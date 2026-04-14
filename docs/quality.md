# Quality Status

마지막 업데이트: 2026-04-14 (팀 라이프사이클 반영)

## 코드 규모

- 소스 파일: 약 86개 (`lib/`)
- 테스트 파일: 4개 (`test/types/`, `test/service/` — team_service_test.dart 추가)

## 정적 분석

- `flutter analyze` 결과:
  - Errors: **0**
  - Warnings: **2** (기존, minor)
  - Info: 다수 (대부분 `prefer_const_constructors`, `directives_ordering`, `dangling_library_doc_comments`)
- 레이어 의존성 위반: **미측정** (`import_lint` 미설치)
- `pubspec.yaml`: `figma_squircle` 제거됨 (discontinued)

## 테스트

- `flutter test` 기준: 33+ 통과 (신규 team_service 14건 포함)
- 기존 실패 2건은 내 변경과 무관: `match_test.dart` 하드코딩 날짜 만료, `widget_test.dart` ProviderScope 누락

## 테스트 커버리지

- Unit: 28개 통과 (Types 10, LineupService 10, MatchService 8)
- Widget: 0% (미작성)
- Integration: 0% (미작성)

## 빌드 상태

- build_runner: 정상
- Android: 미확인
- iOS: 미확인

## 아키텍처 현황

- 현재: `features/` + 6-Layer 병행 (마이그레이션 중)
- 목표: 6-Layer (`docs/migration-scenarios.md`)
- 마이그레이션 진행률: **Phase 4 완료** (Types, Config, Repo 인터페이스, Service 구현)
- 진행 상세: `docs/plans/20260412-6layer-migration.md`

## 기술 부채

| 우선순위 | 항목 | 상태 | 위험도 |
|----------|------|------|--------|
| 1 | 6-Layer 아키텍처 마이그레이션 | 미시작 | Core |
| 2 | 모든 더미 데이터 → Supabase 연동 | 미시작 | Core |
| 3 | freezed 모델 도입 | 미시작 | Mid |
| 4 | import_lint 레이어 강제 | 미시작 | Shell |
| 5 | 테스트 작성 | 미시작 | Mid |
| 6 | 오프라인 캐시 전략 | 미시작 | Mid |
| 7 | 에러 핸들링 통일 | 미시작 | Mid |
| 8 | info 43건 정리 (prefer_const) | 미시작 | Shell |
