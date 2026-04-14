-- 팀 기본 로고 색상. logo_url 이 없을 때 이니셜 배경색으로 사용.
-- hex #RRGGBB 형태, NULL 이면 앱에서 기본색(primary) 사용.

alter table public.teams
  add column if not exists logo_color text;

comment on column public.teams.logo_color
  is '자동 생성 로고 배경색. #RRGGBB. logo_url 있으면 무시.';
