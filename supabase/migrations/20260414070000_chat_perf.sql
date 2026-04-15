-- ============================================================
-- chat 성능 개선 + 레이스 조건 차단
--
-- 1) get_my_chat_rooms()  — 방목록 3N+2 쿼리를 1회 RPC 로 대체
-- 2) get_or_create_direct_room() 재정의 — advisory lock 으로 DM 중복 방지
-- 3) share_team_with(p_other) — 두 사용자가 같은 팀에 속해있는지 1회 조회
-- ============================================================

-- ── 1. 방 목록 집계 RPC ──

create or replace function public.get_my_chat_rooms()
returns table (
  room_id uuid,
  room_type text,
  team_id uuid,
  team_name text,
  peer_id uuid,
  peer_name text,
  peer_avatar_url text,
  last_message text,
  last_message_sender text,
  last_message_at timestamptz,
  member_count int,
  unread_count int,
  last_read_at timestamptz
)
language sql
stable security definer set search_path = ''
as $$
  with me as (select auth.uid() as id),
  my_rooms as (
    select crm.room_id, crm.last_read_at
    from public.chat_room_members crm, me
    where crm.player_id = me.id
  ),
  last_msg as (
    select distinct on (cm.room_id)
      cm.room_id,
      cm.content,
      cm.created_at,
      cm.sender_id,
      p.name as sender_name
    from public.chat_messages cm
    join my_rooms r on r.room_id = cm.room_id
    left join public.players p on p.id = cm.sender_id
    order by cm.room_id, cm.created_at desc
  ),
  member_cnt as (
    select room_id, count(*)::int as cnt
    from public.chat_room_members
    where room_id in (select room_id from my_rooms)
    group by room_id
  ),
  unread_cnt as (
    select cm.room_id, count(*)::int as cnt
    from public.chat_messages cm
    join my_rooms r on r.room_id = cm.room_id
    where cm.sender_id <> (select id from me)
      and cm.created_at > r.last_read_at
    group by cm.room_id
  ),
  dm_peer as (
    select
      crm.room_id,
      crm.player_id as peer_id,
      p.name        as peer_name,
      p.avatar_url  as peer_avatar_url
    from public.chat_room_members crm
    join public.chat_rooms  cr on cr.id = crm.room_id and cr.type = 'direct'
    join public.players     p  on p.id = crm.player_id
    where crm.player_id <> (select id from me)
      and crm.room_id in (select room_id from my_rooms)
  )
  select
    cr.id,
    cr.type,
    cr.team_id,
    cr.name,
    dm.peer_id,
    dm.peer_name,
    dm.peer_avatar_url,
    lm.content,
    lm.sender_name,
    lm.created_at,
    coalesce(mc.cnt, 0),
    coalesce(uc.cnt, 0),
    r.last_read_at
  from public.chat_rooms cr
  join my_rooms r on r.room_id = cr.id
  left join last_msg     lm on lm.room_id = cr.id
  left join member_cnt   mc on mc.room_id = cr.id
  left join unread_cnt   uc on uc.room_id = cr.id
  left join dm_peer      dm on dm.room_id = cr.id
  order by lm.created_at desc nulls last;
$$;

comment on function public.get_my_chat_rooms()
  is '내 채팅방 목록 + 메타데이터를 한 번에 반환 (N+1 제거).';

-- ── 2. 같은 팀 여부 ──

create or replace function public.share_team_with(p_other uuid)
returns boolean
language sql
stable security definer set search_path = ''
as $$
  select exists (
    select 1
    from public.team_members a
    join public.team_members b on a.team_id = b.team_id
    where a.player_id = auth.uid()
      and b.player_id = p_other
  );
$$;

comment on function public.share_team_with(uuid)
  is '현재 유저와 상대가 같은 팀에 속해있는지 1회 조회.';

-- ── 3. DM 방 가져오기/만들기 — advisory lock 으로 레이스 차단 ──

create or replace function public.get_or_create_direct_room(p_other uuid)
returns jsonb
language plpgsql
security definer set search_path = ''
as $$
declare
  v_me uuid;
  v_room_id uuid;
  v_lock_key bigint;
  v_a uuid;
  v_b uuid;
begin
  v_me := auth.uid();
  if v_me is null then
    raise exception 'Not authenticated';
  end if;
  if v_me = p_other then
    raise exception 'Cannot DM yourself';
  end if;

  -- 같은 팀 검증
  if not exists (
    select 1
    from public.team_members a
    join public.team_members b on a.team_id = b.team_id
    where a.player_id = v_me and b.player_id = p_other
  ) then
    raise exception 'Not a teammate';
  end if;

  -- 두 참여자의 정렬된 쌍으로 advisory lock 키 생성 (순서 무관하게 동일 키)
  if v_me < p_other then
    v_a := v_me; v_b := p_other;
  else
    v_a := p_other; v_b := v_me;
  end if;
  v_lock_key := hashtextextended(v_a::text || '|' || v_b::text, 0);
  perform pg_advisory_xact_lock(v_lock_key);

  -- 락 획득 후 기존 방 재확인
  select cr.id into v_room_id
  from public.chat_rooms cr
  where cr.type = 'direct'
    and exists (
      select 1 from public.chat_room_members
      where room_id = cr.id and player_id = v_me
    )
    and exists (
      select 1 from public.chat_room_members
      where room_id = cr.id and player_id = p_other
    )
  limit 1;

  if v_room_id is not null then
    return jsonb_build_object('room_id', v_room_id, 'created', false);
  end if;

  insert into public.chat_rooms (type) values ('direct')
  returning id into v_room_id;

  insert into public.chat_room_members (room_id, player_id)
  values (v_room_id, v_me), (v_room_id, p_other);

  return jsonb_build_object('room_id', v_room_id, 'created', true);
end;
$$;

comment on function public.get_or_create_direct_room(uuid)
  is 'DM 방 가져오기/만들기 — advisory lock 으로 동시 생성 차단.';
