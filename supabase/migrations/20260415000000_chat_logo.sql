-- ============================================================
-- chat: 방 목록에 팀 로고 URL/컬러를 포함해서 반환
-- ============================================================

drop function if exists public.get_my_chat_rooms();

create or replace function public.get_my_chat_rooms()
returns table (
  room_id uuid,
  room_type text,
  team_id uuid,
  team_name text,
  team_logo_url text,
  team_logo_color text,
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
    cr.name        as team_name,
    t.logo_url     as team_logo_url,
    t.logo_color   as team_logo_color,
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
  left join public.teams t on t.id = cr.team_id
  left join last_msg     lm on lm.room_id = cr.id
  left join member_cnt   mc on mc.room_id = cr.id
  left join unread_cnt   uc on uc.room_id = cr.id
  left join dm_peer      dm on dm.room_id = cr.id
  order by lm.created_at desc nulls last;
$$;
