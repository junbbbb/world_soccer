# Migration Scenarios — 현재 구조 → 6-Layer

## 현재 상태

```
lib/
├── core/router/ + theme/     → Runtime + Core로 분리
├── features/                 → UI로 이동
│   ├── home/presentation/    (더미 데이터 내장)
│   ├── match/presentation/   (더미 데이터 내장, 라인업 로직 내장)
│   ├── profile/presentation/ (더미 데이터 내장)
│   ├── chat/presentation/
│   ├── stats/presentation/   (더미 데이터 내장)
│   └── team/presentation/
├── shared/widgets/           → UI/shared로 이동
└── main.dart                 → Runtime으로 이동
```

**핵심 문제**: 모든 데이터(더미)와 비즈니스 로직이 presentation 레이어에 섞여있음.

## 마이그레이션 원칙

1. **각 Phase 후 앱이 빌드 & 실행 가능해야 함** (중간에 깨지면 안 됨)
2. **import 경로 변경은 한 번에 하지 않음** — re-export 파일로 점진적 이동
3. **더미 데이터는 마지막에 교체** — 먼저 구조만 잡고, Supabase 연동은 별도

## Phase 0: 뼈대 생성 (빈 디렉토리 + barrel 파일)

**작업**: 새 디렉토리 생성만. 기존 코드 안 건드림.
**위험도**: Shell (구조만)
**앱 영향**: 없음

```
mkdir -p lib/{types,config,repo,service,runtime}
```

각 디렉토리에 빈 barrel 파일 (`types.dart`, `config.dart` 등) 생성.

## Phase 1: Types 추출

**작업**: 현재 presentation에 흩어진 모델 클래스를 `types/`로 이동.
**위험도**: Mid (import 경로 변경)
**앱 영향**: 없음 (re-export로 기존 import 유지)

### 대상 파일

| 현재 위치 | 이동 | 내용 |
|----------|------|------|
| `match/presentation/lineup/models/lineup_models.dart` | `types/lineup.dart` | LineupMember, Formation, SlotPosition, QuarterLineup, LineupState |
| `match/presentation/lineup/models/lineup_dummy_data.dart` | `config/lineup_defaults.dart` | 더미 16명 + 포메이션 4종 |
| `match/presentation/lineup/lineup_design.dart` | `config/lineup_colors.dart` + `types/enums.dart` (FairnessStatus) | 라인업 색상 + 공정성 enum |
| `home/presentation/widgets/join_match_sheet.dart` 내 `JoinMatchResult` | `types/match.dart` | 참가 결과 타입 |

### 절차

1. `types/lineup.dart` 생성 — 모델 복사
2. 기존 `lineup_models.dart`를 re-export로 변경: `export 'package:world_soccer/types/lineup.dart';`
3. `flutter analyze` 통과 확인
4. 다음 Phase에서 기존 파일 import를 점진적으로 직접 참조로 교체

## Phase 2: Config 추출

**작업**: 더미 데이터, 상수, 포메이션/포지션 목록을 `config/`로 이동.
**위험도**: Shell
**앱 영향**: 없음

### 대상

| 현재 위치 | 이동 | 내용 |
|----------|------|------|
| `lineup_dummy_data.dart` | `config/lineup_defaults.dart` | 더미 로스터 + 포메이션 |
| `join_match_sheet.dart` 내 `_allPositions` | `config/position_config.dart` | 포지션 목록 |
| 각 화면의 더미 상수 | `config/dummy_data.dart` | 프로필/매치/스탯 더미 (임시, Supabase 연동까지) |

## Phase 3: Repo 인터페이스 + 더미 구현

**작업**: 각 도메인의 Repo 인터페이스(abstract class) 정의 + 더미 구현체.
**위험도**: Mid
**앱 영향**: 없음 (아직 연결 안 함)

```dart
// repo/match_repo.dart
abstract class MatchRepo {
  Future<List<Match>> getUpcoming(String teamId);
  Future<void> saveResult(String matchId, int ourScore, int opponentScore);
  Future<List<Match>> getH2H(String teamId, String opponentName);
}

// repo/match_repo_dummy.dart (Phase 7에서 match_repo_supabase.dart로 교체)
class MatchRepoDummy implements MatchRepo { ... }
```

### Repo 목록 (7개)

1. `auth_repo.dart` — 로그인/회원가입/로그아웃
2. `match_repo.dart` — 경기 CRUD, 결과
3. `lineup_repo.dart` — 라인업 저장/조회
4. `player_repo.dart` — 선수 정보, 참가
5. `profile_repo.dart` — 프로필 조회/수정
6. `team_repo.dart` — 팀 목록, 전환
7. `stats_repo.dart` — 시즌 스탯 집계

## Phase 4: Service 추출

**작업**: presentation에 있는 비즈니스 로직을 `service/`로 이동.
**위험도**: Mid
**앱 영향**: 없음 (아직 연결 안 함)

### 핵심 로직 이동 대상

| 현재 위치 | Service | 내용 |
|----------|---------|------|
| `lineup_controller.dart` 내 분배/배치 로직 | `lineup_service.dart` | autoDistribute, placeAtSlot, copyQuarter 등 |
| `auto_distributor.dart` | `lineup_service.dart` (내부 유틸) | 4-layer 분배 알고리즘 |
| 각 화면의 더미 계산 로직 | `stats_service.dart` | 시즌 기록 집계, H2H 계산 |

## Phase 5: Runtime 구성

**작업**: `main.dart` + `app_router.dart` → `runtime/`으로 이동.
**위험도**: Core (앱 진입점 변경)
**앱 영향**: 있음 — 신중히

### 절차

1. `runtime/app.dart` — MaterialApp + ProviderScope 조합
2. `runtime/router.dart` — GoRouter 설정 (기존 app_router.dart 이동)
3. `runtime/providers.dart` — Repo/Service Provider 등록
4. `main.dart` → `runtime/app.dart`를 호출만
5. `build_runner` 실행
6. 기존 `core/router/` 삭제 (re-export 거쳐서)

## Phase 6: UI 이동 (features/ → ui/)

**작업**: `features/` → `ui/`로 리네임. `shared/` → `ui/shared/`로.
**위험도**: Mid (대량 import 경로 변경)
**앱 영향**: 없음 (리네임만)

### 절차

1. `lib/ui/` 생성
2. 각 feature 디렉토리를 `ui/`로 이동 (presentation/ 하위만)
3. IDE 리팩토링으로 import 일괄 변경
4. `flutter analyze` 통과 확인

## Phase 7: Supabase 실제 연동

**작업**: Repo 더미 구현 → Supabase 구현으로 교체.
**위험도**: Core
**앱 영향**: 실데이터 전환

### 절차

1. Supabase 프로젝트 생성 + 테이블 마이그레이션
2. `config/supabase_config.dart` — URL, anon key 설정
3. 각 `*_repo_dummy.dart` → `*_repo_supabase.dart` 구현
4. `runtime/providers.dart`에서 DI 교체 (Dummy → Supabase)
5. RLS 정책 설정
6. 테스트

## Phase 8: 린터 강제

**작업**: `import_lint` 설치 + 레이어 규칙 설정.
**위험도**: Shell
**앱 영향**: 없음 (빌드 시 경고/에러 추가만)

### 절차

1. `pubspec.yaml`에 `import_lint` 추가
2. `import_lint.yaml` 설정 (architecture.md의 규칙대로)
3. `flutter analyze` 실행 → 위반 사항 수정
4. CI에 lint 체크 추가

## 실행 순서 요약

```
Phase 0 (뼈대)        → 5분, Shell, 독립
Phase 1 (Types)       → 30분, Mid, Phase 0 의존
Phase 2 (Config)      → 20분, Shell, Phase 1 의존
Phase 3 (Repo)        → 1시간, Mid, Phase 1+2 의존
Phase 4 (Service)     → 1시간, Mid, Phase 3 의존
Phase 5 (Runtime)     → 30분, Core, Phase 4 의존
Phase 6 (UI 이동)     → 20분, Mid, Phase 5 의존
Phase 7 (Supabase)    → 별도 세션, Core, Phase 6 의존
Phase 8 (린터)        → 15분, Shell, Phase 6 이후 아무때나
```

### 병렬 가능 구간

- Phase 1 + Phase 2: 독립적 (Types와 Config는 서로 의존 없음)
- Phase 7 + Phase 8: 독립적
- 나머지는 순차 필수
