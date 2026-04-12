-- ============================================================
-- 팀 초대 코드 시스템
-- ============================================================

create table public.team_invites (
  id          uuid primary key default gen_random_uuid(),
  team_id     uuid not null references public.teams(id) on delete cascade,
  invite_code text not null unique,
  created_by  uuid not null references public.players(id) on delete cascade,
  role        text not null default 'member' check (role in ('admin', 'member', 'mercenary')),
  expires_at  timestamptz,
  max_uses    int,
  use_count   int not null default 0,
  is_active   boolean not null default true,
  created_at  timestamptz not null default now()
);

comment on table public.team_invites is '팀 초대 코드';
create index idx_team_invites_code on public.team_invites(invite_code) where is_active = true;

-- ── RLS ──

alter table public.team_invites enable row level security;

-- 초대 코드 조회: 누구나 (코드로 팀 가입하려면 조회 필요)
create policy "invites_select_by_code" on public.team_invites
  for select using (true);

-- 초대 코드 생성: admin만
create policy "invites_insert" on public.team_invites
  for insert with check (
    exists (
      select 1 from public.team_members
      where team_id = team_invites.team_id
        and player_id = auth.uid()
        and role = 'admin'
    )
  );

-- 초대 코드 수정/비활성화: admin만
create policy "invites_update" on public.team_invites
  for update using (
    exists (
      select 1 from public.team_members
      where team_id = team_invites.team_id
        and player_id = auth.uid()
        and role = 'admin'
    )
  );

-- ============================================================
-- 초대 코드로 팀 가입하는 함수 (RLS 우회)
-- ============================================================

create or replace function public.join_team_by_invite(p_invite_code text)
returns jsonb
language plpgsql
security definer set search_path = ''
as $$
declare
  v_invite record;
  v_user_id uuid;
  v_team_name text;
begin
  v_user_id := auth.uid();
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  -- 초대 코드 조회
  select * into v_invite
  from public.team_invites
  where invite_code = p_invite_code
    and is_active = true
    and (expires_at is null or expires_at > now())
    and (max_uses is null or use_count < max_uses);

  if not found then
    raise exception 'Invalid or expired invite code';
  end if;

  -- 이미 가입한 팀인지 확인
  if exists (
    select 1 from public.team_members
    where team_id = v_invite.team_id and player_id = v_user_id
  ) then
    raise exception 'Already a member of this team';
  end if;

  -- 팀 가입
  insert into public.team_members (team_id, player_id, role)
  values (v_invite.team_id, v_user_id, v_invite.role);

  -- 사용 횟수 증가
  update public.team_invites
  set use_count = use_count + 1
  where id = v_invite.id;

  -- 팀 이름 조회
  select name into v_team_name
  from public.teams
  where id = v_invite.team_id;

  return jsonb_build_object(
    'team_id', v_invite.team_id,
    'team_name', v_team_name,
    'role', v_invite.role
  );
end;
$$;
