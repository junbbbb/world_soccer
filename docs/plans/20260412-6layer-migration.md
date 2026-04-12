# 6-Layer 아키텍처 마이그레이션 + Supabase 연동

시작: 2026-04-12
상태: 진행중

## 단계

- [x] Phase 0 — 뼈대 디렉토리 생성 (types/, config/, repo/, service/, runtime/)
- [x] Phase 1 — Types 추출 (7개 모델 파일: enums, player, team, match, lineup, chat, profile)
- [x] Phase 2 — Config 추출 (supabase_config, app_constants + 포메이션/포지션 상수)
- [x] Supabase CLI 초기화 + 프로젝트 링크
- [x] DB 마이그레이션 (8 테이블 + RLS + trigger + view) — 정규화 설계 채택
- [x] 패키지 추가 (supabase_flutter, mockito)
- [x] Phase 3 — Repo 인터페이스 7개 (auth, match, lineup, player, profile, team, stats)
- [x] Phase 4 — Service TDD (LineupService + MatchService: 테스트 먼저 → 구현)
- [x] 버그 수정: Match.result의 draw/loss 뒤바뀜 발견 + Types 단위 테스트 추가
- [x] Simplify 1차 — stringly-typed→enum, 중복 제거, 효율성 개선, H2H 버그 수정
- [x] Repo 구현체 7개 (Supabase 실제 연결: auth, match, player, lineup, team, stats, profile)
- [x] Phase 5 — Runtime 구성 (Supabase 초기화 + Riverpod Provider DI 등록)
- [ ] Phase 6 — UI 이동 (features/ → ui/)
- [ ] Phase 8 — import_lint 강제

## 프로세스 규칙

- **레이어 하나 완성될 때마다 `/simplify` 실행** — 중복, 품질, 효율성 리뷰 후 수정
- 몰아서 하면 변경 범위가 커져 기존 테스트가 깨질 위험 증가

## 설계 결정

- 권한 3단계: admin(운영진), member(일반유저), mercenary(용병 — 가입 후부터 기록)
- 쿼터 인덱싱: DB는 1-indexed (1~4), UI에서 변환
- 라인업 저장: 정규화 (quarter_lineups + slot_assignments) — FK 무결성 + 집계 쿼리 용이
- Auth: players.id = auth.uid 구조, signup trigger로 자동 생성
- TDD: Service에서 시작, Types의 로직 있는 getter도 테스트 대상

## 메모

- Match.result getter에 draw/loss 뒤바뀜 버그 있었음 — H2H 집계 테스트에서 두 버그가 상쇄되어 통과. 개별 값 검증 테스트 추가로 해결.
- 교훈: "로직 있는 getter"도 반드시 단위 테스트 작성할 것. 집계만 검증하면 개별 버그 놓칠 수 있음.
