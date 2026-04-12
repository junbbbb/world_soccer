# Technical Decisions Log

## 결정 목록

| # | 날짜 | 제목 | 상태 |
|---|------|------|------|
| 001 | 2026-04-12 | 6-Layer 아키텍처 채택 (OpenAI Layered) | 확정 |
| 002 | 2026-04-12 | Supabase 백엔드 선택 | 확정 |
| 003 | 2026-04-12 | 시즌 구조: 상반기/하반기 (6개월) | 확정 |

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
