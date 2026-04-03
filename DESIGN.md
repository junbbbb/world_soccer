# Design Guide - FC칼로 앱

홈 화면과 경기 상세 화면에서 추출한 실제 디자인 패턴.
모든 새 화면은 이 가이드를 따라야 한다.

---

## 페이지 구조

### 배경색
- 페이지 배경: `Colors.white` (또는 Scaffold 기본)
- 구분선 배경: 없음 (white 위에 카드/리스트로 구성)

### 헤더 (Frosted Glass, Pinned)
```
blur: ImageFilter.blur(sigmaX: 20, sigmaY: 20)
color: Colors.white.withValues(alpha: 0.85)
padding: top(topPadding + sm), h(lg), bottom(base)
logo: 32x32 (clip 없음)
title: AppTextStyles.pageTitle, AppColors.textPrimary
```
- 탭바가 있으면 헤더 하단에 TabBar 추가 (총 높이 ~108px)
- 탭바가 없으면 높이 ~56px

### 섹션 구조
```
SectionTitle (좌측 제목 + 우측 trailing)
  ↓ 콘텐츠 (카드 or 리스트)
SizedBox(height: xxl=32)  ← 섹션 간 간격

[섹션 구분이 필요하면]
Container(height: 12, color: AppColors.surface)
SizedBox(height: xxl=32)
```

---

## 카드 스타일 (핵심!)

### 콘텐츠 카드 (경기, 스탯 테이블 등)
```dart
Container(
  padding: EdgeInsets.all(AppSpacing.base),       // 내부 패딩
  margin: EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,                     // 좌우 20
    vertical: 6,                                   // 카드 간 간격
  ),
  decoration: ShapeDecoration(
    color: AppColors.surfaceLight,                 // #F6F7F9
    shape: SmoothRectangleBorder(
      borderRadius: AppRadius.smoothLg,            // 16px squircle
    ),
    // border 없음! side 없음!
  ),
)
```

**절대 하지 말 것:**
- ~~`side: BorderSide(color: AppColors.surface, width: 1)`~~ — 선 없는 디자인
- ~~`color: Colors.white` + border~~ — surfaceLight 배경으로 구분감

### 프롬프트/알림 카드
```dart
color: AppColors.primary.withValues(alpha: 0.06)  // 브랜드 틴트
shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothMd)
```

### 히어로 카드 (다음 경기)
```dart
color: AppColors.primary                           // 브랜드 솔리드
borderRadius: AppRadius.md                         // ClipRRect
```

---

## 리스트 아이템 스타일

### 카드형 리스트 (경기 리스트)
각 아이템이 독립된 카드:
```
margin: h(lg=20), v(6)
padding: h(base=16), v(base=16)
배경: AppColors.surfaceLight
라운딩: AppRadius.smoothLg
선: 없음
```

### 플랫 리스트 (게시물, 스탯 행)
카드 안에서 divider로 구분:
```
padding: v(base=16)
구분선: Divider(height: 1, color: textPrimary.withAlpha(0.06))
마지막 아이템 하단 divider 생략
```

---

## 뱃지 스타일

**공통 규칙:**
- 아이콘 넣지 않음 (텍스트만)
- 글자색 = 배경색의 진한 버전
- 각 뱃지는 서로 다른 색을 사용
- 한 화면에 메인 컬러 3개 이하로 제한

### 결과 뱃지 (승/무/패) — 각각 고유 색상
```
라운딩: AppRadius.smoothFull (캡슐)
padding: h(10), v(3)
승: bg=#E8F4FD  text=#1572D1 (파란)
무: bg=#F2F4F6  text=#6B7684 (회색)
패: bg=#FDECEC  text=#E5484D (빨강)
```

### 상태 뱃지 (참가/미참가)
```
참가: bg=#E8F4FD  text=#1572D1 (primary 계열)
미참가: bg=#F2F4F6  text=#8E97A3 (surface 계열)
```

### 칭호 뱃지 (MOM, 득점왕 등) — 동일 패턴
```
bg=연한 배경  text=진한 글자  (아이콘/이모지 없음)
예: MOM → bg=#FFF8E1 text=#F57F17
```

### 캡슐 태그 (최근 전적, 카테고리)
```
배경: AppColors.surfaceLight
라운딩: AppRadius.smoothSm
padding: h(xl=24), v(10)
```

---

## 장식 최소화 원칙

- 원이나 사각형 안에 억지로 글자를 넣지 않는다 (뱃지처럼 꼭 필요한 것만)
- 불필요한 아이콘 장식을 넣지 않는다
- 숫자 순위는 텍스트로 충분하다 (원형 배경 불필요)
- 한 화면에 3개 이상의 메인 컬러를 사용하지 않는다

---

## 여백 규칙 (AppSpacing 토큰)

| 용도 | 토큰 | 값 |
|------|------|-----|
| 페이지 좌우 | paddingPage (h: lg) | 20 |
| 섹션 간 | xxl | 32 |
| 카드 내부 | base | 16 |
| 카드 간 세로 | (하드코딩) | 6 |
| 아이콘↔텍스트 | sm | 8 |
| 행 간격 | md | 12 |
| 섹션 구분선 높이 | (하드코딩) | 12 |
| 하단 스크롤 여유 | xxxl~xxxxl | 48~80 |

---

## 텍스트 적용 규칙

| 용도 | 스타일 | 색상 |
|------|--------|------|
| 페이지 제목 | pageTitle (SCDream 20/w700) | textPrimary |
| 섹션 제목 | sectionTitle (20/w700) | textPrimary |
| 카드 내 제목 | heading (16/w700) | textPrimary |
| 팀명/라벨 | label (14/w700) | textPrimary |
| 본문 | body (15/w500) | textPrimary |
| 보조 텍스트 | body / captionMedium | textSecondary |
| 날짜/부가 | caption (12/w400) | textTertiary |
| 스코어 | sectionTitle (20/w700) | textPrimary |

---

## 라운딩 규칙

| 용도 | 토큰 | 값 |
|------|------|-----|
| 콘텐츠 카드 | smoothLg | 16 |
| 버튼/컨테이너 | smoothMd | 12 |
| 뱃지/캡슐 | smoothFull | 100 |
| 팀 로고 | smoothXs | 4 |
| 아바타 | smoothSm | 8 |

---

## 색상 용도

| 토큰 | 용도 |
|------|------|
| surfaceLight (#F6F7F9) | 카드 배경, 캡슐 배경 |
| surface (#F2F4F6) | 섹션 구분선, 비활성 뱃지 배경 |
| primary (#1572D1) | CTA, 승리 뱃지, 브랜드 강조 |
| primary.withAlpha(0.06~0.1) | 프롬프트 카드, 참가 뱃지 |
| textPrimary (#333D4B) | 기본 텍스트, 아이콘 |
| textSecondary (#6B7684) | 보조 텍스트, 값 |
| textTertiary (#8E97A3) | 날짜/시간, 비활성 |
| textPrimary.withAlpha(0.06) | 플랫 리스트 divider |
