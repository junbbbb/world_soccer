# 칼로FC — 조기축구 팀 관리 앱

## Overview

Flutter 기반 조기축구 팀 관리 앱. 경기 참가, 라인업 빌더, 전적/스탯, 프로필, 팀 커뮤니티 기능.
Supabase (Postgres + Auth + Realtime) 백엔드. 현재 UI 완성 단계, 데이터 레이어 미연동.

## Tech Stack

- **Frontend**: Flutter 3.x + Dart (SDK ^3.8.1)
- **State**: Riverpod (riverpod_annotation + code generation)
- **Routing**: GoRouter (app_router.dart → .g.dart)
- **Backend**: Supabase (예정) — Postgres, Auth, Realtime, Storage
- **Models**: Freezed + json_serializable (예정), 현재 순수 Dart class
- **Design**: figma_squircle, Google Fonts (Barlow Condensed)
- **Build**: build_runner (riverpod_generator, freezed, json_serializable)

## Architecture — 6-Layer (OpenAI Layered)

```
의존성 방향: → (앞으로만 허용, 뒤로 가는 import 금지)

Types → Config → Repo → Service → Runtime → UI
                                               ↑
                                          Core(theme)는 예외: 모든 레이어에서 접근 가능
```

```
lib/
├── types/          # 순수 데이터 모델, enum, typedef (의존: 없음)
├── config/         # 설정, 상수, 환경변수 (의존: types)
├── repo/           # 데이터 접근 — Supabase 쿼리, 캐시 (의존: types, config)
├── service/        # 비즈니스 로직 — repo 조합 (의존: types, config, repo)
├── runtime/        # 앱 초기화, 라우터, DI (의존: types~service)
├── ui/             # 화면, 위젯 (의존: 전부)
│   ├── home/
│   ├── match/
│   ├── profile/
│   ├── chat/
│   ├── stats/
│   ├── team/
│   └── shared/
└── core/           # 디자인 시스템 (theme/) — 예외적 전역 접근
    └── theme/
```

## Context Injection Rules

작업 유형에 따라 읽어야 할 문서:
- DB/데이터 스키마 변경 → `docs/architecture.md`
- Supabase 연동 → `docs/architecture.md` + `lib/repo/`
- UI 변경 → `DESIGN.md` + `docs/product-spec.md`
- 새 기능 → `docs/product-spec.md` + `docs/architecture.md`
- 리팩토링 → `docs/migration-scenarios.md`
- 그 외 → 이 파일로 충분

## Change Risk Classification

`docs/blast-radius.md` 참고. 요약:
- **Core** (확인 필요): DB 스키마, 인증, 레이어 의존성 규칙, Supabase config
- **Mid** (테스트 실패 시 알림): 비즈니스 로직(service/), 라우팅, 상태 관리
- **Shell** (테스트 통과하면 자율): UI 컴포넌트, 스타일, 유틸리티, 문서

## Work Rules

- 레이어 의존성 규칙 **절대 위반 금지** — 뒤로 가는 import 발견 시 즉시 수정
- 새 파일 생성 시 반드시 올바른 레이어 디렉토리에 배치
- 디자인 토큰 하드코딩 금지 (DESIGN.md 참고)
- 한국어 UI, 한국어 커밋 메시지
- 기술적 결정은 `docs/decisions/`에 기록

## Available Commands

- `/build [what]` — 기능 빌드
- `/changes [period]` — 최근 변경 요약
- `/status` — 프로젝트 상태
- `/cleanup` — 코드 정리
