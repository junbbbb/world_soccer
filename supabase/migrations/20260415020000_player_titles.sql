-- ============================================================
-- 선수 뱃지 (득점왕/어시왕/출석왕/MOM왕) 반기 기준
-- 결정 017
-- ============================================================
--
-- 입력: player_id, team_id, year, half ('H1' | 'H2')
-- 출력: 선수가 해당 팀·반기에서 1등(공동 포함)인 카테고리 라벨 배열
-- 룰:
--   - 반기 범위: H1 = 1~6월, H2 = 7~12월
--   - 최소 3경기 출전해야 뱃지 자격 있음
--   - 공동 1위는 모두 뱃지 수여
--   - max 값이 0이면 아무도 받지 못함 (예: 아직 아무도 MOM 없을 때)
--   - 완료된 경기(status = 'completed')만 집계

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
      count(distinct pms.match_id)::int as appearances,
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
    having count(distinct pms.match_id) >= 3
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
      then '득점왕'
    end,
    case
      when exists (select 1 from me)
       and (select assists from me) = (select max_assists from max_vals)
       and (select max_assists from max_vals) > 0
      then '어시왕'
    end,
    case
      when exists (select 1 from me)
       and (select appearances from me) = (select max_appearances from max_vals)
       and (select max_appearances from max_vals) > 0
      then '출석왕'
    end,
    case
      when exists (select 1 from me)
       and (select mom_count from me) = (select max_mom from max_vals)
       and (select max_mom from max_vals) > 0
      then 'MOM왕'
    end
  ], null);
$$;

comment on function public.get_player_titles(uuid, uuid, int, text) is
  '팀·반기 기준 1등 카테고리 뱃지 반환. 최소 3경기, 공동 1위 포함.';

grant execute on function public.get_player_titles(uuid, uuid, int, text) to authenticated;
