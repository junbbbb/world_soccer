# 2026-04-15 — 팀 탭 실데이터 연결 + 기본 로고 통합 + 프로필 아바타 업로드

시작: 2026-04-15
상태: 완료

오전 세션에서 채팅 시스템 마무리(`20260415-chat-feature.md`) 후,
오후에 데이터/UI 통합과 프로필 이미지 업로드까지 완료.
결정 015~016 묶음.

## 변경 요약 (사용자 관점)

### Before → After

**홈 좌상단 팀 로고**
- Before: 업로드 없을 때 logoColor 배경 원형 + 알파벳
- After: 업로드 없을 때 상대팀과 동일한 "방패 + 이니셜" (`defaultteamlogo.png` + OpponentLogo)
  업로드 사진 있으면 그 사진 그대로. 방패 모양 잘리지 않도록 클립도 원형→smoothSm 사각

**채팅 방 목록 셀**
- Before: 원형 컬러 + 이니셜 fallback
- After: 업로드된 `teams.logo_url` 이미지. 없을 때 `logoColor`(hex) 또는 해시 기반 색상 위에 이니셜

**홈 "결과 입력" 카드 여백**
- Before: 카드가 조건부로 숨겨져도 위·아래 SizedBox 가 그대로 남아서 48px 공백
- After: 카드 자체가 null 이면 주변 spacing 까지 함께 제거

**경기 탭**
- Before: SegmentControl(실제 모드만) + 월 네비 (더미 전용)
- After: **예정 / 종료 TabBar + TabBarView** (팀 탭과 동일 스타일). 월 네비 제거

**팀 탭/경기 탭 TabBar 왼쪽 여백**
- Before: labelPadding base(16) 로 시작 → 페이지 edge lg(20) 와 4px 차이
- After: TabBar 를 `EdgeInsets.only(left: AppSpacing.xs)` 로 감싸 20px 에서 시작

**팀 탭 3개 탭 — 실데이터**
- Before: `showDummy=false` 면 전부 "데이터가 없습니다" 만 뜸
- After:
  - 오버뷰: 실제 팀 로고·이름·설명·창단년도·멤버 수·초대 시트·팀 기록(통산 전적 + 승률)
  - 팀 스탯: `TeamStats`(승/무/패, 득점/실점/평균, 클린시트) + `season_player_stats` view 기반 득점/어시스트 랭킹
  - 멤버: 포지션별 그룹핑(GK/DF/MF/FW/기타), 아바타·이름·등번호·포지션 표시

**팀 탭 아바타**
- Before: `ClipRRect(smoothSm)` — 둥근 사각형
- After: `ClipOval` — 완전한 원. fallback 이니셜 박스도 `BoxShape.circle`

**프로필 편집 — 이미지 선택**
- Before: 프로필 이미지 탭 시 "이미지 변경 (준비중)" SnackBar. 저장 버튼은 pop 만
- After: 갤러리에서 사진 선택 → 즉시 프리뷰 → 저장 시 Supabase Storage 업로드 후
  `players.avatar_url` 갱신 → 전 앱(홈 프로필 아이콘, 멤버 목록, 채팅 DM 상대 아바타 등) 자동 반영

**프로필 "최근 경기 기록"**
- Before: 각 행이 회색 박스 + 그 안에 흰색 "x골x도움" 박스
- After: 행 배경·radius 제거(구분선 없이 세로 패딩만). "x골x도움" 박스만 회색(`surfaceLight`) pill

## DB 변경

| 마이그레이션 | 내용 |
|------|------|
| `20260415000000_chat_logo.sql` | `get_my_chat_rooms` RPC 에 `team_logo_url` / `team_logo_color` 추가 (방 목록 셀에서 팀 로고 이미지 렌더) |
| `20260415010000_player_avatars_bucket.sql` | Storage 버킷 `player-avatars` + RLS (public read, 본인 폴더 write/update/delete) |

## 코드 변경

### Layer 2 — Repo
| 파일 | 변경 |
|---|---|
| `repo/profile_repo.dart` | `uploadAvatar({playerId, bytes, extension})` 인터페이스 추가 |
| `repo/supabase_profile_repo.dart` | `uploadAvatar` 구현: `{playerId}/avatar_{ts}.{ext}` 경로, content-type 매핑, public URL 반환 |

### Layer 4 — Runtime Providers
| Provider | 용도 |
|---|---|
| `teamStatsByTeam(teamId)` | `TeamRepo.getStats` — 팀 전적 |
| `teamGoalRanking(teamId)` | `StatsRepo.getTeamRanking(RankType.goals)` |
| `teamAssistRanking(teamId)` | `StatsRepo.getTeamRanking(RankType.assists)` |

### Layer 5 — UI

**공용**
- `shared/widgets/team_logo_view.dart`: fallback monogram 로직 제거 → `OpponentLogo` 위임.
  `_buildMonogram`/`_pickForeground` 삭제. `parseLogoHex`/`kTeamLogoPalette`/
  `TeamLogoPaletteGrid` 는 팀 생성 UI 에서 여전히 쓰이므로 유지

**홈**
- `features/home/presentation/home_tab.dart`:
  - 좌상단 `TeamLogoView` borderRadius: `BorderRadius.circular(16)`(원) → `AppRadius.smoothSm`
  - 결과입력 카드를 `_buildResultPromptCard()` 헬퍼로 분리 (null 반환 시 카드 미렌더).
    Column 에서 `if (resultPromptCard != null) ...[SizedBox(base), card]` 로 주변 spacing
    도 함께 조건부
  - `_animatedPrompt()` 로 AnimatedSlide/Opacity DRY 화

**경기**
- `features/match/presentation/match_tab.dart`: SegmentControl + 월 네비 제거 →
  TabController(length: 2) + TabBar(예정/종료) + TabBarView. 리스트 렌더를
  `_MatchListView` 로 추출해 양 탭이 카드 렌더 재사용.
- 헤더 TabBar 에 `Padding(left: AppSpacing.xs)` 추가 (페이지 edge 와 정렬)

**팀**
- `features/team/presentation/team_tab.dart`:
  - 더미 상수/모델(`_teamInfo`, `_teamStats`, `_topScorers`, `_topAssisters`,
    `_dummyMembers`, `_Member`, `_TeamInfo`) 전부 제거
  - TabBarView 의 `showDummy` 분기 삭제
  - `_OverviewView`/`_TeamStatsView`/`_MembersView` 를 `ConsumerWidget`
    기반으로 재작성
  - `_TeamInfoSection(team: Team)`: 로고·이름·설명·창단년도·실제 멤버 수
  - `_TeamSummarySection(teamId)`: 통산 전적(승/무/패) + 승률 %
  - `_TeamStatsView`: 실제 `TeamStats` + 랭킹 2종. 데이터 없으면
    "기록된 득점/어시스트가 없습니다"
  - `_MembersView`: `teamMembersByTeamProvider` + 포지션 그룹핑.
    초대 버튼 상단. 0명이면 "아직 멤버가 없습니다"
  - `_playerAvatar(url, name, size)` 헬퍼: URL 있으면 `ClipOval(Image.network)`,
    없으면 회색 원 + 이니셜. asset path 도 `Image.asset` 로 분기. 에러는 fallback
  - TabBar 에 `Padding(left: AppSpacing.xs)` 추가
- `features/team/presentation/team_tab.dart` `_TeamLogoView` fallback 이
  이제 방패+이니셜이므로 오버뷰 배너도 자동으로 동일 스타일

**채팅**
- `features/chat/presentation/widgets/chat_room_cell.dart`: `logoUrl` 이미지 우선,
  실패 시 `logoColor` 기반 이니셜 원 fallback 로 변경 (`_fallbackInitial` 헬퍼,
  `_parseHex`)

**프로필**
- `features/profile/presentation/profile_screen.dart`:
  - `_EditProfileScreen` → `ConsumerStatefulWidget`
  - `_pickedAvatarBytes` / `_pickedAvatarExt` 상태. `_pickAvatar()` 가
    `pickTeamLogoImage(context)` 재사용 (512px 리사이즈 + 품질 85)
  - 프로필 이미지 프리뷰: 선택된 bytes 있으면 `Image.memory`, 없으면 기존 asset
  - 저장 버튼 `_save()`: 이미지 선택된 경우 `profileRepo.uploadAvatar` →
    `profileRepo.update(avatarUrl: url)` → pop. 실패 시 SnackBar. 저장 중 로딩
    스피너
  - "최근 경기 기록" 각 행의 회색 배경·radius 제거, 골/도움 박스를 흰색→
    `surfaceLight` 회색 pill 로 반전

## 단계

- [x] 프로필 "최근 경기 기록" 행 배경 제거 + 골/도움 회색 pill
- [x] `TeamLogoView` fallback → `OpponentLogo`(방패+이니셜) 위임
- [x] 홈 좌상단 팀 로고 원형 → smoothSm (방패 모양 유지)
- [x] 홈 결과입력 카드 여백 조건부 렌더 리팩토링
- [x] 경기 탭 예정/종료 TabBar 전환
- [x] 팀/경기 TabBar 왼쪽 여백 정렬 (AppSpacing.xs)
- [x] 팀 탭 3개 탭 실데이터 연결 (오버뷰/팀스탯/멤버)
- [x] 팀 탭 랭킹/멤버 아바타 원형화
- [x] `player-avatars` 버킷 + `ProfileRepo.uploadAvatar` 추가
- [x] 프로필 편집 이미지 피커 연결 + 저장 시 업로드
- [x] `flutter analyze` 에러 0 확인, 채팅 테스트 12/12 통과

## 핵심 파일

| Layer | 파일 |
|------|------|
| repo | `lib/repo/profile_repo.dart` (uploadAvatar 인터페이스) |
| repo | `lib/repo/supabase_profile_repo.dart` (Storage 업로드 구현) |
| runtime | `lib/runtime/providers.dart` (teamStatsByTeam, teamGoalRanking, teamAssistRanking) |
| ui-shared | `lib/shared/widgets/team_logo_view.dart` (기본 로고 OpponentLogo 위임) |
| ui-home | `lib/features/home/presentation/home_tab.dart` (여백 리팩토링, 로고 클립 변경) |
| ui-match | `lib/features/match/presentation/match_tab.dart` (TabBar 예정/종료) |
| ui-team | `lib/features/team/presentation/team_tab.dart` (전체 실데이터 + 원형 아바타) |
| ui-chat | `lib/features/chat/presentation/widgets/chat_room_cell.dart` (팀 로고 표시) |
| ui-profile | `lib/features/profile/presentation/profile_screen.dart` (편집 이미지 피커) |
| db | `supabase/migrations/20260415000000_chat_logo.sql` |
| db | `supabase/migrations/20260415010000_player_avatars_bucket.sql` |

## 메모

- `pickTeamLogoImage()` 는 이름이 팀 로고 특정처럼 보이지만 범용 이미지 피커 유틸
  이라 프로필 아바타에도 그대로 재사용 (향후 `pickImage` 로 개명 가능)
- `TeamLogoView` 가 fallback 을 `OpponentLogo` 에 위임하므로 `TeamLogoPaletteGrid`
  로 고른 `logoColor` 는 이제 **업로드 이미지 없는 팀의 이니셜 색상 튜닝**
  의미만 남음. 팀 생성 UI 는 여전히 팔레트를 쓰지만 시각적 영향이 줄어든 상태 —
  향후 팔레트 UX 재검토 여지
- 프로필 편집의 이름/등번호/포지션/주발/키 필드는 여전히 더미 저장
  (pop 만). 아바타만 실제 저장. 나머지 필드 저장은 다음 작업으로 남김
- 프로필 "최근 경기 기록" 의 데이터는 더미. 실제 `RecentPerformance` 연결은
  별도 진행
