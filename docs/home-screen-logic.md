# 홈 화면 로직 정리

> 최종 수정: 2026-04-13

---

## 화면 구조 (위→아래)

```
┌─────────────────────────────────┐
│  블러 헤더 (팀 로고·팀명 / 프로필) │  ← 고정, 투명 블러
├─────────────────────────────────┤
│                                 │
│  NextMatchCard                  │  ← 메인 카드
│  (VS 영역 + 참가하기 버튼)       │
│                                 │
├─────────────────────────────────┤
│  결과 입력 알림 카드 (조건부)      │  ← 슬라이드인 애니메이션
├─────────────────────────────────┤
│  최근 전적 (가로 스크롤)          │
├─────────────────────────────────┤
│  ──── 12px 구분선 ────          │
├─────────────────────────────────┤
│  팀 게시물                       │
└─────────────────────────────────┘
```

---

## 1. 다음 경기 카드 (NextMatchCard)

### 1-1. 어떤 경기를 보여줄 것인가 — `_pickHomeMatch()`

전체 경기 목록에서 **하나의 경기**를 골라 홈 카드에 표시한다.

```
입력: 팀의 전체 경기 리스트
  ↓
Step 1. isVisibleOnHome == true 인 것만 필터
  ↓
Step 2. 두 그룹으로 분리
  - [예정/진행] upcoming · inProgress → 날짜 오름차순 → 가장 가까운 것
  - [종료됨]    ended · earlyEnded · completed → 날짜 내림차순 → 가장 최근 것
  ↓
Step 3. 선택
  - 예정만 있음 → 예정 경기 표시
  - 종료만 있음 → 종료 경기 표시
  - 둘 다 있음 → 아래 규칙
```

**둘 다 있을 때 우선순위:**

| 조건 | 표시 |
|------|------|
| 다음 경기 시작 시간 < 종료 경기의 visibilityDeadline | **다음 경기** (같은날/다음날 아침 경기) |
| 다음 경기 시작 시간 >= 종료 경기의 visibilityDeadline | **종료 경기** (결과 카드 유지) |

> 예: 토요일 18시 경기 종료 → deadline은 일요일 06시.
> 일요일 09시에 다음 경기 있으면 → deadline(06시) 이후라 → 종료 경기 유지 (X)
> → 이 경우 일요일 06시가 지나면 종료 경기가 사라지고 일요일 09시 경기가 자동으로 뜸.
>
> 토요일 23시에 다음 경기 있으면 → deadline(일요일 06시) 이전 → 다음 경기 표시.

### 1-2. 경기 표시 기한 — `isVisibleOnHome`

| displayState | 홈 카드 표시 |
|---|---|
| `upcoming` | 항상 표시 |
| `inProgress` | 항상 표시 |
| `ended` (시간 지남, 결과 미입력) | `visibilityDeadline`까지 |
| `earlyEnded` (조기 종료) | `visibilityDeadline`까지 |
| `completed` (결과 입력 완료) | `visibilityDeadline`까지 |
| `cancelled` | 표시 안 함 |

**핵심: 결과를 입력해도 바로 사라지지 않는다.** 경기날 다음날 아침 6시까지 유지.

### 1-3. visibilityDeadline 계산

```
경기 날짜가 D일이고 endTime이 자정(00시) 이후~06시 이전이면:
  → endTime 당일 06시
그 외:
  → D+1일 06시
```

| 경기 시작 | duration | endTime | deadline |
|-----------|----------|---------|----------|
| 토 18:00 | 120분 | 토 20:00 | **일 06:00** |
| 토 23:00 | 120분 | 일 01:00 | **일 06:00** |
| 일 02:00 | 120분 | 일 04:00 | **일 06:00** |

### 1-4. displayState 결정 로직

DB에 저장되는 `MatchStatus`와 현재 시간을 조합하여 UI용 `MatchDisplayState`를 산출.

```dart
if (status == cancelled)  → cancelled
if (status == earlyEnded) → earlyEnded
if (status == completed)  → completed
if (now < 경기시작)        → upcoming
if (now < endTime)        → inProgress
else                      → ended
```

| MatchStatus (DB) | MatchDisplayState (UI) | 설명 |
|---|---|---|
| `upcoming` + 시작 전 | `upcoming` | 예정 |
| `upcoming` + 진행 중 | `inProgress` | 진행 중 |
| `upcoming` + 시간 경과 | `ended` | 종료, 결과 미입력 |
| `completed` | `completed` | 결과 입력 완료 |
| `cancelled` | `cancelled` | 취소 |
| `earlyEnded` | `earlyEnded` | 조기 종료 |

### 1-5. 카드 UI 상태별 차이

| displayState | 스코어 표시 | 참가하기 버튼 | 배지 |
|---|---|---|---|
| `upcoming` | 시간 표시 | 표시 | `0/16명` + H2H |
| `inProgress` | 시간 표시 | 표시 | `진행 중` + H2H |
| `ended` | 시간 표시 | 숨김 | `경기 종료` + H2H |
| `earlyEnded` | 시간 표시 | 숨김 | `경기 종료` + H2H |
| `completed` | 스코어 표시 | 숨김 | `완료` + H2H |
| 없음 | — | — | `_EmptyMatchCard` (일정 추가 유도) |

참가 완료 상태에서는 버튼이 `AnimatedSize`로 접히고 `참가완료` 배지 추가.

### 1-6. 배지 (InfoCapsule) 규칙 — `buildMatchBadges()`

**1번째 배지: 상태**

| displayState | 텍스트 |
|---|---|
| `upcoming` | `0/16명` |
| `inProgress` | `진행 중` |
| `ended` / `earlyEnded` | `경기 종료` |
| `completed` | `완료` |
| `cancelled` | `취소` |

**2번째 배지: 상대 전적 (H2H)**

같은 상대와의 과거 `completed` 경기를 조회하여 가장 최근 결과 기반:

| 조건 | 텍스트 |
|---|---|
| 과거 경기 없음 | `첫 매치` |
| 마지막 경기 패배 | `리벤지 매치` |
| 마지막 경기 승리 | `연승 도전` |
| 마지막 경기 무승부 | `재대결` |

---

## 2. 결과 입력 알림 카드

NextMatchCard 바로 아래에 조건부로 표시되는 알림 카드.

### 표시 조건

**실제 데이터 모드:**
```
경기 중 (ended 또는 earlyEnded) && 결과 미입력(!hasResult) 인 것이 있으면
→ 가장 최근 것의 "vs {상대팀} 결과 입력" 카드 표시
```

**더미 데이터 모드:**
```
hasNextMatch && !dismissed → 제네릭 "경기 결과 입력" 카드 표시
```

### 동작
- 탭 → `MatchResultInputScreen`으로 이동 (matchId, opponentName 전달)
- X 버튼 → `_isResultCardDismissed = true` (세션 동안 숨김)

### 애니메이션
- 400ms 딜레이 후 등장 (initState에서 예약)
- `AnimatedSlide`: Y 0.3 → 0 (아래→위 슬라이드)
- `AnimatedOpacity`: 0 → 1
- duration: 350ms, curve: `easeOutCubic`

---

## 3. 최근 전적 섹션 (TeamRecentResultsSection)

### 데이터
```
status == completed 인 경기 → 날짜 내림차순 → 최근 5개
```

### 표시
- **결과 있음**: 가로 스크롤 캡슐 리스트
  - 각 캡슐: 결과(승/패/무) + 스코어(`3 - 1`) + 상대 로고
- **결과 없음**: "첫 기록 추가하기" 버튼 → `/match/result-input`

---

## 4. 팀 게시물 섹션 (TeamPostsSection)

### 실제 모드
- 봇 메시지 1건: "{{팀명}} 팀이 생성되었습니다! 팀원들에게 초대 코드를 공유하고, 첫 경기 일정을 만들어보세요."

### 더미 모드
- 4건의 샘플 포스트 (아바타, 이름, 본문, 좋아요, 댓글 수)

---

## 5. 블러 헤더

- 고정 위치 (Positioned top: 0)
- `BackdropFilter` blur(20, 20) + 흰색 85% 배경
- 좌측: 팀 로고(32px) + 팀명 + 드롭다운 화살표 → 탭 시 팀 전환 시트
- 우측: 프로필 아이콘(32px) → `/profile`
  - 프로필 미완성 시 우상단 빨간 점(10px) 표시

---

## 6. 팀 전환 시트 (_TeamSwitcherSheet)

- 바텀시트로 표시
- 소속 팀 리스트 (현재 팀에 체크 표시)
- "새 팀 참가하기" 버튼

---

## 시나리오별 홈 화면 상태

### A. 경기 없음
```
[빈 카드: "예정된 경기가 없습니다" + 추가 버튼]
[최근 전적: "첫 기록 추가하기"]
[게시물: 봇 환영 메시지]
```

### B. 다음 경기 예정
```
[NextMatchCard: VS + 시간 + "참가하기" 버튼]
[최근 전적: 캡슐 or 빈 상태]
[게시물]
```

### C. 경기 진행 중
```
[NextMatchCard: VS + 시간 + "진행 중" 배지]
[최근 전적]
[게시물]
```

### D. 경기 종료, 결과 미입력
```
[NextMatchCard: VS + "경기 종료" 배지, 버튼 숨김]
[결과 입력 알림: "vs 상대팀 결과 입력"]     ← 400ms 슬라이드인
[최근 전적]
[게시물]
```

### E. 경기 종료, 결과 입력 완료
```
[NextMatchCard: 스코어 + "완료" 배지, 버튼 숨김]  ← 다음날 06시까지 유지
[최근 전적: 방금 입력한 결과 포함]
[게시물]
```

### F. 결과 입력 완료 + 다음 경기가 같은날/다음날 아침
```
[NextMatchCard: 다음 경기 표시 (예정)]           ← 다음 경기 우선
[최근 전적: 이전 결과 포함]
[게시물]
```

### G. 다음날 06시 경과
```
종료/완료 경기 → isVisibleOnHome = false → 카드에서 제거
다음 예정 경기가 있으면 그것을 표시, 없으면 빈 카드
```

---

## 데이터 흐름

```
Supabase (matches 테이블)
  ↓
SupabaseMatchRepo.getByTeam()    ← 날짜 DESC 정렬
  ↓
teamMatchesProvider (Riverpod)   ← watch로 실시간 반영
  ↓
HomeTab                          ← hasNextMatch 판단
  ├── NextMatchCard              ← _pickHomeMatch() 로 경기 선택
  ├── 결과 입력 알림              ← ended/earlyEnded + !hasResult 필터
  └── TeamRecentResultsSection   ← completed 경기 최근 5개
```

---

## 핵심 규칙 요약

1. **결과 입력해도 카드 유지** — `completed` 상태도 `visibilityDeadline`까지 표시
2. **deadline = 경기날 다음날 06시** — 자정 넘긴 경기는 당일 06시
3. **다음 경기 우선** — 같은날/다음날 아침에 경기가 있으면 그것을 표시
4. **취소된 경기는 표시 안 함** — `cancelled`는 항상 `isVisibleOnHome = false`
5. **결과 미입력 알림은 별도** — NextMatchCard 아래에 독립적으로 표시
