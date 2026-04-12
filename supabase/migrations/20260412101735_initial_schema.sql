-- ============================================================
-- 칼로FC 초기 스키마
-- ============================================================

-- ── 1. players (auth.users 1:1) ──

create table public.players (
  id          uuid primary key references auth.users(id) on delete cascade,
  name        text not null,
  number      int,
  avatar_url  text,
  preferred_positions text[] default '{}',
  preferred_foot text check (preferred_foot in ('오른발', '왼발', '양발')),
  height      int,
  created_at  timestamptz not null default now()
);

comment on table public.players is '선수 프로필 (auth.users와 1:1)';

-- ── 2. teams ──

create table public.teams (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  logo_url    text,
  created_at  timestamptz not null default now()
);

comment on table public.teams is '팀';

-- ── 3. team_members (다대다) ──

create table public.team_members (
  team_id     uuid not null references public.teams(id) on delete cascade,
  player_id   uuid not null references public.players(id) on delete cascade,
  role        text not null default 'member' check (role in ('admin', 'member')),
  joined_at   timestamptz not null default now(),
  primary key (team_id, player_id)
);

comment on table public.team_members is '팀 멤버십';

-- ── 4. matches ──

create table public.matches (
  id              uuid primary key default gen_random_uuid(),
  team_id         uuid not null references public.teams(id) on delete cascade,
  date            timestamptz not null,
  location        text not null,
  opponent_name   text not null,
  opponent_logo_url text,
  our_score       int,
  opponent_score  int,
  status          text not null default 'upcoming' check (status in ('upcoming', 'completed')),
  created_at      timestamptz not null default now()
);

comment on table public.matches is '경기';
create index idx_matches_team_date on public.matches(team_id, date desc);

-- ── 5. match_participations ──

create table public.match_participations (
  match_id            uuid not null references public.matches(id) on delete cascade,
  player_id           uuid not null references public.players(id) on delete cascade,
  preferred_positions text[] default '{}',
  available_quarters  int[] default '{1,2,3,4}',
  created_at          timestamptz not null default now(),
  primary key (match_id, player_id)
);

comment on table public.match_participations is '경기 참가 신청';

-- ── 6. quarter_lineups (정규화) ──

create table public.quarter_lineups (
  match_id        uuid not null references public.matches(id) on delete cascade,
  quarter         int not null check (quarter between 1 and 4),
  formation_name  text not null,
  created_at      timestamptz not null default now(),
  primary key (match_id, quarter)
);

comment on table public.quarter_lineups is '쿼터별 포메이션';

-- ── 7. slot_assignments (라인업 슬롯) ──

create table public.slot_assignments (
  match_id    uuid not null,
  quarter     int not null,
  slot_index  int not null,
  player_id   uuid not null references public.players(id) on delete cascade,
  primary key (match_id, quarter, slot_index),
  foreign key (match_id, quarter) references public.quarter_lineups(match_id, quarter) on delete cascade
);

comment on table public.slot_assignments is '라인업 슬롯 배정';
create index idx_slot_assignments_player on public.slot_assignments(player_id);

-- ── 8. player_match_stats ──

create table public.player_match_stats (
  match_id    uuid not null references public.matches(id) on delete cascade,
  player_id   uuid not null references public.players(id) on delete cascade,
  goals       int not null default 0,
  assists     int not null default 0,
  is_mom      boolean not null default false,
  primary key (match_id, player_id)
);

comment on table public.player_match_stats is '선수별 경기 기록';
create index idx_player_match_stats_player on public.player_match_stats(player_id);

-- ============================================================
-- Auto-create player profile on signup
-- ============================================================

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.players (id, name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'name', '새 선수'));
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================================================
-- RLS (Row Level Security)
-- ============================================================

alter table public.players enable row level security;
alter table public.teams enable row level security;
alter table public.team_members enable row level security;
alter table public.matches enable row level security;
alter table public.match_participations enable row level security;
alter table public.quarter_lineups enable row level security;
alter table public.slot_assignments enable row level security;
alter table public.player_match_stats enable row level security;

-- players: 본인 수정, 인증 사용자 조회
create policy "players_select" on public.players
  for select using (auth.uid() is not null);

create policy "players_update_own" on public.players
  for update using (auth.uid() = id);

-- teams: 팀원이면 조회, admin이면 수정
create policy "teams_select" on public.teams
  for select using (
    exists (
      select 1 from public.team_members
      where team_id = teams.id and player_id = auth.uid()
    )
  );

create policy "teams_insert" on public.teams
  for insert with check (auth.uid() is not null);

create policy "teams_update" on public.teams
  for update using (
    exists (
      select 1 from public.team_members
      where team_id = teams.id and player_id = auth.uid() and role = 'admin'
    )
  );

-- team_members: 팀원이면 조회
create policy "team_members_select" on public.team_members
  for select using (
    exists (
      select 1 from public.team_members tm
      where tm.team_id = team_members.team_id and tm.player_id = auth.uid()
    )
  );

create policy "team_members_insert" on public.team_members
  for insert with check (
    player_id = auth.uid() or
    exists (
      select 1 from public.team_members tm
      where tm.team_id = team_members.team_id and tm.player_id = auth.uid() and tm.role = 'admin'
    )
  );

-- matches: 팀원이면 조회/생성
create policy "matches_select" on public.matches
  for select using (
    exists (
      select 1 from public.team_members
      where team_id = matches.team_id and player_id = auth.uid()
    )
  );

create policy "matches_insert" on public.matches
  for insert with check (
    exists (
      select 1 from public.team_members
      where team_id = matches.team_id and player_id = auth.uid()
    )
  );

create policy "matches_update" on public.matches
  for update using (
    exists (
      select 1 from public.team_members
      where team_id = matches.team_id and player_id = auth.uid() and role = 'admin'
    )
  );

-- match_participations: 팀원 조회, 본인 참가/취소
create policy "participations_select" on public.match_participations
  for select using (
    exists (
      select 1 from public.matches m
      join public.team_members tm on tm.team_id = m.team_id
      where m.id = match_participations.match_id and tm.player_id = auth.uid()
    )
  );

create policy "participations_insert" on public.match_participations
  for insert with check (player_id = auth.uid());

create policy "participations_delete" on public.match_participations
  for delete using (player_id = auth.uid());

-- quarter_lineups: 팀원 조회, admin 수정
create policy "lineups_select" on public.quarter_lineups
  for select using (
    exists (
      select 1 from public.matches m
      join public.team_members tm on tm.team_id = m.team_id
      where m.id = quarter_lineups.match_id and tm.player_id = auth.uid()
    )
  );

create policy "lineups_all_admin" on public.quarter_lineups
  for all using (
    exists (
      select 1 from public.matches m
      join public.team_members tm on tm.team_id = m.team_id
      where m.id = quarter_lineups.match_id and tm.player_id = auth.uid() and tm.role = 'admin'
    )
  );

-- slot_assignments: quarter_lineups와 동일 권한
create policy "slots_select" on public.slot_assignments
  for select using (
    exists (
      select 1 from public.matches m
      join public.team_members tm on tm.team_id = m.team_id
      where m.id = slot_assignments.match_id and tm.player_id = auth.uid()
    )
  );

create policy "slots_all_admin" on public.slot_assignments
  for all using (
    exists (
      select 1 from public.matches m
      join public.team_members tm on tm.team_id = m.team_id
      where m.id = slot_assignments.match_id and tm.player_id = auth.uid() and tm.role = 'admin'
    )
  );

-- player_match_stats: 팀원 조회, admin 수정
create policy "stats_select" on public.player_match_stats
  for select using (
    exists (
      select 1 from public.matches m
      join public.team_members tm on tm.team_id = m.team_id
      where m.id = player_match_stats.match_id and tm.player_id = auth.uid()
    )
  );

create policy "stats_all_admin" on public.player_match_stats
  for all using (
    exists (
      select 1 from public.matches m
      join public.team_members tm on tm.team_id = m.team_id
      where m.id = player_match_stats.match_id and tm.player_id = auth.uid() and tm.role = 'admin'
    )
  );

-- ============================================================
-- 편의 뷰: 시즌 스탯 집계
-- ============================================================

create or replace view public.season_player_stats as
select
  p.id as player_id,
  p.name,
  m.team_id,
  extract(year from m.date)::int as year,
  case when extract(month from m.date) <= 6 then '상반기' else '하반기' end as half,
  count(distinct pms.match_id)::int as appearances,
  coalesce(sum(pms.goals), 0)::int as goals,
  coalesce(sum(pms.assists), 0)::int as assists,
  count(*) filter (where pms.is_mom)::int as mom_count
from public.players p
join public.player_match_stats pms on pms.player_id = p.id
join public.matches m on m.id = pms.match_id
group by p.id, p.name, m.team_id, year, half;
