-- 팀 소개 한 줄. 팀 식별에 도움되는 선택값. 최대 200자 가정.

alter table public.teams
  add column if not exists description text;

comment on column public.teams.description
  is '팀 소개. 예: 매주 토요일 저녁, 강동구 40대 모임.';
