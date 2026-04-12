# Change Risk Classification — Blast Radius

## Core (변경 전 확인 필요)

변경 시 데이터 손실, 인증 실패, 앱 크래시 가능성이 있는 영역.

| 영역 | 파일 패턴 | 이유 |
|------|----------|------|
| DB 스키마 | `supabase/migrations/`, `types/*.dart` 모델 필드 추가/삭제 | 기존 데이터와 불일치 |
| 인증 | `repo/auth_repo.dart`, `service/auth_service.dart` | 로그인 불가 |
| Supabase 설정 | `config/supabase_config.dart`, `.env` | 전체 데이터 접근 불가 |
| 레이어 의존성 규칙 | `analysis_options.yaml`, `import_lint.yaml` | 아키텍처 무너짐 |
| 앱 진입점 | `main.dart`, `runtime/app.dart` | 앱 실행 불가 |

## Mid (테스트 실패 시 알림)

비즈니스 로직에 영향. 테스트가 잡아주지만 사이드 이펙트 가능.

| 영역 | 파일 패턴 | 이유 |
|------|----------|------|
| 비즈니스 로직 | `service/*.dart` | 계산 오류, 분배 로직 깨짐 |
| 라우팅 | `runtime/router.dart`, `app_router.dart` | 화면 이동 깨짐 |
| 상태 관리 | `*_controller.dart`, `*_provider.dart` | UI 동기화 깨짐 |
| 데이터 접근 | `repo/*.dart` 쿼리 변경 | 잘못된 데이터 표시 |
| 자동 분배 | `auto_distributor.dart` | 라인업 공정성 깨짐 |

## Shell (테스트 통과하면 자율 진행)

사용자 경험에 영향은 있지만 데이터/로직 무결성에는 영향 없음.

| 영역 | 파일 패턴 | 이유 |
|------|----------|------|
| UI 컴포넌트 | `ui/**/*.dart`, `widgets/*.dart` | 시각적 변경만 |
| 디자인 토큰 | `core/theme/*.dart` | 색/폰트/여백 변경 |
| 문서 | `*.md`, `docs/` | 코드 무관 |
| 테스트 | `test/**/*.dart` | 기존 기능 무관 |
| 더미 데이터 | `*_dummy_data.dart` | 실제 데이터 무관 |
| 에셋 | `assets/` | 이미지/폰트 교체 |
