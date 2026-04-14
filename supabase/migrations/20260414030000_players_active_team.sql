-- 유저가 현재 선택한 활성 팀. 여러 팀에 소속되었을 때 홈이 어느 팀을 기본으로
-- 보여줄지 결정. null 이면 앱에서 첫번째 팀을 기본으로 사용.
--
-- 팀이 삭제되면 NULL 로 세팅해서 팀 참조 무결성 유지.

alter table public.players
  add column if not exists active_team_id uuid
    references public.teams(id) on delete set null;

comment on column public.players.active_team_id
  is '유저가 현재 선택한 활성 팀. null 이면 가입한 첫 팀을 기본으로.';
