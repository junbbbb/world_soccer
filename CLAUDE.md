# World Soccer (칼로FC 팀 관리 앱)

Flutter 기반 축구팀 관리 앱. 경기 참가, 전적, 팀 커뮤니티 기능 제공.
Supabase 백엔드. 6-Layer 아키텍처 (OpenAI Layered) 마이그레이션 진행 중.

> 프로젝트 구조/컨텍스트: `AGENTS.md`
> 디자인 시스템 상세: `DESIGN.md`
> 아키텍처 상세: `docs/architecture.md`
> 마이그레이션 계획: `docs/migration-scenarios.md`
> 기술 결정 로그: `docs/decisions/index.md`
> 주요 작업 타임라인: `docs/plans/`

## Build & Run

```bash
flutter pub get                              # 의존성 설치
dart run build_runner build --delete-conflicting-outputs  # 코드 생성
flutter analyze                              # 정적 분석
flutter run                                  # 앱 실행
```

## 6-Layer Architecture Rules

**의존성: Types → Config → Repo → Service → Runtime → UI (앞으로만)**

- 뒤로 가는 import 발견 시 **즉시 수정**
- 새 파일은 반드시 올바른 레이어에 배치
- `core/theme/`는 예외 — 모든 레이어에서 접근 가능
- Repo를 UI에서 직접 접근 지양 → Service를 통해
- 상세 규칙 + 의존성 매트릭스: `docs/architecture.md`

## Tech Stack

- **Flutter** + **Dart** (SDK ^3.8.1)
- **Supabase** — Postgres, Auth, Realtime, Storage (연동 완료)
- **Riverpod** (상태관리, `riverpod_annotation` + code generation)
- **GoRouter** (라우팅, `app_router.dart` → `app_router.g.dart`)
- **Freezed** + **json_serializable** (모델, 예정)
- **Google Fonts** (Barlow Condensed)

## Architecture

현재: `features/` 기반 (마이그레이션 진행 중)
목표: 6-Layer (`docs/migration-scenarios.md` 참고)

```
lib/
├── types/          # Layer 0: 순수 데이터 모델, enum (의존: 없음)
├── config/         # Layer 1: 설정, 상수 (의존: types)
├── repo/           # Layer 2: 데이터 접근 — Supabase (의존: types, config)
├── service/        # Layer 3: 비즈니스 로직 (의존: types, config, repo)
├── runtime/        # Layer 4: 앱 초기화, 라우터, DI (의존: types~service)
├── ui/             # Layer 5: 화면, 위젯 (의존: 전부)
│   ├── home/
│   ├── match/
│   ├── profile/
│   ├── chat/
│   ├── stats/
│   ├── team/
│   └── shared/
└── core/           # 예외: 디자인 시스템 (모든 레이어에서 접근)
    └── theme/
```

## Navigation Flow

```
앱 실행 → HomeScreen (하단바: 홈/채팅/스탯/팀)
  홈 → NextMatchCard 탭 → /match (경기 상세)
  홈 → 참가하기 → 바텀시트 (포지션+쿼터)
  홈 → 프로필 아이콘 → /profile
  홈 → 팀명 탭 → 팀 전환 시트
  경기 상세 → 라인업 만들기 → /match/lineup-builder
  경기 상세 → 결과 입력 → /match/result-input
  프로필 → ⚙️ → 프로필 편집 (풀스크린)
  채팅 → 방 탭 → /chat (ChatRoomScreen, 실시간 송수신)
  채팅방 → 헤더 → /group-info (팀원 목록 + 1:1 메시지 버튼)
  팀원 "1:1 메시지" → getOrCreateDirectRoom → /chat (DM)
```

## Chat 시스템 요약

팀 생성/멤버 변동에 맞춰 DB 트리거가 방을 자동 동기화, 1:1 DM 은
RPC + advisory lock 으로 원자 생성. 방 목록/메시지는 RPC 집계와
sender 캐시로 N+1 없음. 상세: `docs/plans/20260415-chat-feature.md`
+ 결정 012~014.

핵심 파일:
- `lib/types/chat.dart`, `lib/repo/chat_repo.dart`, `lib/repo/supabase_chat_repo.dart`
- `lib/service/chat_service.dart` (TDD, 12 케이스)
- `lib/features/chat/presentation/chat_tab.dart` (realtime 배지)
- `lib/features/chat/presentation/chat_room_screen.dart` (stream + optimistic send)
- `lib/features/chat/presentation/group_info_screen.dart` (팀원 + DM 진입점)

서버:
- `supabase/migrations/20260414050000_chat.sql` (스키마 + 트리거)
- `supabase/migrations/20260414060000_chat_rls_fix.sql` (RLS 재귀 수정)
- `supabase/migrations/20260414070000_chat_perf.sql` (RPC 집계 + lock)
- `supabase/migrations/20260415000000_chat_logo.sql` (팀 로고 RPC 반영)

## Design Tokens (요약)

상세 디자인 시스템: `DESIGN.md`

### 색상 (`AppColors`)

| 토큰 | 값 | 용도 |
|------|-----|------|
| `primary` | `#1572D1` | 브랜드, CTA |
| `primaryDark` | `#1C6EC3` | 그라데이션 |
| `textPrimary` | `#333D4B` | 기본 텍스트 |
| `textSecondary` | `#6B7684` | 보조 텍스트 |
| `textTertiary` | `#8E97A3` | 비활성, 캡션 |
| `surface` | `#F2F4F6` | 회색 배경 |
| `surfaceLight` | `#F6F7F9` | 카드/입력 배경 |
| `error` | `#E5484D` | 에러, 패배 |
| `iconInactive` | `#D1D6DB` | 비활성 아이콘 |
| `badgeBlue` | `#2563EB` | 뱃지 파란색 |
| `momBackground` | `#FFF8E1` | MOM 배지 배경 |
| `momText` | `#F57F17` | MOM 배지 텍스트 |
| `rankGold` | `#FFC107` | 랭킹 금 |
| `rankSilver` | `#B0BEC5` | 랭킹 은 |
| `rankBronze` | `#BF8A54` | 랭킹 동 |

### 텍스트 스타일 (`AppTextStyles`)

| 토큰 | 크기/굵기 | 폰트 |
|------|-----------|------|
| `pageTitle` | 20/w700 | SCDream |
| `sectionTitle` | 20/w700 | Pretendard |
| `heading` | 16/w700 | Pretendard |
| `body` | 15/w500 | Pretendard |
| `bodyRegular` | 15/w400 | Pretendard |
| `label` | 14/w700 | Pretendard |
| `labelMedium` | 14/w600 | Pretendard |
| `labelRegular` | 14/w400 | Pretendard |
| `captionBold` | 13/w800 | Pretendard |
| `captionMedium` | 13/w600 | Pretendard |
| `caption` | 12/w400 | Pretendard |
| `buttonPrimary` | 17/w700 | Pretendard |
| `buttonSecondary` | 16/w600 | Pretendard |
| `timeDisplay` | 36/w800 | Barlow Condensed |

### 여백 (`AppSpacing`) — 8px 그리드

| 토큰 | 값 |
|------|----|
| `xs` | 4 |
| `sm` | 8 |
| `md` | 12 |
| `base` | 16 |
| `lg` | 20 |
| `xl` | 24 |
| `xxl` | 32 |
| `xxxl` | 48 |
| `paddingPage` | **h:20** (= lg) |
| `paddingSection` | **h:20, v:24** (= lg, xl) |

### 라운딩 (`AppRadius`) — squircle

| 토큰 | 값 | 캐시 |
|------|-----|------|
| `xs` | 4 | `smoothXs` |
| `sm` | 8 | `smoothSm` |
| `md` | 12 | `smoothMd` |
| `button` | 14 | `smoothButton` |
| `lg` | 16 | `smoothLg` |
| `xl` | 20 | `smoothXl` |
| `full` | 100 | `smoothFull` |

## Code Style

- 폰트: `Pretendard` (본문), `SCDream` (팀명), `Barlow Condensed` (큰 숫자)
- 라운딩: `AppRadius.smoothXx` 캐시 사용 우선
- 여백: `AppSpacing` 토큰 사용, 하드코딩 금지
- 색상: `AppColors` 사용, 하드코딩 금지
- 텍스트: `AppTextStyles` + `.copyWith(color:)` 패턴
- 선택 요소: outline pill (배경 유지 + 테두리로 선택 표현)
- CTA: `textPrimary`(검정) 배경 = 저장/확인, `primary`(파랑) = 참가하기
- 컴포넌트 패턴 상세: `DESIGN.md`

## Assets

- `assets/images/` — 팀 로고, 아바타 이미지
- `assets/icons/` — SVG 아이콘 (하단 네비)
- `assets/fonts/` — SCDream 1~9, Pretendard, Barlow Condensed

## Important Notes

- `app_router.dart` 수정 후 반드시 `build_runner` 실행
- 한국어 UI, 응답도 한국어로
- 새 위젯 추가 시 디자인 토큰 사용 필수, 하드코딩 절대 금지
- 하네스 명령: `/build`, `/status`, `/changes`, `/cleanup` (AGENTS.md 참고)
- 변경 위험도: `docs/blast-radius.md` (Core/Mid/Shell)
- 기술 결정 기록: `docs/decisions/`
