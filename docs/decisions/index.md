# Technical Decisions Log

## 결정 목록

| # | 날짜 | 제목 | 상태 |
|---|------|------|------|
| 001 | 2026-04-12 | 6-Layer 아키텍처 채택 (OpenAI Layered) | 확정 |
| 002 | 2026-04-12 | Supabase 백엔드 선택 | 확정 |
| 003 | 2026-04-12 | 시즌 구조: 상반기/하반기 (6개월) | 확정 |
| 004 | 2026-04-13 | 상대팀 기본 로고 (OpponentLogo + 이니셜) | 확정 |
| 005 | 2026-04-14 | squircle 라운딩 폐기 (figma_squircle 제거) | 확정 |
| 006 | 2026-04-14 | 경기 삭제 권한: 팀 admin 전용 | 확정 |
| 007 | 2026-04-14 | 팀 로고: 이니셜+색(B) 우선, 업로드(A) 추후 | 확정 |
| 008 | 2026-04-14 | 팀 생성 풀스크린 + 팀 소개 필드 추가 | 확정 |
| 009 | 2026-04-14 | 팀 탈퇴 규칙: 마지막 admin 보호 (TDD) | 확정 |
| 010 | 2026-04-14 | 활성 팀 전환: `players.active_team_id` (TDD) | 확정 |
| 011 | 2026-04-14 | 팀 로고 업로드: Supabase Storage `team-logos` 버킷 | 확정 |

---

## 001. 6-Layer 아키텍처 채택

**결정**: OpenAI Layered Architecture 적용. Types → Config → Repo → Service → Runtime → UI.

**이유**:
- AI 에이전트의 코드 생성 품질 향상 (솔루션 공간 제한)
- 의존성 방향 단일화 → 린터로 물리적 강제 가능
- Clean Architecture와 동일한 원칙이되, 기계 검증에 최적화

**트레이드오프**:
- 기존 features/ 구조에서 마이그레이션 비용
- 글로벌 레이어라 feature 간 경계가 불명확할 수 있음
- → core/theme는 예외적 전역 접근 허용으로 완화

## 002. Supabase 백엔드 선택

**결정**: Firebase 대신 Supabase (Postgres + Auth + Realtime + Storage).

**이유**:
- SQL 기반이라 복잡한 쿼리 (시즌 스탯 집계, H2H 전적) 유리
- Row Level Security로 팀별 데이터 격리
- 오픈소스, 셀프호스팅 가능

## 003. 시즌 구조

**결정**: 상반기 (1~6월) / 하반기 (7~12월).

**이유**: 조기축구 특성상 프로 시즌이 없음. 반기(12~24경기)가 스탯 의미 있는 최소 단위. 분기(6~12경기)는 너무 적음.

## 004. 상대팀 기본 로고 (OpponentLogo + 이니셜)

**결정**: 상대팀 로고가 없을 때, `assets/images/defaultteamlogo.png` 배경 + 팀 이름 첫 글자(이니셜)를 흰색 텍스트로 오버레이하는 `shared/widgets/opponent_logo.dart` 위젯을 사용.

**이유**:
- 상대팀은 보통 실제 로고를 업로드하지 않아 일관된 placeholder 가 필요
- "FC뽀잉" 같은 이름에서 `FC` 접두/접미사를 떼고 첫 글자만 노출하면 판별성이 높음
- 한글 초성 → 영문 매핑으로 일관된 모노그램 (뽀→B, 쏘→S, 드→D, 올→O, 칼→K 등)

**트레이드오프**:
- Flutter `flutter_svg` 가 Figma 의 `<pattern>` + base64 임베디드 PNG 를 제대로 렌더하지 못해, SVG 에서 PNG 를 추출해 크롭(473×597) 해 `defaultteamlogo.png` 로 저장 → 일반 `Image.asset` 사용
- 한글 초성 매핑은 영문 단일 글자로 축약 (예: ㅃ→B). 로마자 표준(Revised Romanization) 과 다를 수 있음

**적용 위치**: `TeamLogoBadge`, 매치탭 `_TeamRow`, 홈 경기 리스트, 최근 전적 캡슐, 프로필 경기 로그. 실제 `logoUrl` 이 있으면 네트워크 이미지 우선, 없을 때만 fallback.

## 005. squircle 라운딩 폐기 (figma_squircle 제거)

**결정**: `figma_squircle` 의존성과 관련 타입(`ClipSmoothRect`, `SmoothRectangleBorder`, `SmoothBorderRadius`, `SmoothRadius`, `cornerSmoothing`) 을 전 코드베이스에서 제거. `AppRadius.smoothXx` 토큰은 이름을 유지하되 내부 값을 `BorderRadius.circular(...)` 로 전환.

**이유**:
- `figma_squircle: ^0.6.3` 은 discontinued 상태
- Flutter 기본 `BorderRadius` + `ClipRRect` + `RoundedRectangleBorder` 만으로 시각 차이가 미미
- 디자인 토큰 키(`smoothLg` 등)는 호환 유지 → 호출처 수정 불필요

**영향**: `lib/` 내 32개 파일 일괄 치환 (스크립트 기반). `pubspec.yaml` 에서 의존성 제거. `flutter analyze` 에러 0건 확인.

## 006. 경기 삭제 권한: 팀 admin 전용

**결정**: 경기 상세 화면의 `⋯` 메뉴에서 `경기 삭제` 를 허용. DB 단에서는 RLS 정책으로 `team_members.role = 'admin'` 인 사용자만 삭제 가능.

**이유**:
- 경기 생성 오기입 정정 용도로 영구 삭제가 필요
- 자식 테이블(`match_participations`, `quarter_lineups`, `match_stats`) 은 이미 `on delete cascade` 로 연결돼 있어 추가 정리 로직 불필요
- 권한은 `matches_update` 정책과 동일 조건(admin only) 으로 대칭

**구현**:
- 마이그레이션: `supabase/migrations/20260414000000_matches_delete_policy.sql` (RLS `matches_delete` 추가)
- Repo: `MatchRepo.delete(matchId)` + `SupabaseMatchRepo` 구현
- UI: `MatchTopBarDelegate.onDelete` + 확인 다이얼로그(AlertDialog) → 성공 시 `teamMatchesProvider` 무효화 및 화면 pop

**트레이드오프**: soft-delete(status='deleted') 가 아닌 hard-delete. 복구 불가. 운영 로그/감사가 필요해지면 archive 테이블로 옮기는 방식으로 재검토.

## 007. 팀 로고: 이니셜+색(B) 우선, 업로드(A) 추후

**결정**: 두 가지 로고 모드 병행. 기본은 B(팀 이름 이니셜 + 배경색), 선택적으로 A(사진 업로드). 이번 단계에선 B 만 구현, A 는 Supabase Storage 버킷 준비 후 별도 진행.

**이유**:
- 업로드 UX 는 크롭/용량/스토리지 RLS 가 붙어 복잡도가 큼. B 만으로도 팀 식별 퀄리티 확보
- 모든 팀이 즉시 일관된 시각 퀄리티 — 디폴트 "빈 방패" 상태가 없음
- A 에 대비해 `logo_url` 은 계속 우선순위 1, B 는 fallback 이라 나중에 A 구현해도 호환

**구현**:
- 마이그레이션 `20260414010000_teams_logo_color.sql` — `teams.logo_color text` (hex #RRGGBB, nullable)
- 공통 렌더 위젯 `shared/widgets/team_logo_view.dart` — `logoUrl` 있으면 네트워크 이미지, 없으면 이니셜 + `logoColor` 배경. 배경 밝기 기준 흰/검정 텍스트 자동 선택. `kTeamLogoPalette` 8색 정의
- 편집 시트 `team_logo_edit_sheet.dart` — 탭 2개(`자동 로고` 활성, `사진 업로드` 비활성)
- 팀 탭 톱니 → 설정 시트 → 로고 수정 진입

**트레이드오프**: 디폴트 색이 null 이면 앱에서 `AppColors.primary` 로 폴백. 파랑 일변도 방지 위해 온보딩 시 팔레트 첫 색으로 암묵 지정되는 선택권 고려 가능하지만 현재는 유저 선택까지 null 유지.

## 008. 팀 생성 풀스크린 + 팀 소개 필드 추가

**결정**: 바텀시트 대신 풀스크린 라우트(`/team/create`)로 통일. 입력 3종(팀 이름, 로고 색상, 팀 소개). 온보딩의 기존 `_CreateTeamView` 인라인 flow(초대 코드 다이얼로그 + 로고 꾸미기 CTA) 제거하고 이 화면으로 단일화.

**이유**:
- 바텀시트는 폼 3개 수용하기엔 좁음. 풀스크린이 모바일 폼 입력에 적합
- 온보딩/팀탭/팀 스위처 3개 진입점이 동일한 풀스크린 UX 공유 → 중복 코드 제거 (~285줄)
- 팀 소개는 선택이지만 여러 팀 가진 유저에게 식별 단서 제공 (팀 스위처에 부제로 노출)

**구현**:
- 마이그레이션 `20260414020000_teams_description.sql` — `teams.description text`
- 화면: `lib/features/team/presentation/team_create_screen.dart` — 이름 입력 → 실시간 이니셜 프리뷰 → 색상 팔레트 탭 → 소개 (max 200자)
- 라우트: `GoRoute(/team/create)` → 저장 성공 시 `context.go('/')` 로 홈 교체
- 진입점: 팀탭 톱니(팀 없을 때), 설정 시트 "새 팀 만들기", 홈 팀 스위처 "새 팀 만들기", 온보딩 "새 팀 만들기"

**트레이드오프**: `context.go('/')` 는 네비 스택 교체 — 팀탭 내부 위치 컨텍스트 손실. 이 기능은 팀 자체가 바뀌는 큰 이벤트라 홈에서 다시 시작이 자연스럽다고 판단.

## 009. 팀 탈퇴 규칙: 마지막 admin 보호 (TDD)

**결정**: 팀 탈퇴 기능 추가. 마지막 admin 이고 다른 멤버가 남아있을 때 `LastAdminException` 으로 차단. 혼자 남은 admin 은 탈퇴 가능(팀은 빈 상태로 남음). TDD 로 서비스 로직 먼저 작성.

**이유**:
- 팀 운영자가 사라지면 남은 멤버가 admin 권한을 얻을 경로가 없어 팀이 잠김 → 선제 차단
- 혼자 있는 팀은 admin 이 나가도 피해자 없음 → 허용
- 일반 멤버/용병은 언제든 탈퇴 허용 (가입 자유 원칙)

**구현**:
- 테스트 `test/service/team_service_test.dart` — 6 케이스(일반/용병/다중 admin/마지막 admin 차단/혼자 admin/비소속)
- Repo: `TeamRepo.leave()` + `SupabaseTeamRepo` — `.delete().eq().select()` 로 0 rows 감지해 `StateError`
- Service: `TeamService.leaveTeam()` — 멤버 목록에서 admin 카운트 검사 → 조건 만족 시 `LastAdminException`
- UI: 팀 설정 시트에 빨간색 "팀 탈퇴" 액션 → 확인 다이얼로그 → 성공 시 `myTeamsProvider`/`currentTeamProvider` 무효화
- DB RLS 는 기존 `team_members_delete` 정책이 이미 `player_id = auth.uid()` 본인 탈퇴 허용 → 추가 마이그레이션 없음

**트레이드오프**: "팀 자동 삭제" 는 구현하지 않음. 마지막 멤버 탈퇴 후 빈 팀은 DB 에 남음. 정리가 필요해지면 크론이나 `teams_delete` 정책 + UI 액션으로 별도 처리.

## 010. 활성 팀 전환: `players.active_team_id` (TDD)

**결정**: 한 유저가 여러 팀에 소속됐을 때 "현재 보고 있는 팀" 을 `players.active_team_id` 컬럼으로 DB 에 저장. 홈 상단 팀 로고 탭 → 팀 스위처 시트 → 선택 시 DB 업데이트. TDD 로 서비스 먼저.

**이유**:
- 기존 `currentTeamProvider` 는 `teams.first` 하드코딩 → 유저가 어느 팀을 보는지 선택 불가
- 기기 간 동기화 필요 (`shared_preferences` 대신 DB) — 다른 기기에서 같은 팀 계속 유지
- `on delete set null` 로 팀 삭제 시 참조 무결성 보장 (NULL 이면 `teams.first` 폴백)

**구현**:
- 마이그레이션 `20260414030000_players_active_team.sql` — `players.active_team_id uuid references teams(id) on delete set null`. 기존 `players_update_own` RLS 로 본인만 갱신 가능
- 테스트: `switchTeam` 3 케이스(소속 팀 성공/미소속 `NotAMemberException`/동일 팀 no-op)
- Repo: `PlayerRepo.setActiveTeam` / `getActiveTeamId` 추가, `SupabasePlayerRepo` 구현
- Service: `TeamService.switchTeam` — 소속 검증 → `NotAMemberException` 또는 `playerRepo.setActiveTeam`
- Provider: `currentTeamProvider` 재작성 — `active_team_id` 우선 조회, 해당 팀이 현재 내 팀 목록에 없으면(탈퇴/삭제) `teams.first` 폴백
- UI: `_TeamSwitcherSheet` 가 `myTeamsProvider` 구독, 선택 시 `switchTeam` → 관련 provider 무효화

**트레이드오프**: 기기 간 실시간 동기화는 폴링/realtime 구독 없이 "다음 조회 시점" 까지 지연. 앱 foreground 전환 시 강제 refresh 추가 고려 가능. 현재는 수동 새로고침 수준.

## 011. 팀 로고 업로드: Supabase Storage `team-logos` 버킷

**결정**: 결정 007 에서 보류했던 업로드(A) 경로 활성화. Supabase Storage `team-logos` public 버킷 사용. 경로 `{team_id}/logo_{ts}.{ext}`, 최대 2MB, `image/jpeg|png|webp` 만 허용. RLS 로 읽기 public, 쓰기/수정/삭제는 해당 팀 admin 만.

**이유**:
- 팀 아이덴티티 강화. 이니셜 로고는 fallback 성격이고 실제 엠블럼이 있는 팀도 많음
- Supabase Storage 가 이미 인증 세션과 통합되어 있어 별도 S3/CDN 불필요
- `image_picker` 만으로 크롭 없이 `maxWidth/maxHeight/imageQuality` 로 용량 제어 — 외부 크롭 패키지 의존 없이 가볍게

**구현**:
- 마이그레이션 `20260414040000_team_logos_bucket.sql`:
  - `storage.buckets` insert (`team-logos`, public, 2MB, jpeg/png/webp)
  - `storage.objects` 에 4개 RLS 정책 (public read, admin insert/update/delete — path 첫 폴더를 `team_id::text` 로 해석)
- 패키지: `image_picker: ^1.1.2`
- Repo: `TeamRepo.uploadLogo(teamId, bytes, extension)` → Storage 에 업로드하고 public URL 반환
- UI:
  - `team_create_screen.dart`: 로고 탭 시 "갤러리 / 색상 / (사진 제거)" 3옵션 시트. 선택된 사진 bytes 보관 → create 후 업로드 → `updateInfo(logoUrl)`. 업로드 실패해도 팀은 생존(색상 fallback)
  - `team_logo_edit_sheet.dart` 재작성: 기존 팀은 teamId 가 있으므로 사진 선택 즉시 업로드 가능한 구조. "사진" / "사진 제거" 칩 + 팔레트 + 저장
- iOS: `NSPhotoLibraryUsageDescription` 추가
- Android: `image_picker` 가 Android 13+ Photo Picker 를 자동 사용 → 추가 퍼미션 불필요

**트레이드오프**:
- 크롭 UI 없이 `maxWidth: 512` 리사이즈만 → 긴 사진은 `BoxFit.cover` 시점에서 중앙 크롭으로 보임. 원본 비율이 극단적이면 어색할 수 있음
- 버킷 public read → URL 만 알면 누구나 이미지 접근 가능. 팀 로고는 공개 정보라 허용
- 구 로고 파일 자동 삭제 안 함 — 경로가 타임스탬프로 다르므로 업데이트 시 과거 파일이 스토리지에 남음. 추후 정리 크론 또는 upload 시 기존 파일 일괄 삭제 로직 고려
