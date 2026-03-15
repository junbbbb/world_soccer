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
│   └── theme/           # AppColors, AppTextStyles
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
    └── widgets/         # TeamLogoBadge, SectionTitle 등 공용 위젯
```

## Navigation Flow

```
앱 실행 → HomeScreen (하단바: 홈/채팅/스탯/팀)
  → NextMatchCard 탭 → context.push('/match')
  → MatchDetailScreen (풀스크린, 뒤로가기 버튼)
  → 뒤로가기 → HomeScreen 복귀
```

## Code Style

- 폰트: `Pretendard` (본문), `SCDream` (팀명/강조), `Barlow Condensed` (영문 타이틀)
- 라운딩: `figma_squircle` 사용, cornerSmoothing 1.0 기본
- 여백: 8px 그리드 기반, 좌우 24px, 섹션 간 32px (Airbnb 여백 철학)
- 색상: `AppColors` 클래스 사용, 하드코딩 지양
- 텍스트: `AppTextStyles` 클래스 사용

## Assets

- `assets/images/` — 팀 로고 (fc_calor.png, fc_bosong.png)
- `assets/fonts/` — SCDream 1~9

## Important Notes

- `app_router.dart` 수정 후 반드시 `build_runner` 실행
- 한국어 UI, 응답도 한국어로
