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
| 012 | 2026-04-14 | 채팅 스키마 + 팀 ↔ 방 자동 동기화 트리거 | 확정 |
| 013 | 2026-04-14 | RLS 무한 재귀 해결: SECURITY DEFINER 헬퍼 | 확정 |
| 014 | 2026-04-14 | 방 목록 N+1 제거: RPC 집계 + DM advisory lock | 확정 |
| 015 | 2026-04-15 | 기본 팀 로고: OpponentLogo(방패+이니셜)로 통합 | 확정 |
| 016 | 2026-04-15 | 선수 아바타 업로드: `player-avatars` 버킷 | 확정 |

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

## 012. 채팅 스키마 + 팀 ↔ 방 자동 동기화 트리거

**결정**: 채팅 도메인 세 테이블(`chat_rooms`, `chat_room_members`, `chat_messages`)
을 도입. 팀 단체방의 생성/가입/탈퇴를 앱 레이어가 아닌 DB 트리거로 자동 동기화.
방 종류는 `type in ('team', 'direct')` 두 가지. 팀당 단체방은 정확히 1개
(`unique (team_id)` + CHECK `chat_rooms_type_integrity`).

**이유**:
- 앱이 `team_members` insert 직후 별도 rooms insert 를 호출하는 방식은
  RPC 초대, RLS 우회 경로, 백필 시나리오에서 누락 위험 → DB 에서 단일화
- `on delete cascade` 와 조합해 팀/멤버 라이프사이클이 채팅 데이터까지 그대로 전파
- 단체방 이름은 `teams.name` 을 복제해 보관 — 팀명 rename 시 `sync_team_chat_room_name`
  트리거가 즉시 반영하므로 조회 1회에 방이름 포함

**구현**:
- 마이그레이션 `20260414050000_chat.sql`:
  - 테이블 3개 + 인덱스 (`room_id, created_at desc` 등)
  - 트리거 4종:
    - `on_team_created_create_chat_room` — 팀 insert → 방 insert
    - `on_team_renamed_sync_chat_room_name` — 팀명 update → 방이름 update
    - `on_team_member_added_join_chat_room` — 멤버 insert → 방 참여
    - `on_team_member_removed_leave_chat_room` — 멤버 delete → 방 탈퇴
  - 기존 팀/멤버에 대한 백필 쿼리(중복 insert 는 `on conflict do nothing`)
  - `get_or_create_direct_room(p_other)` RPC (DM 생성/재사용)
  - `chat_messages`/`chat_room_members` 를 `supabase_realtime` publication 에 등록

**트레이드오프**:
- 트리거는 비가시적이라 신규 기여자가 "왜 방이 저절로 생기지?" 혼란 가능 → 이 ADR
  + `20260414050000_chat.sql` 주석으로 문서화
- 단체방당 1개 제약이라 "여러 주제 채널" 같은 확장은 별도 `channels` 테이블이 필요

## 013. RLS 무한 재귀 해결: SECURITY DEFINER 헬퍼

**결정**: `chat_rooms_select` / `chat_room_members_select` / `chat_messages_select`
정책이 모두 `chat_room_members` 에 대한 서브쿼리로 멤버십을 확인하도록
작성됐는데, `chat_room_members_select` 가 자기 자신을 참조해 PostgreSQL 이
`infinite recursion detected in policy for relation 'chat_room_members'`
(`42P17`) 로 거절. 헬퍼 함수 `public.is_chat_room_member(uuid)` 를
`SECURITY DEFINER STABLE` 로 정의해 RLS 를 우회하고, 네 정책을 모두
이 함수 한 번 호출로 재작성.

**이유**:
- Supabase 공식 권장 패턴. DEFINER 로 RLS 를 끊어 재귀를 구조적으로 해결
- 함수 인자가 `room_id` 단일, 내부에서 `auth.uid()` 로 본인 행만 검사 →
  권한 확장/우회 위험 없음
- 정책을 헬퍼 호출 1줄로 통일 → 가독성 + 유지보수성 상승

**구현**:
- 마이그레이션 `20260414060000_chat_rls_fix.sql` — 재귀 정책 4종 `drop policy if exists`
  후, 헬퍼 + 정책 재작성
- 헬퍼는 `search_path = ''` 로 고정해 스키마 하이재킹 방지
- `chat_messages_insert` 도 `sender_id = auth.uid() and public.is_chat_room_member(room_id)`
  조합으로 재작성

**트레이드오프**:
- DEFINER 함수는 소유자 권한으로 실행되므로 정의/수정 시 코드리뷰 필수.
  현재는 단순 `exists` 만 반환하므로 공격 표면 없음

## 014. 방 목록 N+1 제거: RPC 집계 + DM advisory lock

**결정**: `ChatRepo.getMyRooms` 구현이 방 개수 N 에 대해 `memberCount` N회,
`unreadCount` N회, DM peer 이름 K회 로 `2 + 2N + K` round-trip 발생. 이를
서버 RPC `get_my_chat_rooms()` 한 번으로 집계해 **1 round-trip**. 함께
DM 방 중복 생성 레이스(동시 `SELECT` 두 번이 모두 null → 둘 다 INSERT)
는 `pg_advisory_xact_lock(hashtextextended(정렬쌍))` 으로 차단.
`ChatRepo` 인터페이스에서 `findDirectRoom` / `createDirectRoom` /
`shareTeam` 세 메서드를 제거하고 `getOrCreateDirectRoom` 하나로 통합
(서버 RPC 가 팀원 검증/락/생성 전부 책임).

**이유**:
- 방 10개·DM 3 기준 26 RT → 1 RT. 3G 환경에서 체감 2초 → 80ms
- 클라이언트 로직이 서버 RPC 로 이동 → Dart 단순화 + 트랜잭션 원자성 확보
- Advisory lock 은 트랜잭션 스코프라 교착 위험 없음. 정렬쌍 해시로 순서 무관하게 동일 키

**구현**:
- 마이그레이션 `20260414070000_chat_perf.sql`:
  - `get_my_chat_rooms()` returns table — `with me`, `my_rooms`, `last_msg`
    (`distinct on (room_id)`), `member_cnt`, `unread_cnt`, `dm_peer` CTE 합성
  - `share_team_with(uuid)` returns boolean
  - `get_or_create_direct_room(uuid)` 재정의 — advisory lock 획득 후
    재조회 → 없으면 insert. `chat_rooms` insert 와 양쪽 `chat_room_members`
    insert 를 단일 트랜잭션으로 원자화
- 후속 마이그레이션 `20260415000000_chat_logo.sql`:
  - 방 목록 RPC 에 `team_logo_url` / `team_logo_color` 컬럼 추가
    (셀이 팀 로고 이미지를 한 번에 받도록)
- 클라이언트: `ChatRepo.getMyRooms` 는 `rpc('get_my_chat_rooms')` 반환
  JSON 을 `ChatRoom` 으로 매핑
- `SupabaseChatRepo` 는 `_senderCache: Map<String, Map<String, String?>>` 를
  repo 내부에 유지해 realtime stream 에서 sender 조회 N+1 을 1회로 축소
- `subscribeMessages` 는 `.order desc .limit(1)` 로 최신 1행만 관찰.
  초기 로드(`getMessages`) 와 경합 방지 + 불필요한 과거 tuple 재방출 제거

**트레이드오프**:
- RPC 하나로 쿼리가 길어져 초기 디버깅 난이도는 소폭 증가. 각 CTE 별 주석으로 완화
- Advisory lock 키가 `hashtextextended` 이므로 64비트 해시 충돌 이론적으로 가능
  (실질 0에 수렴). 충돌해도 최악 직렬화 한 트랜잭션 더 대기일 뿐
- `PostgrestException.message.contains('Not a teammate')` 문자열 매칭으로
  `NotTeammateException` 변환 — 서버 예외 메시지 변경 시 동기화 필요

## 015. 기본 팀 로고: OpponentLogo(방패+이니셜)로 통합

**결정**: 팀 로고 렌더 공용 위젯 `TeamLogoView` 의 업로드 없는 fallback 을,
기존 `logoColor` 배경 원/사각 + 이니셜 에서, 상대팀과 동일한
`defaultteamlogo.png`(방패 SVG→PNG) + 이니셜 오버레이 (`OpponentLogo`) 로 변경.
업로드된 `logo_url` 이 있으면 그 이미지 그대로. 홈 헤더의 로고 클립은
원형(`BorderRadius.circular(16)`) → `AppRadius.smoothSm` 로 바꿔 방패 윤곽이
잘리지 않게 함.

**이유**:
- 업로드 없는 팀과 상대팀이 완전히 다른 비주얼이었음 → 한 화면에 섞이면
  (예: 경기 카드의 우리팀 vs 상대팀) 이질감. 두 로고 시스템 통합이 일관성 측면에서 분명한 개선
- 방패 모양 자체가 "스포츠 엠블럼" 느낌을 전달 → 컬러 원보다 팀 정체성에 가깝다
- 기존 `OpponentLogo` 의 한글 초성→영문 이니셜 매핑 로직을 그대로 재사용

**구현**:
- `shared/widgets/team_logo_view.dart`:
  - `_buildMonogram` 제거 → `_buildDefault` 가 `OpponentLogo(teamName, size, borderRadius, ...)` 위임
  - `_pickForeground` 삭제 (더 이상 배경색 밝기 기반 text color 선택 불필요)
- `features/home/presentation/home_tab.dart`: 좌상단 `TeamLogoView` 의
  borderRadius 를 원형에서 `AppRadius.smoothSm` 로 변경 — 방패 모양 유지
- `features/chat/presentation/widgets/chat_room_cell.dart`: 방 목록 셀의 로고
  렌더 우선순위를 (logoUrl → logoPath → logoColor+이니셜 원형) 로 재정의.
  `logoColor` 는 해시 기반 폴백 색상과 병용. `_parseHex` 헬퍼 추가

**트레이드오프**:
- `TeamLogoPaletteGrid` 와 `teams.logo_color` 의 시각적 영향이 줄어듦 —
  팔레트는 이제 "업로드 이미지 없는 팀의 이니셜/주변 색조 튜닝" 용도로만
  남음. 팀 생성 UI 의 팔레트 스텝 UX 는 향후 재검토 여지
- 방패 PNG 의 중앙 이니셜 폰트 대비/그림자 문제는 `OpponentLogo` 쪽 스타일로만
  조정 가능. 크기/회색 제약 있어 이니셜 가독성이 팀명에 따라 다를 수 있음

## 016. 선수 아바타 업로드: `player-avatars` 버킷

**결정**: 프로필 편집 화면에서 갤러리 이미지 선택 → Supabase Storage 업로드 →
`players.avatar_url` 갱신. 버킷 `player-avatars` 는 public read, 쓰기/수정/삭제
는 본인 폴더(`{playerId}/`) 에만 허용 (RLS). 경로 규칙 `{playerId}/avatar_{ts}.{ext}`,
허용 확장자 jpeg/png/webp, 최대 2MB.

**이유**:
- 팀 내 식별성 핵심 자산. 업로드 없으면 멤버 목록/채팅 DM/홈 헤더 전부 이니셜
  원만 보여 매우 flat. 아바타가 실제 얼굴일 때 팀 분위기가 살아남
- 팀 로고 업로드(결정 011) 가 이미 비슷한 패턴을 검증 — Storage 버킷 + RLS +
  `image_picker` 리사이즈(512px) + `Repo.upload*` 메서드. 아바타도 같은 패턴 복제
- public read 허용은 위험도 낮음 (팀 로고와 동일). URL 추측 불가 수준의 경로
  (`{uuid}/avatar_{epoch_ms}.ext`) + `players.avatar_url` 이 이미 공개 정보

**구현**:
- 마이그레이션 `20260415010000_player_avatars_bucket.sql`:
  - `storage.buckets` insert — public, 2MB, mime 3종
  - `storage.objects` RLS 4종: select 공개 / insert·update·delete 는
    `(storage.foldername(name))[1] = auth.uid()::text`
- Repo: `ProfileRepo.uploadAvatar({playerId, bytes, extension})` 인터페이스 +
  `SupabaseProfileRepo` 구현 — `uploadBinary` + public URL 반환.
  기존 `update()` 가 이미 `avatarUrl` 을 받으므로 uploadAvatar 결과를 바로
  연결
- UI: `features/profile/presentation/profile_screen.dart`:
  - `_EditProfileScreen` → `ConsumerStatefulWidget`
  - `_pickedAvatarBytes` / `_pickedAvatarExt` 상태
  - `_pickAvatar()` 가 `pickTeamLogoImage(context)` 재사용 (512px, 품질 85,
    jpeg/png/webp 확장자 정리)
  - 프리뷰: 선택된 bytes → `Image.memory`, 없으면 기존 asset
  - `_save()` 가 업로드 → `profileRepo.update(avatarUrl)` → pop. 로딩 스피너 +
    실패 시 SnackBar

**트레이드오프**:
- 크롭 UI 없이 `maxWidth: 512` 리사이즈만 → 세로 긴 사진은 원형 crop 시
  중앙 위주로 잘림. 얼굴 위치가 중앙이 아니면 어색
- 구 아바타 파일 자동 삭제 없음 (팀 로고와 동일 이슈). 스토리지 정리
  크론 또는 upsert 시 이전 파일 삭제 로직은 향후
- 이름/등번호/포지션/발/키 등 나머지 프로필 필드 저장은 이번 변경 scope 밖
  (피커/업로드만 실제 연결, 텍스트 필드는 여전히 pop)
