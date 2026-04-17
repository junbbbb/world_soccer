-- ============================================================
-- get_player_titles v2 — i18n-safe 코드 반환 + count(*) 최적화
-- 결정 017 개정
-- ============================================================
--
-- v1 (20260415020000) 대비 변경:
--   1. 반환 라벨을 Korean UI 문자열('득점왕' 등) → 안정 코드('top_scorer' 등)
--      i18n 대비. 클라이언트는 PlayerTitle.fromCode 로 enum 매핑
--   2. count(distinct match_id) → count(*)
--      player_match_stats PK 가 (match_id, player_id) 라 이미 unique

create or replace function public.get_player_titles(
  p_player_id uuid,
  p_team_id uuid,
  p_year int,
  p_half text
)
returns text[]
language sql
stable
security definer
set search_path = ''
as $$
  with player_stats as (
    select
      pms.player_id,
      count(*)::int as appearances,
      coalesce(sum(pms.goals), 0)::int as goals,
      coalesce(sum(pms.assists), 0)::int as assists,
      count(*) filter (where pms.is_mom)::int as mom_count
    from public.player_match_stats pms
    join public.matches m on m.id = pms.match_id
    where m.team_id = p_team_id
      and m.status = 'completed'
      and extract(year from m.date)::int = p_year
      and (
        (p_half = 'H1' and extract(month from m.date) between 1 and 6)
        or
        (p_half = 'H2' and extract(month from m.date) between 7 and 12)
      )
    group by pms.player_id
    having count(*) >= 3
  ),
  max_vals as (
    select
      coalesce(max(goals), 0) as max_goals,
      coalesce(max(assists), 0) as max_assists,
      coalesce(max(appearances), 0) as max_appearances,
      coalesce(max(mom_count), 0) as max_mom
    from player_stats
  ),
  me as (
    select * from player_stats where player_id = p_player_id
  )
  select array_remove(array[
    case
      when exists (select 1 from me)
       and (select goals from me) = (select max_goals from max_vals)
       and (select max_goals from max_vals) > 0
      then 'top_scorer'
    end,
    case
      when exists (select 1 from me)
       and (select assists from me) = (select max_assists from max_vals)
       and (select max_assists from max_vals) > 0
      then 'top_assister'
    end,
    case
      when exists (select 1 from me)
       and (select appearances from me) = (select max_appearances from max_vals)
       and (select max_appearances from max_vals) > 0
      then 'top_attendance'
    end,
    case
      when exists (select 1 from me)
       and (select mom_count from me) = (select max_mom from max_vals)
       and (select max_mom from max_vals) > 0
      then 'top_mom'
    end
  ], null);
$$;

comment on function public.get_player_titles(uuid, uuid, int, text) is
  '팀·반기 기준 1등 카테고리 뱃지 반환. 안정 코드 반환 (클라이언트에서 i18n). 최소 3경기, 공동 1위 포함.';
