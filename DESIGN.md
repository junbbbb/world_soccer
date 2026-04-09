# Design Guide — FC칼로 앱

홈 탭(`home_tab.dart`)과 경기 탭(`match_tab.dart`)의 실제 구현에서 추출한 디자인 시스템.
새로운 화면을 만들 때는 이 가이드의 패턴을 우선 재사용한다.

> **원칙**
> - Airbnb 8px 그리드 → `AppSpacing` 토큰만 사용 (하드코딩 금지, 칩 내부 14/10 같은 컴포넌트 고유값만 예외)
> - squircle `cornerSmoothing: 1.0` → `AppRadius.smoothXx` 캐시 인스턴스 사용
> - 그림자 지양 — 색·면적·여백으로 위계 표현
> - 한 화면에 메인 컬러 3개 이하
> - 색상/텍스트 하드코딩 금지 → `AppColors`, `AppTextStyles` 토큰 사용

---

## 1. 페이지 셸 (Page Shell)

### 1-1. 배경

| 화면 유형 | 배경색 | 사용처 |
|-----------|--------|--------|
| 콘텐츠가 white 카드 위주 | `Colors.white` | 홈 탭 |
| 카드가 떠있는 리스트 | `AppColors.surface` (#F2F4F6) | 경기 탭 |

> **이유**: 매치 카드는 `Colors.white`이므로 동일색 배경 위에 두면 카드가 보이지 않음 → 리스트성 화면은 회색 배경(`surface`) 위에 white 카드를 띄운다.

### 1-2. Frosted Glass Header (Pinned)

홈/경기 탭 모두 동일 패턴. `Stack` 최상단 `Positioned`로 고정한다.

```dart
ClipRect(
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
    child: Container(
      color: <pageBgColor>.withValues(alpha: 0.85), // 페이지 배경색의 85%
      padding: EdgeInsets.only(
        top: topPadding + AppSpacing.sm,    // safe area + 8
        left: AppSpacing.lg,                // 20
        right: AppSpacing.lg,
        bottom: AppSpacing.base,            // 16
      ),
      child: Row(...),
    ),
  ),
)
```

| 요소 | 값 |
|------|-----|
| Blur sigma | `20` (홈/경기 동일) |
| 배경 알파 | `0.85` |
| 본문 시작 offset | `topPadding + 56` (홈) / `topPadding + 64 + sm` (경기) |
| 헤더 높이 상수 | `_headerHeight = 56` 또는 `64` (탭별 정의) |

### 1-3. Header 구성

```
[로고 32x32]  [pageTitle: "FC칼로" / "경기"]      ⟶  [trailing actions]
```

- **로고**: `32×32`, clip 없음 (로고가 squircle 형태이므로 그대로)
- **타이틀**: `AppTextStyles.pageTitle` (SCDream 20 / w700) + `AppColors.textPrimary`
- **로고↔타이틀 간격**: `AppSpacing.sm` (8)
- **trailing**: 우측 정렬, 액션 1~2개. 액션 사이는 `AppSpacing.sm`

#### Trailing 액션 패턴

| 패턴 | 사용 | 스타일 |
|------|------|--------|
| 아이콘 only | 공유, 알림 | SVG `32×32`, `colorFilter: textTertiary` |
| Solid CTA | "일정 만들기" 등 새 항목 만들기 | `bg: primary`, `padding: h:12 v:6`, `smoothSm`, 아이콘+`captionBold` 흰색 |

---

## 2. 컬러 시스템

### 2-1. 토큰 의미

| 토큰 | HEX | 용도 |
|------|-----|------|
| `primary` | `#1572D1` | CTA, 브랜드 히어로, 활성 뱃지, 강조 |
| `primaryDark` | `#1C6EC3` | 그라데이션 시작 |
| `textPrimary` | `#333D4B` | 본문 텍스트, 기본 아이콘 |
| `textSecondary` | `#6B7684` | 보조 텍스트 |
| `textTertiary` | `#8E97A3` | 날짜/시간/비활성, hint |
| `surface` | `#F2F4F6` | 페이지 회색 배경, 비활성 뱃지, 세로 구분선 |
| `surfaceLight` | `#F6F7F9` | 캡슐 칩 배경 |
| `iconInactive` | `#D1D6DB` | 비활성 아이콘, 핸들바, 점선 |
| `error` | `#E5484D` | 패배, 위험 |

### 2-2. 알파 사용 패턴

| 표현 | 구문 |
|------|------|
| 프롬프트/알림 카드 배경 | `primary.withValues(alpha: 0.06)` |
| 활성 뱃지 배경 | `primary.withValues(alpha: 0.08)` |
| DEV 토글 등 약한 강조 | `primary.withValues(alpha: 0.10)` |
| 화살표 / 보조 아이콘 | `primary.withValues(alpha: 0.40)` |
| InfoCapsule (히어로 위) | `Colors.black.withValues(alpha: 0.12)` |
| 플랫 리스트 divider | `textPrimary.withValues(alpha: 0.06)` |

### 2-3. 시맨틱 컬러 (인라인 허용)

뱃지·결과 표시처럼 의미가 고정된 색은 토큰화하지 않고 인라인 hex 사용 (NextMatchCard·MatchTab과 동일).

| 의미 | 배경 | 텍스트 |
|------|------|--------|
| 참가완료 (green) | `#E8F8EE` | `#22A55B` |
| 카카오톡 브랜드 | `#FEE500` | `#3C1E1E` |
| 승 (W) — 향후 통일 | `primary` | `primary` |
| 패 (L) — 향후 통일 | `error` | `error` |

> **규칙**: 새로운 시맨틱 컬러는 4쌍 이상 등장할 때만 `AppColors`에 토큰 등록.

---

## 3. 타이포그래피

`AppTextStyles` 토큰만 사용한다. 색상은 항상 `.copyWith(color: ...)`로 적용.

| 토큰 | 폰트 / 사이즈 / 굵기 | 사용처 (현재 코드 기준) |
|------|---------------------|------------------------|
| `pageTitle` | SCDream 20/w700 | 헤더 타이틀 ("FC칼로", "경기") |
| `sectionTitle` | Pretendard 20/w700 | 섹션 제목 ("최근 전적", "팀 게시물") |
| `heading` | Pretendard 16/w700 | 카드 시간 ("20:00"), 월 헤더 ("2026년 3월"), 빈 카드 메인 카피 |
| `label` | Pretendard 14/w700 | 스코어 |
| `labelMedium` | Pretendard 14/w600 | 프롬프트 카드 텍스트, 팀명 (리스트), 시트 버튼 라벨 |
| `body` | Pretendard 15/w500 | 결과 캡슐 텍스트, 게시물 작성자 |
| `bodyRegular` | Pretendard 15/w400 | 게시물 본문 (`height: 1.5`), 좋아요/댓글 카운트 |
| `caption` | Pretendard 12/w400 | 요일, 장소·인원, 상태 뱃지 |
| `captionBold` | Pretendard 13/w800 | "일정 만들기" CTA |
| `buttonSecondary` | Pretendard 16/w600 | 시트 하단 버튼, 참가하기 버튼 |
| `teamName` | SCDream 14/w700 white | TeamLogoBadge 팀명 (히어로 카드 위) |
| `matchInfo` | SCDream 14/w500 white | 날짜/장소 (히어로 카드 위) |
| `timeDisplay` | Barlow Condensed 36/w800 white | 히어로 카드 시간 ("20:00") |
| `timeBadge` | Pretendard 14/w700 white | 오후/오전 캡슐 |

> **금지**: `Text(..., style: TextStyle(fontSize: 14))` 같은 직접 스타일 생성. 다만 `_ParticipateButton` 같이 토큰화 안 된 일회성 컴포넌트만 예외.

---

## 4. 여백 시스템 (8px 그리드)

`AppSpacing` 토큰만 사용. 명확한 컴포넌트 고유값(예: 칩 패딩 14/10)만 하드코딩 허용.

| 토큰 | 값 | 주요 사용처 |
|------|----|------------|
| `xxs` | 2 | TeamLogoBadge 로고↔팀명 |
| `xs` | 4 | 아이콘↔텍스트(타이트), 작은 갭 |
| `sm` | 8 | 기본 소 간격, 히어로 캡슐 간격, 헤더 로고↔타이틀 |
| `md` | 12 | 행 간 갭, 매치 카드 항목 간 갭 |
| `base` | 16 | 카드 내부 패딩, 헤더 하단 패딩, 카드 간 세로 갭 |
| `lg` | 20 | **페이지 좌우 패딩**, 매치 카드 좌우 패딩 |
| `xl` | 24 | 매치 카드 세로 패딩, 시트 좌우 패딩 |
| `xxl` | 32 | **섹션 간 세로 갭**, NextMatchCard 상단 패딩 |
| `xxxl` | 48 | 빈 카드 큰 여백, 시트 VS 섹션 세로 패딩 |
| `xxxxl` | 80 | 스크롤 하단 여유 (탭바에 가리지 않게) |

### 4-1. 페이지 좌우 패딩

```dart
EdgeInsets.symmetric(horizontal: AppSpacing.lg)  // = 20
```

> **주의**: `AppSpacing.paddingPage`는 `lg` 기반(20)으로 정의되어 있으므로 둘은 동치. 신규 코드도 페이지 좌우 패딩은 `lg`로 통일.

### 4-2. 섹션 간 간격

```dart
SizedBox(height: AppSpacing.xxl)   // 32, 일반 섹션 사이
Container(height: 12, color: AppColors.surface)  // 두꺼운 섹션 구분선
SizedBox(height: AppSpacing.xxl)   // 구분선 뒤 32
```

### 4-3. 카드 간 세로 갭 (리스트)

- **경기 탭**: `EdgeInsets.only(bottom: AppSpacing.md)` (12)
- **홈 탭 카드↔카드**: `SizedBox(height: AppSpacing.base)` (16)

---

## 5. 라운딩 (Squircle)

`SmoothBorderRadius` + `cornerSmoothing: 1.0`. `AppRadius.smoothXx` 캐시 인스턴스만 사용.

| 토큰 | 값 | 사용처 |
|------|-----|--------|
| `smoothXs` | 4 | 팀 로고 클립, 결과 뱃지 |
| `smoothSm` | 8 | **매치 카드**, 결과 캡슐, 아바타, "일정 만들기" 버튼 |
| `smoothMd` | 12 | 프롬프트 카드, 시트 버튼, NextMatchCard `ClipRRect` |
| `smoothLg` | 16 | 시트 티켓 외곽 |
| `smoothXl` | 20 | 바텀시트 상단 |
| `smoothFull` | 100 | InfoCapsule (히어로 위 캡슐) |

> **주의**: `BorderRadius.circular()`도 일부 사용(예: NextMatchCard의 `ClipRRect`는 `BorderRadius.circular(AppRadius.md)`). `ClipRRect`는 `SmoothBorderRadius`를 직접 받지 않으므로 squircle이 필요한 경우 `ClipSmoothRect` 사용.

---

## 6. 핵심 컴포넌트

### 6-1. NextMatchCard (홈 히어로)

다음 경기를 강조하는 풀 와이드 솔리드 블루 카드.

```
┌────────────────────────────────────┐
│  🏷  🏷  [VS Header — primary]      │
│  [팀로고]  20:00  [팀로고]          │
│   FC칼로  2/7(토)…  FC쏘아          │
│       ⬡ 13/16명  ⬡ 참가완료  ⬡ 리벤지매치 │
├──── gradient divider ──────────────┤
│        참가하기  (radial CTA)        │
└────────────────────────────────────┘
```

| 속성 | 값 |
|------|-----|
| 좌우 여백 | `AppSpacing.lg` (20) — `Padding(horizontal:)` |
| 클립 | `ClipRRect(borderRadius: BorderRadius.circular(AppRadius.md))` |
| 상단 영역 색 | `AppColors.primary` |
| 상단 영역 패딩 | `fromLTRB(sm, xxl, sm, xl)` |
| 팀 로고 사이즈 | `52` (`TeamLogoBadge`) |
| 상단 ↔ 캡슐 줄 갭 | `AppSpacing.xl` (24) |
| 캡슐 간 갭 | `AppSpacing.sm` (8) |
| 구분선 | 1px 그라데이션 (`#1572D1 → #1E64AC → #1572D1`) |
| 참가하기 버튼 높이 | `55` |
| 참가하기 배경 | radial gradient `#1869BE → primary` (Y축 압축) |
| 참가하기 텍스트 | Pretendard 16/w600 white |
| 누름 피드백 | `AnimatedOpacity 100ms, 0.7` |

#### Empty 상태 (`_EmptyMatchCard`)

```
[+ 56원형 (white 0.15)]
"예정된 경기가 없습니다"  (heading, white)
"새 경기 일정을 추가해보세요"  (caption, white 0.6)
```

| 속성 | 값 |
|------|-----|
| 좌우 여백 | `AppSpacing.lg` (20) |
| 세로 패딩 | `AppSpacing.xxxl` (48) |
| 배경 | `AppColors.primary` |
| 라운딩 | `BorderRadius.circular(AppRadius.md)` |
| 원형 + 아이콘 | `56×56`, `white 0.15`, 아이콘 `Icons.add_rounded` 32 white |

### 6-2. InfoCapsule (히어로 위 정보 칩)

```dart
padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
color: Colors.black.withValues(alpha: 0.12),
borderRadius: BorderRadius.circular(AppRadius.full),  // 캡슐
text: AppTextStyles.labelRegular.copyWith(color: Colors.white),
```

> 컴포넌트 고유 패딩(10/5)은 하드코딩 허용.

### 6-3. 프롬프트 카드 (`_MatchResultPromptCard`)

탭하면 해당 경기 결과 입력 화면으로 이동하는 약한 강조 카드.

```dart
margin: AppSpacing.paddingPage,                                  // h:20
padding: EdgeInsets.symmetric(horizontal: base, vertical: md),   // 16/12
color: AppColors.primary.withValues(alpha: 0.06),
shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothMd),

[icon edit_rounded 16 primary]  텍스트(labelMedium primary)  ⟶  [chevron 18 primary 0.4]
```

### 6-4. 매치 카드 (`_MatchCard`, 경기 탭)

회색 배경(`surface`) 위에 떠있는 white 카드. 좌측 일자, 우측 정보의 2열 구조.

```
┌─ 일자 ─┬─ 정보 ────────────────────┐
│  21    │  20:00  [참가완료] [예정]  │
│  토    │  성내유수지 · 15/16명      │
│        │  🏷 FC칼로            3   │
│        │  🏷 FC쏘아            1   │
└────────┴───────────────────────────┘
```

| 속성 | 값 |
|------|-----|
| 좌우 마진 | `AppSpacing.lg` (20) — 부모 `Padding`이 처리 |
| 카드 간 갭 | `EdgeInsets.only(bottom: AppSpacing.md)` (12) |
| 배경 | `Colors.white` |
| 라운딩 | `AppRadius.smoothSm` (8) |
| 내부 패딩 | `h: AppSpacing.lg` (20), `v: AppSpacing.xl` (24) |
| 좌측 일자 width | `36` |
| 일자 숫자 | `sectionTitle` (20/w700) `textPrimary` |
| 일자 요일 | `caption` (12/w400) `textTertiary` |
| 구분선 | `width: 1`, `color: surface`, margin `left: sm, right: md` |
| 시간 | `heading` (16/w700) `textPrimary` |
| 장소·인원 | `caption` (12/w400) `textTertiary` (`xs` 위 갭) |
| 시간 ↔ 팀 갭 | `base` (16) |
| 우리팀 ↔ 상대팀 갭 | `md` (12) |

#### 상태 뱃지 (카드 우상단)

| 상태 | 배경 | 텍스트 색 | 코드 |
|------|------|-----------|------|
| 참가완료 | `#E8F8EE` | `#22A55B` | `caption + w700` |
| 예정 | `primary.withAlpha(0.08)` | `primary` | `caption + w700` |
| 완료 | `surface` | `textTertiary` | `caption + w700` |

- 패딩: `h:8 v:3`
- 라운딩: `AppRadius.smoothXs` (4)
- 다중 뱃지일 때 갭: `AppSpacing.xs` (4)

#### TeamRow (카드 내부 팀 행)

```
[로고 22×22 smoothXs]  팀명(labelMedium, ellipsis)  스코어(label)
```

| 속성 | 값 |
|------|-----|
| 로고 | `22×22`, `ClipSmoothRect(radius: smoothXs)` |
| 로고↔팀명 갭 | `AppSpacing.sm` (8) |
| 패배팀 색 | 팀명/스코어 모두 `textTertiary` |
| 승팀 색 | `textPrimary` |

### 6-5. 월 헤더 (`_MonthHeader`)

```
   ←   2026년 3월   →
```

| 속성 | 값 |
|------|-----|
| 정렬 | `MainAxisAlignment.center` |
| 화살표 | `Icons.chevron_left/right_rounded`, `size: 24` |
| 활성 색 | `textPrimary` |
| 비활성 색 | `iconInactive` |
| 화살표 hit padding | `AppSpacing.xs` (4) — `behavior: opaque` |
| 화살표↔타이틀 갭 | `AppSpacing.sm` (8) |
| 타이틀 | `heading` (16/w700) `textPrimary` |
| 하단 갭 | `AppSpacing.base` (16) |
| 인터랙션 | `HapticFeedback.selectionClick()` |

### 6-6. 결과 캡슐 (`_ResultCapsule`, 홈 최근 전적)

가로 스크롤 리스트의 단일 칩.

```
[ 승   3 - 1   🏷 ]
```

| 속성 | 값 |
|------|-----|
| 배경 | `AppColors.surfaceLight` |
| 라운딩 | `AppRadius.smoothSm` |
| 패딩 | `h: AppSpacing.xl (24), v: 10` |
| 텍스트 | `body + w700, textPrimary` |
| 항목 간 갭 | `body 텍스트 ↔ 항목` `AppSpacing.base` (16) |
| 리스트 좌우 패딩 | `AppSpacing.lg` (20) |
| 리스트 항목 사이 | `separated`, `AppSpacing.sm` (8) |
| 리스트 height | `52` |
| 끝 "더보기" | 동일 캡슐 + `chevron 14 textTertiary` |

### 6-7. 게시물 아이템 (`_PostItem`)

플랫 리스트 — divider로만 구분.

```
[아바타 40×40] │ 작성자 (body w700)
              │ 본문 (bodyRegular, height 1.5, max 3줄)
              │ 🤍 5    💬 3
```

| 속성 | 값 |
|------|-----|
| 아바타 | `40×40`, `ClipSmoothRect(smoothSm)` |
| 아바타 ↔ 본문 갭 | `AppSpacing.md` (12) |
| 작성자 ↔ 본문 갭 | `AppSpacing.xs` (4) |
| 본문 ↔ 액션 갭 | `AppSpacing.md` (12) |
| 본문 line-height | `1.5` |
| 본문 최대 줄수 | `3 + ellipsis` |
| 좋아요 아이콘 | `favorite_border_rounded 22 textPrimary` |
| 댓글 아이콘 | `chat_bubble_outline_rounded 20 textPrimary` |
| 아이콘↔숫자 갭 | `AppSpacing.xs` (4) |
| 아이콘 그룹 간 갭 | `AppSpacing.base` (16) |
| 아이템 세로 패딩 | `AppSpacing.base` (16) |
| 아이템 간 divider | `Divider(height: 1, color: textPrimary.withAlpha(0.06))` 마지막 생략 |

### 6-8. 섹션 타이틀 (`SectionTitle`)

```dart
Padding(bottom: AppSpacing.base)  // 내부에 16 포함
Row [Text(sectionTitle, textPrimary), Spacer, trailing?]
```

> **주의**: `SectionTitle` 자체에 `bottom: 16`이 포함되어 있으므로, 외부에서 추가 갭을 주면 이중 간격이 생긴다.

### 6-9. 바텀시트 (`_ShareTicketSheet`) — 패턴 참조

홈 헤더 공유 버튼에서 호출되는 특수 시트지만, 일반 시트 패턴의 기준이 된다.

| 속성 | 값 |
|------|-----|
| 배경 | `AppColors.surface` |
| 상단 라운딩 | `BorderRadius.vertical(top: Radius.circular(AppRadius.xl))` (20) |
| 핸들바 | `width 40, height 4, color iconInactive, radius 2`, `vertical: AppSpacing.md` |
| 좌우 패딩 | `AppSpacing.lg` (20) |
| 하단 액션 영역 | 좌우 1:1 분할, 갭 `AppSpacing.sm` (8) |
| 액션 버튼 | `vertical: base`, `smoothMd`, 좌측 secondary(white) / 우측 카카오(`#FEE500`) |

---

## 7. 인터랙션

| 액션 | 피드백 |
|------|--------|
| 카드 탭 | `GestureDetector` (피드백 없음, 라우팅 즉시) |
| 참가 버튼 누름 | `AnimatedOpacity 100ms → 0.7` |
| 월 이전/다음 | `HapticFeedback.selectionClick()` |
| 참가 토글 | `HapticFeedback.mediumImpact()` |
| 헤더 trailing CTA | `GestureDetector` + 라우팅 |
| 시트 닫기 | `Navigator.pop` |

> **권장**: 새 인터랙티브 카드는 누름 시 `AnimatedOpacity 100~150ms 0.7` 또는 `transform: scale 0.98` 중 하나를 일관되게.

---

## 8. 헤더↔본문 레이아웃 패턴

```dart
Stack(
  children: [
    // 1) 본문 — top 패딩으로 헤더 자리 비워두기
    SingleChildScrollView(
      padding: EdgeInsets.only(top: topPadding + _headerHeight),
      child: Column(...),
    ),
    // 2) 헤더 — Positioned + BackdropFilter (스크롤 위로 떠있음)
    Positioned(top: 0, left: 0, right: 0, child: <GlassHeader>),
  ],
)
```

| 탭 | `_headerHeight` | 본문 top padding |
|----|----------------|------------------|
| 홈 | `56` | `topPadding + 56` |
| 경기 | `64` | `topPadding + 64 + AppSpacing.sm` (월 헤더 위 8 여유) |

---

## 9. 새 화면 만들 때 체크리스트

### 필수
- [ ] 페이지 셸: glass header + Stack 구조 따랐는가?
- [ ] 좌우 패딩: `AppSpacing.lg` (20)?
- [ ] 섹션 간 갭: `AppSpacing.xxl` (32)?
- [ ] 카드 간 갭: 경기 리스트 `md` (12), 일반 `base` (16)?
- [ ] 모든 색상이 `AppColors` 토큰? (시맨틱 인라인 hex 제외)
- [ ] 모든 텍스트가 `AppTextStyles` 토큰? (`copyWith(color:)` 패턴)
- [ ] 모든 라운딩이 `AppRadius.smoothXx` 캐시 인스턴스?
- [ ] 그림자 사용 안 함? (필요시 `AppShadows` 토큰만)

### 위계
- [ ] 한 화면에 메인 컬러 3개 이하?
- [ ] 같은 의미의 뱃지가 같은 색?
- [ ] 카드 안에 카드 안 만듬? (한 레벨까지만)
- [ ] 아이콘 장식 남발 안 함? (텍스트 우선)

### 인터랙션
- [ ] 탭 영역 ≥ 44×44pt?
- [ ] 인터랙티브 카드에 누름 피드백?
- [ ] 중요한 토글에 햅틱 피드백?
- [ ] 월/탭 이동에 selectionClick 햅틱?

### 리스트/스크롤
- [ ] 하단 패딩 `xxxl~xxxxl` (48~80) 줘서 탭바에 안 가림?
- [ ] 회색 배경 리스트 화면이면 카드 색은 `Colors.white`?
- [ ] 헤더가 본문을 가리지 않게 본문에 top 패딩 줬는가?

---

## 10. 절대 하지 말 것 (Anti-patterns)

- 색상/텍스트/여백/라운딩 하드코딩 (토큰을 만들어 사용)
- `BoxShadow` 직접 정의 (필요하면 `AppShadows` 토큰화)
- 카드에 `BorderSide` 추가 — 면+여백으로 위계 표현, 선 없는 디자인 유지
- `Container` 위에 `Container`를 4겹 이상 중첩 — 위젯 추출
- 한 화면에 4가지 이상 메인 컬러
- 결과 캡슐/뱃지 안에 이모지·아이콘 — 텍스트만
- `SectionTitle` 위/아래에 추가 `SizedBox` — 이미 내부 16 포함
- `AppRadius.smooth(값)` 새로 만들어 비표준 값 사용 — 토큰에 추가하거나 가까운 값 사용
- `Colors.white` 카드를 `Colors.white` 배경 위에 — 회색 배경(`surface`)으로 대비 만들기
- 헤더 뒤 본문이 글자가 가려지게 — `topPadding + headerHeight`로 항상 자리 확보
