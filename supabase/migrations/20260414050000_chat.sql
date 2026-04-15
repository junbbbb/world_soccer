-- ============================================================
-- 채팅 시스템
-- 팀 채팅방: 팀 생성 시 자동 생성, 팀원 추가/삭제 시 자동 동기화
-- DM:       팀원 간 1:1. 항상 참여자 2명 고정
-- ============================================================

-- ── 1. chat_rooms ──

create table public.chat_rooms (
  id         uuid primary key default gen_random_uuid(),
  type       text not null check (type in ('team', 'direct')),
  team_id    uuid references public.teams(id) on delete cascade,
  name       text,
  created_at timestamptz not null default now(),
  -- 팀당 단체방은 정확히 1개
  constraint chat_rooms_team_unique unique (team_id),
  -- type 무결성
  constraint chat_rooms_type_integrity check (
    (type = 'team'   and team_id is not null) or
    (type = 'direct' and team_id is null)
  )
);

comment on table public.chat_rooms is '채팅방 (팀 단체방 + 팀원 간 DM)';
create index idx_chat_rooms_team on public.chat_rooms(team_id);

-- ── 2. chat_room_members ──

create table public.chat_room_members (
  room_id      uuid not null references public.chat_rooms(id) on delete cascade,
  player_id    uuid not null references public.players(id) on delete cascade,
  joined_at    timestamptz not null default now(),
  last_read_at timestamptz not null default now(),
  primary key (room_id, player_id)
);

comment on table public.chat_room_members is '채팅방 참여자';
create index idx_chat_room_members_player on public.chat_room_members(player_id);

-- ── 3. chat_messages ──

create table public.chat_messages (
  id         uuid primary key default gen_random_uuid(),
  room_id    uuid not null references public.chat_rooms(id) on delete cascade,
  sender_id  uuid not null references public.players(id) on delete cascade,
  content    text not null,
  type       text not null default 'text' check (type in ('text', 'event')),
  created_at timestamptz not null default now()
);

comment on table public.chat_messages is '채팅 메시지';
create index idx_chat_messages_room_time
  on public.chat_messages(room_id, created_at desc);

-- ============================================================
-- 자동 동기화 트리거
-- ============================================================

-- 팀 생성 시 단체 채팅방 자동 생성
create or replace function public.create_team_chat_room()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.chat_rooms (type, team_id, name)
  values ('team', new.id, new.name);
  return new;
end;
$$;

create trigger on_team_created_create_chat_room
  after insert on public.teams
  for each row execute function public.create_team_chat_room();

-- 팀명이 바뀌면 방 이름도 동기화
create or replace function public.sync_team_chat_room_name()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  if new.name is distinct from old.name then
    update public.chat_rooms
    set name = new.name
    where team_id = new.id;
  end if;
  return new;
end;
$$;

create trigger on_team_renamed_sync_chat_room
  after update on public.teams
  for each row execute function public.sync_team_chat_room_name();

-- 팀원 추가 시 팀 채팅방 자동 참여
create or replace function public.join_team_chat_room()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
declare
  v_room_id uuid;
begin
  select id into v_room_id
  from public.chat_rooms
  where team_id = new.team_id;

  if v_room_id is not null then
    insert into public.chat_room_members (room_id, player_id)
    values (v_room_id, new.player_id)
    on conflict do nothing;
  end if;

  return new;
end;
$$;

create trigger on_team_member_added_join_chat_room
  after insert on public.team_members
  for each row execute function public.join_team_chat_room();

-- 팀원 제거 시 팀 채팅방 자동 탈퇴
create or replace function public.leave_team_chat_room()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  delete from public.chat_room_members
  using public.chat_rooms
  where chat_room_members.room_id = chat_rooms.id
    and chat_rooms.team_id = old.team_id
    and chat_room_members.player_id = old.player_id;
  return old;
end;
$$;

create trigger on_team_member_removed_leave_chat_room
  after delete on public.team_members
  for each row execute function public.leave_team_chat_room();

-- 기존 팀/팀원에 대한 백필
insert into public.chat_rooms (type, team_id, name)
select 'team', t.id, t.name
from public.teams t
where not exists (
  select 1 from public.chat_rooms where team_id = t.id
);

insert into public.chat_room_members (room_id, player_id)
select cr.id, tm.player_id
from public.chat_rooms cr
join public.team_members tm on tm.team_id = cr.team_id
where cr.type = 'team'
on conflict do nothing;

-- ============================================================
-- DM 방 생성 함수 (양쪽 참여자 원자적 등록)
-- ============================================================

create or replace function public.get_or_create_direct_room(p_other uuid)
returns jsonb
language plpgsql
security definer set search_path = ''
as $$
declare
  v_me uuid;
  v_room_id uuid;
begin
  v_me := auth.uid();
  if v_me is null then
    raise exception 'Not authenticated';
  end if;
  if v_me = p_other then
    raise exception 'Cannot DM yourself';
  end if;

  -- 같은 팀에 소속되어 있는지 검증
  if not exists (
    select 1
    from public.team_members a
    join public.team_members b on a.team_id = b.team_id
    where a.player_id = v_me and b.player_id = p_other
  ) then
    raise exception 'Not a teammate';
  end if;

  -- 기존 DM 조회 (두 참여자로만 구성된 direct 방)
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

  -- 새 DM 방 생성
  insert into public.chat_rooms (type) values ('direct')
  returning id into v_room_id;

  insert into public.chat_room_members (room_id, player_id)
  values (v_room_id, v_me), (v_room_id, p_other);

  return jsonb_build_object('room_id', v_room_id, 'created', true);
end;
$$;

-- ============================================================
-- RLS
-- ============================================================

alter table public.chat_rooms        enable row level security;
alter table public.chat_room_members enable row level security;
alter table public.chat_messages     enable row level security;

-- 참여자만 방 조회
create policy "chat_rooms_select" on public.chat_rooms
  for select using (
    exists (
      select 1 from public.chat_room_members
      where room_id = chat_rooms.id and player_id = auth.uid()
    )
  );

-- 참여자 목록: 같은 방 참여자끼리만 조회
create policy "chat_room_members_select" on public.chat_room_members
  for select using (
    exists (
      select 1 from public.chat_room_members m
      where m.room_id = chat_room_members.room_id and m.player_id = auth.uid()
    )
  );

-- last_read_at 본인만 갱신
create policy "chat_room_members_update_own" on public.chat_room_members
  for update using (player_id = auth.uid())
  with check (player_id = auth.uid());

-- 메시지: 참여자만 조회/작성
create policy "chat_messages_select" on public.chat_messages
  for select using (
    exists (
      select 1 from public.chat_room_members
      where room_id = chat_messages.room_id and player_id = auth.uid()
    )
  );

create policy "chat_messages_insert" on public.chat_messages
  for insert with check (
    sender_id = auth.uid() and exists (
      select 1 from public.chat_room_members
      where room_id = chat_messages.room_id and player_id = auth.uid()
    )
  );

-- 본인 메시지 삭제 허용(선택)
create policy "chat_messages_delete_own" on public.chat_messages
  for delete using (sender_id = auth.uid());

-- ============================================================
-- Realtime
-- ============================================================

alter publication supabase_realtime add table public.chat_messages;
alter publication supabase_realtime add table public.chat_room_members;
