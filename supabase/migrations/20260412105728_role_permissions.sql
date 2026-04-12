-- ============================================================
-- 3단계 역할 체계 + RLS 수정
-- admin(운영진), member(일반유저), mercenary(용병)
-- ============================================================

-- ── 1. team_members.role에 mercenary 추가 ──

alter table public.team_members
  drop constraint team_members_role_check;

alter table public.team_members
  add constraint team_members_role_check
  check (role in ('admin', 'member', 'mercenary'));

-- ── 2. matches_insert: admin 전용으로 수정 ──

drop policy "matches_insert" on public.matches;

create policy "matches_insert" on public.matches
  for insert with check (
    exists (
      select 1 from public.team_members
      where team_id = matches.team_id
        and player_id = auth.uid()
        and role = 'admin'
    )
  );

-- ── 3. mercenary 조회 권한 ──
-- mercenary는 소속 팀의 경기/라인업/스탯을 조회만 가능
-- 기존 select 정책은 team_members 존재 여부로 체크하므로
-- mercenary가 team_members에 등록되면 자동으로 조회 가능 ✓
-- 별도 정책 불필요

-- ── 4. match_participations: mercenary도 참가 가능하도록 ──
-- 기존: player_id = auth.uid() (본인만 참가 신청)
-- 수정: admin이 대신 참가 등록 가능 (용병 대리 등록)

drop policy "participations_insert" on public.match_participations;

create policy "participations_insert" on public.match_participations
  for insert with check (
    -- 본인 참가 신청
    player_id = auth.uid()
    or
    -- admin이 대리 등록 (용병 등)
    exists (
      select 1 from public.matches m
      join public.team_members tm on tm.team_id = m.team_id
      where m.id = match_participations.match_id
        and tm.player_id = auth.uid()
        and tm.role = 'admin'
    )
  );

-- participations_delete도 admin 대리 삭제 가능하도록
drop policy "participations_delete" on public.match_participations;

create policy "participations_delete" on public.match_participations
  for delete using (
    player_id = auth.uid()
    or
    exists (
      select 1 from public.matches m
      join public.team_members tm on tm.team_id = m.team_id
      where m.id = match_participations.match_id
        and tm.player_id = auth.uid()
        and tm.role = 'admin'
    )
  );

-- ── 5. team_members: admin이 mercenary 추가/삭제 가능 ──
-- 기존 insert 정책에 이미 admin 체크 있음 ✓

-- admin이 mercenary 제거 가능하도록 delete 정책 추가
create policy "team_members_delete" on public.team_members
  for delete using (
    -- 본인 탈퇴
    player_id = auth.uid()
    or
    -- admin이 멤버/용병 제거
    exists (
      select 1 from public.team_members tm
      where tm.team_id = team_members.team_id
        and tm.player_id = auth.uid()
        and tm.role = 'admin'
    )
  );
