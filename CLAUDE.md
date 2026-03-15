# World Soccer (칼로FC 팀 관리 앱)

Flutter 기반 축구팀 관리 앱. 경기 참가, 전적, 팀 커뮤니티 기능 제공.

## Build & Run

```bash
flutter pub get                              # 의존성 설치
dart run build_runner build --delete-conflicting-outputs  # 코드 생성 (riverpod, freezed, json_serializable)
flutter analyze                              # 정적 분석
flutter run                                  # 앱 실행
```

## Tech Stack

- **Flutter** + **Dart**
- **Riverpod** (상태관리, `riverpod_annotation` + code generation)
- **GoRouter** (라우팅, `app_router.dart` → `app_router.g.dart`)
- **Freezed** + **json_serializable** (모델)
- **figma_squircle** (iOS 스타일 squircle 라운딩)
- **Google Fonts** (Barlow Condensed 등)

## Architecture

```
lib/
├── core/
│   ├── router/          # GoRouter 설정 (/ → HomeScreen, /match → MatchDetailScreen)
│   └── theme/           # 디자인 시스템 (아래 Design System 섹션 참고)
│       ├── app_colors.dart
│       ├── app_text_styles.dart
│       ├── app_spacing.dart
│       ├── app_radius.dart
│       ├── app_shadows.dart
│       └── app_theme.dart
├── features/
│   ├── home/            # 홈 화면 (하단 네비 포함)
│   │   └── presentation/
│   │       ├── home_screen.dart      # 메인 셸 (BottomNavigationBar + IndexedStack)
│   │       ├── home_tab.dart         # 홈 탭 (NextMatchCard, 최근전적, 게시물)
│   │       └── widgets/
│   │           ├── next_match_card.dart
│   │           ├── team_recent_results_section.dart
│   │           └── team_posts_section.dart
│   ├── match/           # 경기 상세 (풀스크린, 하단바 없음)
│   │   └── presentation/
│   │       ├── match_screen.dart     # MatchDetailScreen
│   │       └── widgets/             # MatchHeader, TabBar, Lineup, Attendance 등
│   └── auth/
└── shared/
    └── widgets/         # 공용 위젯
        ├── team_logo_badge.dart
        ├── section_title.dart
        ├── match_time_info.dart     # 경기 시간 블록 (오후 뱃지 + 시간 + 날짜/장소)
        └── player_chip.dart
```

## Navigation Flow

```
앱 실행 → HomeScreen (하단바: 홈/채팅/스탯/팀)
  → NextMatchCard 탭 → context.push('/match')
  → MatchDetailScreen (풀스크린, 뒤로가기 버튼)
  → 뒤로가기 → HomeScreen 복귀
```

## Design System

### 색상 (`AppColors`)

| 토큰 | 값 | 용도 |
|------|-----|------|
| `primary` | `#1572D1` | 브랜드 파란색, CTA 버튼 |
| `primaryDark` | `#1C6EC3` | 그라데이션 시작 |
| `textPrimary` | `#333D4B` | 기본 텍스트 |
| `textSecondary` | `#6B7684` | 보조 텍스트 |
| `textTertiary` | `#8E97A3` | 비활성 텍스트, 아이콘 |
| `surface` | `#F2F4F6` | 카드/칩 배경 |
| `surfaceLight` | `#F6F7F9` | 더 밝은 배경 |
| `iconInactive` | `#D1D6DB` | 비활성 네비 아이콘 |
| `overlayDark` | black 30% | 오버레이 뱃지 배경 |

### 텍스트 스타일 (`AppTextStyles`)

| 토큰 | 크기/굵기 | 폰트 | 용도 |
|------|-----------|------|------|
| `pageTitle` | 20/w700 | SCDream | 페이지 제목 (홈 "칼로FC") |
| `sectionTitle` | 20/w700 | Pretendard | 섹션 제목 |
| `heading` | 16/w700 | Pretendard | 중간 제목 |
| `body` | 15/w500 | Pretendard | 본문 기본 |
| `bodyRegular` | 15/w400 | Pretendard | 본문 레귤러 |
| `label` | 14/w700 | Pretendard | 라벨 굵은 |
| `labelMedium` | 14/w600 | Pretendard | 라벨 중간 |
| `labelRegular` | 14/w400 | Pretendard | 라벨 기본 |
| `captionBold` | 13/w800 | Pretendard | 캡션 굵은 |
| `captionMedium` | 13/w600 | Pretendard | 캡션 중간 |
| `caption` | 12/w400 | Pretendard | 캡션 |
| `buttonPrimary` | 17/w700 | Pretendard | 메인 CTA |
| `buttonSecondary` | 16/w600 | Pretendard | 보조 버튼 |
| `teamName` | 14/w700 | SCDream | 팀명 (white) |
| `matchInfo` | 14/w500 | SCDream | 경기 날짜/장소 (white) |
| `timeBadge` | 14/w700 | Pretendard | 오후/오전 뱃지 (white) |
| `timeDisplay` | 36/w800 | Barlow Condensed | 경기 시간 (white, static final) |

### 여백 (`AppSpacing`) — 8px 그리드

| 토큰 | 값 | 용도 |
|------|-----|------|
| `xxs` | 2 | 미세 간격 |
| `xs` | 4 | 아이콘↔텍스트 |
| `sm` | 8 | 기본 소 간격 |
| `md` | 12 | 아이콘↔텍스트 (큰) |
| `base` | 16 | 기본 간격 |
| `lg` | 20 | 탭 라벨 패딩 |
| `xl` | 24 | 좌우 페이지 패딩, 섹션 패딩 |
| `xxl` | 32 | 섹션 간 간격 |
| `xxxl` | 48 | 큰 여백 |
| `xxxxl` | 80 | 스크롤 하단 여유 |
| `paddingPage` | h:24 | 페이지 좌우 패딩 |
| `paddingSection` | h:24, v:24 | 섹션 전체 패딩 |

### 라운딩 (`AppRadius`) — squircle 기본

| 토큰 | 값 | 용도 |
|------|-----|------|
| `xs` | 4 | 작은 로고 클립 |
| `sm` | 8 | 팀 로고, 캡슐 |
| `md` | 12 | 버튼, 컨테이너 |
| `button` | 14 | CTA 버튼 |
| `lg` | 16 | 카드 |
| `xl` | 20 | 바텀시트 |
| `full` | 100 | 캡슐/원형 |
| `smoothXs`~`smoothLg` | cached | 캐시된 SmoothBorderRadius (빌드마다 재생성 방지) |

### 그림자 (`AppShadows`)

| 토큰 | 용도 |
|------|------|
| `header` | 매치 헤더 |
| `bottomBar` | 하단 네비게이션 |
| `elevated` | 플로팅 요소 |

## Code Style

- 폰트: `Pretendard` (본문), `SCDream` (팀명/강조), `Barlow Condensed` (영문 타이틀)
- 라운딩: `AppRadius.smoothXx` 캐시 사용 우선, 비표준 값은 `AppRadius.smooth(값)`
- 여백: `AppSpacing` 토큰 사용, 하드코딩 금지 (예외: 칩 내부 14/10 같은 컴포넌트 고유 값)
- 색상: `AppColors` 사용, 하드코딩 금지
- 텍스트: `AppTextStyles` 사용, 색상은 `.copyWith(color:)`로 적용
- EdgeInsets: 반복 패턴은 `AppSpacing.paddingPage` / `AppSpacing.paddingSection` 사용

## Assets

- `assets/images/` — 팀 로고 (fc_calor.png, fc_bosong.png), 아바타 이미지
- `assets/icons/` — SVG 아이콘 (하단 네비)
- `assets/fonts/` — SCDream 1~9

## Important Notes

- `app_router.dart` 수정 후 반드시 `build_runner` 실행
- 한국어 UI, 응답도 한국어로
- `bottom_action_bar.dart`는 현재 미사용 (match_screen에서 직접 버튼 구현)
- 새 위젯 추가 시 디자인 토큰 사용 필수, 하드코딩 절대 금지
