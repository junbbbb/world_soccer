# 2026-04-15 오후 ~ 저녁 — 프로필 실데이터 완성 + 뱃지·공유·크롭·자동참가

시작: 2026-04-15 오후
상태: 완료

`20260415-team-ui-data-and-avatar.md` 이후, 프로필 화면의 남은 더미를 모두
DB 연동으로 전환하고, 뱃지(득점왕/어시왕/출석왕/MOM왕), 공유, 인스타식 크롭,
홈 참가 버튼 자동참가까지 한 번에. 결정 017~019.

## 변경 요약 (사용자 관점)

### 프로필 카드
**Before**: 이름/팀/포지션/경기수/골/어시/MOM/뱃지 모두 하드코딩 더미.
**After**: 현재 로그인 유저 + 활성 팀 + 현재 반기 기준 실데이터 렌더.
뱃지는 팀 내 1등 카테고리만 표시 (최소 3경기, 공동 1위 허용).

### 프로필 편집
**Before**: 아바타 업로드만 실제 저장. 이름/번호/포지션/발/키는 pop 만.
**After**: **전 필드 Supabase 에 저장**. 저장 후 프로필카드 즉시 반영.
초기값은 현재 player 에서 로드 (더미 'CM'/'오른발' 제거).

### 최근 경기 기록
**Before**: 하드코딩 5건.
**After**: `player_match_stats` + `matches` 조회 5건 (팀 필터).
상대팀 로고는 `TeamLogoView.byName` (URL 있으면 네트워크, 없으면 방패+이니셜).

### 프로필카드 공유
**Before**: 공유 아이콘 → "준비중" SnackBar.
**After**: `RepaintBoundary + ui.Image.toByteData` 캡처 → `Share.shareXFiles`
(system share sheet). 카톡/메시지/SNS 등으로 PNG 전송 가능.
캡처 중 아이콘이 스피너로 전환.

### 프로필 아바타 업로드 — 인스타식 크롭
**Before**: 갤러리 픽 → 정사각 리사이즈(512, 품질 85) → 원형 ClipOval.
**After**: 갤러리 픽(1500 max, 품질 92) → **크롭 스크린** → 업로드.
- 320x320 고정 크롭 박스, InteractiveViewer 로 드래그/핀치
- **사각 테두리 + 인스크립트 원** 가이드 동시 표시 → 프로필카드(사각) 와
  다른 화면(원형) 어디에 무엇이 보일지 예측 가능
- 3분할 가이드 라인
- 완료 시 RepaintBoundary 로 PNG 반환 (pixelRatio 3 = ~960x960)

### 프로필카드 아바타 모양
**Before**: 160×160 **원형**(ClipOval) + 기본 이미지 fallback 은 220 풀샷.
**After**: 업로드 이미지 220×220 **사각형**(ClipRRect + smoothMd) — 크롭한
전체 영역 노출. 업로드 없으면 기본 풀샷 유지. 다른 화면(멤버 목록, 채팅,
DM 등) 은 그대로 원형.

### 선호 포지션 표시
**Before**: 3개 이상 시 Text 오버플로로 "+" 같은 truncation 발생.
**After**: `CM, AM +3` 포맷 (`_positionsText`).

### 홈 "참가하기" 버튼
**Before**: 탭 → 바텀시트에서 포지션/쿼터 선택, **DB 저장 없이 로컬
_isJoined 만 토글** (dummy UI).
**After**:
- **짧게 탭** → 프로필 선호 포지션 + 전 쿼터로 `MatchService.joinMatch`
  즉시 호출 (하단 시트 안 뜸)
- **길게 누름** → 기존 바텀시트 (커스텀 포지션/쿼터)
- **이미 참가** 상태에서 짧게 탭 → `leaveMatch` 로 참가 취소
- 프로필에 선호 포지션 없으면 "프로필에서 선호 포지션을 먼저 설정해주세요"
  SnackBar
- `_busy` 가드로 중복 호출 차단
- 시트의 쿼터 representation 도 1-indexed 로 통일 (기존엔 0~3 내부 + `q+1`
  변환 외부 → 현재 1~4 동일)

## DB 변경

| 마이그레이션 | 내용 |
|---|---|
| `20260415020000_player_titles.sql` | RPC `get_player_titles(player_id, team_id, year, half)` — 4개 카테고리 1등 판정. 최소 3경기, 공동 1위 포함. CTE 1회. |

`update()` 의 RLS 실패 감지를 위해 `SupabaseProfileRepo.update` 에
`.select('id')` + empty check 추가 (0 rows 업데이트 시 StateError 로 surface).

## 코드 변경 — 레이어별

### Layer 0 — Types
| 파일 | 변경 |
|---|---|
| `types/enums.dart` | `PlayerTitle` enum (득점왕/어시왕/출석왕/MOM왕, `fromLabel`). `Position.fromLabel`, `PreferredFoot.fromLabel` static helper 추가. |
| `types/match.dart` | `JoinMatchResult.availableQuarters` 1-indexed 명시 (주석). |

### Layer 2 — Repo
| 파일 | 변경 |
|---|---|
| `repo/stats_repo.dart` | `getPlayerTitles(playerId, teamId, year, half)` 인터페이스. |
| `repo/supabase_stats_repo.dart` | RPC 호출 구현. SeasonHalf → 'H1'/'H2' 매핑. |
| `repo/supabase_profile_repo.dart` | `update()` 에 `.select('id')` + `result.isEmpty` 검증. RLS 실패 시 StateError. |
| `repo/supabase_player_repo.dart` | `Position.fromLabel` / `PreferredFoot.fromLabel` 재사용 — 기존 `firstWhere(orElse: cm)` 폴백 제거, 알 수 없는 라벨은 drop. |

### Layer 4 — Runtime
| Provider | 용도 |
|---|---|
| `currentPlayer` | 현재 로그인 유저의 `Player` |
| `currentSeasonHalf()` 헬퍼 | 오늘 날짜 → `(year, half)` |
| `currentSeasonStats` | 현 유저·현 팀·현 반기 시즌 스탯 |
| `currentPlayerTitles` | 현 유저·현 팀·현 반기 뱃지 목록 |
| `currentRecentPerformances` | 현 유저·현 팀 최근 경기 |

### Layer 5 — UI
**공용 유틸** (신규)
- `lib/core/utils/capture.dart` — `captureWidgetAsPng(GlobalKey, {pixelRatio})`
  공용. `RepaintBoundary.toImage` + `ImageByteFormat.png` + image.dispose.
  share 와 crop 에서 재사용, 메모리 누수 방지.
- `lib/core/utils/date_format.dart` — `kWeekdaysShort`, `formatMdWeekday(DateTime)`.
  (코드베이스에 5군데 더 인라인된 동일 배열이 있음 — 점진 마이그레이션용)

**Profile**
- `features/profile/presentation/profile_screen.dart`:
  - `ConsumerWidget` → `ConsumerStatefulWidget` — `_cardKey`, `_sharing` 상태
  - `_shareCard(player)` — `captureWidgetAsPng` + `Share.shareXFiles`
  - `_ProfileCard` 를 `RepaintBoundary(key: _cardKey)` 로 래핑
  - 5개 provider watch (player/team/stats/titles/recent)
  - 더미 상수(`_name`,`_position`,`_number`,`_team`,`_season`,`_appearances`,
    `_goals`,`_assists`,`_mom`,`_tags`,`_recentPerformances`,`_PerfData`) 전부 제거
  - `_BigAvatar` — URL 있으면 220×220 사각형(smoothMd), 없으면 기본 풀샷
  - `_positionsText` — 2개 초과 시 `A, B +N` 포맷
  - `_TagRow` — `PlayerTitle` → 카테고리별 bg/fg 색상 pill
  - `_RecentSection` — 실데이터, 0개면 "기록된 경기가 없습니다"
  - 편집 화면 `_EditProfileScreen`:
    - `_selectedPositions: Set<Position>` / `_foot: PreferredFoot` **직접** 보유
      (String 라운드트립 제거)
    - `_pickedAvatarBytes` 만 유지 (`_pickedAvatarExt` 삭제 — 크롭 산출물은 항상 PNG)
    - `_pickAvatar()` — `pickTeamLogoImage(context, maxWidth: 1500, ...)` 재사용
      → `CropImageScreen` push → 결과 bytes 저장
    - `_save()` — 업로드 URL 포함 전 필드 update,
      `invalidate(currentPlayerProvider) + await read(future)` 로 fresh 확정 후 pop
- `features/profile/presentation/widgets/crop_image_screen.dart` (신규):
  - InteractiveViewer + RawImage + 초기 cover transform 계산
  - `_GuidePainter` — 사각 테두리 + 인스크립트 원 + 3분할 가이드
  - `captureWidgetAsPng` 로 캡처

**Home**
- `features/home/presentation/widgets/next_match_card.dart`:
  - `_onParticipateTap(match)` — DB 저장(프로필 선호 포지션 자동) / leave 토글
  - `_onParticipateLongPress(match)` — 바텀시트 + DB 저장
  - `_busy` 가드, `_showError` helper
  - 더미 모드는 예전처럼 로컬 토글만

**Join sheet**
- `features/home/presentation/widgets/join_match_sheet.dart`:
  - 내부 `_quarters` 1-indexed (1~4) 로 통일. `Q${q + 1}` → `Q$q`.
  - leaky abstraction 제거 — 호출자가 `+1` 변환하지 않음.

**Team logo picker (공용)**
- `shared/widgets/team_logo_picker.dart`:
  - `pickTeamLogoImage` 에 optional `maxWidth/maxHeight/imageQuality` 파라미터.
    팀 로고 기본 512/85, 프로필 호출은 1500/92 전달.

**공용**
- `features/profile/presentation/profile_screen.dart` — `_OpponentLogoImage`
  클래스 삭제, `TeamLogoView.byName` 재사용.
- 프로필의 `_formatMatchDate` / `_weekdays` 제거, `formatMdWeekday` 재사용.
- `_seasonLabel()` 를 `currentSeasonHalf()` + `SeasonHalf.label` 로 1줄 축약.

### pubspec
- `share_plus: ^10.1.4` 추가

## 크롭 UI 상세

| 요소 | 스펙 |
|---|---|
| 크롭 박스 | 320 × 320 logical px, 흰색 2px 테두리 |
| 가이드 | 인스크립트 원(r=160, α 0.55), 3분할 라인(α 0.25) |
| 입력 | drag(팬), pinch(줌 0.2~5) |
| 초기 transform | `max(320/w, 320/h)` 로 cover + 중앙 정렬 |
| 출력 | PNG bytes, pixelRatio 3 = ~960×960 |
| 업로드 ext | 항상 `'png'` (ui.ImageByteFormat.png 고정) |

## 공유 UI 상세

| 요소 | 스펙 |
|---|---|
| 캡처 대상 | `_ProfileCard` (이름/팀/아바타/4스탯/뱃지) |
| 해상도 | pixelRatio 3, 카드 실 렌더 크기 × 3 |
| 형식 | PNG, `Share.shareXFiles([XFile.fromData(...)])` |
| 파일명 | `profile_{playerId}.png` |
| 공유 텍스트 | `${player.name} 프로필` |

## 성능/품질 체크 (선-cleanup 리뷰 후)

`/simplify` 3개 병렬 리뷰 기반:

**코드 재사용**
- `captureWidgetAsPng` 로 share + crop 동일 sequence 통합
- `formatMdWeekday` 공용화 (프로필에서 6번째 복제 방지)
- `_OpponentLogoImage` 삭제, `TeamLogoView.byName` 재사용
- `Position.fromLabel` / `PreferredFoot.fromLabel` 추가, repo/UI 중복 파싱 제거
- `pickTeamLogoImage` 파라미터화, 인라인 picker 제거

**품질**
- `_pickedAvatarExt` 제거 (크롭 산출물 항상 PNG)
- `_selectedPositions: Set<String>` → `Set<Position>` 로 스트링 라운드트립 제거
- `_foot: String` → `PreferredFoot` enum 직접
- 쿼터 0/1 index 혼용 leaky abstraction 제거 (시트가 1-indexed 소유)
- narrative 주석 ("더미 모드:", "새 데이터가 확실히 들어온 뒤 pop ..." 등) 삭제

**성능**
- `_shareCard` 의 `ui.Image.dispose()` 누락 수정 → 탭마다 ~3.7MB leak 막음
  (`captureWidgetAsPng` 내부 `finally` 에서 dispose)
- 공유/크롭 캡처 pixelRatio 3 유지 — 220px @ 3x = 660, 960 여유 OK

## 단계

- [x] `get_player_titles` RPC 마이그레이션 + 푸시
- [x] `PlayerTitle` enum + StatsRepo 인터페이스 + Supabase 구현
- [x] 프로필용 4개 Provider + `currentSeasonHalf()` 헬퍼
- [x] profile_screen 더미 전체 제거, 실데이터 연결
- [x] `_BigAvatar` 사각 220×220 (smoothMd)
- [x] 편집 화면 — 전 필드 저장 + `.select('id')` RLS 검증
- [x] `share_plus` + `_shareCard` 구현
- [x] `CropImageScreen` 신규 — 사각·원 가이드 동시 표시
- [x] 선호 포지션 3+ 표시: `+N` 포맷
- [x] 홈 참가 탭/길게누름 분기 + DB 저장
- [x] /simplify 3개 리뷰 반영 (reuse/quality/efficiency)
- [x] `flutter analyze` 에러 0 확인

## 핵심 파일

| Layer | 파일 |
|---|---|
| types | `lib/types/enums.dart` (PlayerTitle, Position.fromLabel, PreferredFoot.fromLabel) |
| types | `lib/types/match.dart` (JoinMatchResult 주석) |
| repo | `lib/repo/stats_repo.dart` + `lib/repo/supabase_stats_repo.dart` (getPlayerTitles) |
| repo | `lib/repo/supabase_profile_repo.dart` (RLS 검증) |
| repo | `lib/repo/supabase_player_repo.dart` (fromLabel 재사용) |
| runtime | `lib/runtime/providers.dart` (4 providers + currentSeasonHalf) |
| core | `lib/core/utils/capture.dart` (신규) |
| core | `lib/core/utils/date_format.dart` (신규) |
| ui-shared | `lib/shared/widgets/team_logo_picker.dart` (파라미터화) |
| ui-profile | `lib/features/profile/presentation/profile_screen.dart` |
| ui-profile | `lib/features/profile/presentation/widgets/crop_image_screen.dart` (신규) |
| ui-home | `lib/features/home/presentation/widgets/next_match_card.dart` |
| ui-home | `lib/features/home/presentation/widgets/join_match_sheet.dart` |
| db | `supabase/migrations/20260415020000_player_titles.sql` |
| pubspec | share_plus: ^10.1.4 |

## 메모 / 향후 작업

- `_isJoined` 는 홈 카드 로컬 상태 — 서버 participations 에서 derive 하면
  다른 디바이스/재실행 간 동기화 가능. 다음 작업
- `ScaffoldMessenger.showSnackBar(...floating...)` 패턴이 20+ 파일에 반복,
  `InlineSpinner` 도 여러 곳 반복. 공용 헬퍼 추출은 별도 스윕
- `SeasonHalf.label` 이 DB 뷰 `season_player_stats.half`('상반기'/'하반기')
  와 RPC `p_half`('H1'/'H2') 두 가지 표현 담당 — 추후 `SeasonHalf.dbCode`
  분리하면 i18n 안전
- `PlayerTitle` 라벨 '득점왕' 등이 SQL RPC 반환값에 하드코딩됨 — i18n 시
  코드 상수('top_scorer') 분리 필요
- 크롭 출력 pixelRatio 3 → 2 로 낮추면 업로드 용량 ~55% 절감. 현재 220px
  표시 대비 충분함. UX 관찰 후 조정
- 프로필 "최근 경기 기록" 중 전체 보기 버튼은 onPressed `{}` — 추후 연결
- 구 아바타 파일 orphan 정리 (팀 로고와 동일 이슈) 향후
