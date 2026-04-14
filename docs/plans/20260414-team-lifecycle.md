# 2026-04-14 — 팀 라이프사이클 (로고/생성/탈퇴/전환)

결정 007~010 묶음. 한 유저가 여러 팀에 소속되어 자유롭게 오갈 수 있는 구조 완성.

## 변경 요약 (사용자 관점)

### Before → After

**팀 로고**
- Before: 모든 팀 로고가 `logo_calo.png` 하드코딩
- After: 자동 로고(이니셜 + 색상 8색 팔레트) 즉시 사용. 팀 탭 톱니 → "팀 로고 수정" 에서 변경

**팀 생성**
- Before: 온보딩에서만 가능, 팀 이름만 입력, 기존 팀 있으면 추가 생성 경로 없음
- After: 풀스크린(`/team/create`) 에서 이름 + 색상 + 팀 소개 한 번에 입력. 홈 팀 스위처 "새 팀 만들기", 팀 설정 시트 "새 팀 만들기", 온보딩 버튼 모두 같은 화면으로 연결

**팀 탈퇴**
- Before: 기능 없음
- After: 팀 탭 톱니 → "팀 탈퇴" → 확인 다이얼로그. 마지막 admin 이면 차단 ("다른 멤버를 관리자로 지정하거나 팀을 삭제하세요")

**팀 전환 (다중 팀 소속)**
- Before: 홈 상단 팀 로고 탭 시 더미 목록 노출, 선택해도 아무 동작 없음
- After: 실제 소속 팀 리스트, 선택 시 DB `players.active_team_id` 업데이트, 홈 전체가 선택한 팀 데이터로 리프레시

## TDD 흐름

`test/service/team_service_test.dart` — 총 14 케이스 (leaveTeam 6, createTeam 5, switchTeam 3)

**🔴 Red**: 테스트 작성 → 서비스/예외 타입 부재로 컴파일 실패 확인
**🟢 Green**: `TeamService` + `LastAdminException` + `NotAMemberException` + 필요한 `TeamRepo`/`PlayerRepo` 메서드 구현 → 14/14 통과
**🔵 Refactor**: UI 와 Provider 연결, 중복 코드 제거 (온보딩 `_CreateTeamView` ~285줄)

## DB 변경

| 마이그레이션 | 내용 |
|------|------|
| `20260414010000_teams_logo_color.sql` | `teams.logo_color text` 추가 |
| `20260414020000_teams_description.sql` | `teams.description text` 추가 |
| `20260414030000_players_active_team.sql` | `players.active_team_id uuid references teams(id) on delete set null` 추가 |
| `20260414040000_team_logos_bucket.sql` | Storage 버킷 `team-logos` + RLS (read public, write admin only) |

RLS 정책은 기존 `teams_update`(admin only) / `team_members_delete`(본인 탈퇴 허용) / `players_update_own` 으로 충분 → 신규 정책 없음.

## 파일 변경

**신규**
- `lib/shared/widgets/team_logo_view.dart` — 통합 로고 위젯 (`TeamLogoView`, `TeamLogoView.byName`, `kTeamLogoPalette`)
- `lib/features/team/presentation/team_create_screen.dart` — 팀 생성 풀스크린
- `lib/features/team/presentation/widgets/team_logo_edit_sheet.dart` — 로고 편집 바텀시트
- `lib/features/team/presentation/widgets/team_settings_sheet.dart` — 팀 설정(로고/새팀/탈퇴) 액션 시트
- `lib/service/team_service.dart` — `TeamService` + `LastAdminException` + `NotAMemberException`
- `test/service/team_service_test.dart`

**수정**
- `lib/types/team.dart` — `logoColor`, `description` 필드 + `copyWith`
- `lib/repo/team_repo.dart` + `lib/repo/supabase_team_repo.dart` — `create(logoColor, description)`, `updateInfo(...)`, `leave()`
- `lib/repo/player_repo.dart` + `lib/repo/supabase_player_repo.dart` — `setActiveTeam`, `getActiveTeamId`
- `lib/runtime/providers.dart` — `teamServiceProvider`, `currentTeamProvider` 가 `players.active_team_id` 우선 조회
- `lib/core/router/app_router.dart` — `/team/create` 라우트
- `lib/features/home/presentation/home_tab.dart` — `_TeamSwitcherSheet` 실제 데이터 + `switchTeam` 호출
- `lib/features/team/presentation/team_tab.dart` — 톱니 onTap → 설정 시트 / 새 팀, `_TeamInfoSection` 실제 팀 렌더
- `lib/features/auth/presentation/onboarding_screen.dart` — `_CreateTeamView` + `_showInviteCodeDialog` + `_showLogoCtaDialog` 제거, "새 팀 만들기" → `context.push('/team/create')`
- `lib/shared/widgets/team_logo_badge.dart` — 내부적으로 `TeamLogoView` 위임

## 위험도

- 로고 위젯/편집 시트 / 생성 화면: **Shell** (시각 변경)
- `TeamService` 규칙 / DB 마이그레이션 / `active_team_id` 흐름 / 탈퇴: **Core**
- `currentTeamProvider` 재작성: **Mid** (리플 체인이 넓음)

## 확인 필요 (Core 영역)

- [x] `teams.logo_color` / `description` 컬럼 nullable + 기존 row 영향 없는지 (확인됨: ADD COLUMN 만, 기본값 불변)
- [x] `players.active_team_id` FK + `on delete set null` 로 팀 삭제 시 안전한지 (확인됨)
- [x] `matches_update` 와 동일 조건으로 권한 대칭 (확인됨)
- [x] `team_members_delete` RLS 가 본인 탈퇴 허용하는지 (확인됨)
- [ ] 다중 팀 소속 admin 계정으로 실기기 팀 전환 → 홈/경기탭 데이터 리프레시 확인
- [ ] `LastAdminException` 실제 팀에서 트리거 (admin 혼자 아닌 경우 확인)
