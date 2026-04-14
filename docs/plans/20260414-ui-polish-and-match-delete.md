# 2026-04-13~14 — UI 다듬기 + 경기 삭제

경기 상세 화면의 시각/기능 개선 묶음.

## 변경 요약 (사용자 관점)

### Before → After

**상대팀 로고**
- Before: 더미 로고(쏘아/칼로 이미지) 를 상대 모든 팀에 공통 사용 → 어느 팀이든 로고가 똑같이 보임
- After: 기본 방패 이미지 + 팀 이름 이니셜(예: `FC뽀잉` → `B`, `드림FC` → `D`). 실제 로고 업로드된 팀은 그대로 노출

**경기 상세 — 라인업 4쿼터 미리보기**
- Before: 각 쿼터 안 선수 위치가 흰 점으로 표시
- After: 실제 라인업 그대로 축소해서 표시(아바타/이니셜). 1:1 정사각형 셀이라 위아래가 살짝 잘림

**경기 상세 — 라인업 섹션**
- Before: 2×2 미니 피치 그리드만 노출
- After: 연한 회색 카드 안에 그리드 배치, 카드 하단에 "감독의 전술" 메모 영역(현재는 placeholder)

**전반적인 모서리 라운딩**
- Before: squircle(cornerSmoothing 1.0) 기반 Apple 스타일 둥근 모서리
- After: 표준 라운딩. 디자인 토큰 이름은 유지(`AppRadius.smoothLg` 등) 되어 호출처 변경 없음. 시각 차이 거의 없음. `figma_squircle` discontinued 대응

**경기 삭제**
- Before: 잘못 만든 경기는 "취소(cancelled)" 상태로만 전환 가능 → 목록에 남음
- After: 경기 상세 우상단 `⋯` → `경기 삭제` 로 영구 삭제 가능. 확인 다이얼로그 필수. admin 권한만 가능

## 기술 변경

- `lib/shared/widgets/opponent_logo.dart` 신설 (SVG 에서 PNG 추출 → `assets/images/defaultteamlogo.png` 사용, 한글 초성→영문 매핑 유틸 포함)
- `lib/features/match/presentation/lineup/widgets/mini_pitch_view.dart` 재작성 — 실제 PlayerSlot 축소판
- `lib/features/match/presentation/widgets/lineup_section.dart` — `_LineupCard` + `_TacticsNote` 신설
- squircle 제거: 32개 파일 일괄 치환, `pubspec.yaml` 에서 `figma_squircle` 제거, `AppRadius` 캐시가 `BorderRadius.circular` 반환
- 경기 삭제: `MatchRepo.delete` + `SupabaseMatchRepo` 구현, `MatchTopBarDelegate.onDelete`, `match_screen.dart._confirmDelete`
- DB: `supabase/migrations/20260414000000_matches_delete_policy.sql` — RLS `matches_delete` 정책 (admin only), `supabase db push` 로 원격 적용 완료

## 위험도

- OpponentLogo / mini preview / 카드 래핑: **Shell** (UI 전용)
- squircle 제거: **Shell** (시각 변경만, 분석기 통과)
- 경기 삭제 (Repo + UI + RLS): **Core** (DB 영구 삭제, RLS 정책 변경)

## 확인 필요 (Core 영역)

- [x] `matches_delete` 정책이 admin 만 허용하는지 (확인됨: 기존 `matches_update` 와 동일 조건)
- [x] 자식 테이블 cascade 삭제가 의도한 동작인지 (`match_participations`/`quarter_lineups`/`match_stats` 모두 `on delete cascade` — 확인됨)
- [ ] 실제 admin 계정으로 삭제 테스트 (운영자 검증 필요)
