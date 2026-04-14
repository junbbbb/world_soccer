-- 경기 삭제 정책: 해당 팀의 admin 만 삭제 가능.
-- matches_update 정책과 동일한 admin 체크. 자식 테이블
-- (match_participations, quarter_lineups, match_stats) 은 이미
-- on delete cascade 로 연결되어 있어 별도 정리 필요 없음.

create policy "matches_delete" on public.matches
  for delete using (
    exists (
      select 1 from public.team_members
      where team_id = matches.team_id
        and player_id = auth.uid()
        and role = 'admin'
    )
  );
