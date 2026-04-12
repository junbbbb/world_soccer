# Product Specification — 칼로FC

## 사용자

- **주 사용자**: 조기축구 팀원 (20~40대, 주말 축구)
- **관리자**: 감독/팀장 (라인업 편성, 경기 결과 입력)
- **일반 팀원**: 참가 신청, 개인 기록 확인, 프로필 관리

## 핵심 기능 (우선순위)

### 1. 경기 참가 관리
- 홈에서 다음 경기 카드 확인 → 참가하기 (선호 포지션 + 가능 쿼터 선택)
- 감독이 참가자 기반으로 4쿼터 라인업 편성 (드래그앤드롭)
- 자동 분배 알고리즘 (최소 2쿼터 균등 출전)
- 용병 급하게 추가 가능 (이름+포지션만으로)

### 2. 경기 결과 & 개인 기록
- 경기 종료 후 결과 입력 (스코어 + 선수별 골/어시스트)
- 개인 프로필: 시즌(상반기/하반기) 기록 카드 (출전/골/어시/MOM)
- 프로필 카드 인스타 공유 가능
- 상대 전적 (H2H) 조회

### 3. 팀 관리
- 여러 팀 동시 소속 가능 (팀 전환)
- 팀원 목록, 팀 스탯/랭킹
- 팀 채팅 (Telegram 스타일)

## 시즌 구조

- **상반기**: 1~6월
- **하반기**: 7~12월
- 시즌별 기록 아카이브

## 라인업 빌더 특수 요구

- 조기축구 특성: 지각, 급결석, 용병 투입이 빈번
- 4쿼터제: 최소 2쿼터 분배 노력
- 쿼터별 독립 포메이션 (예: 3쿼터만 5백)
- 관리자 전용 (아름다움보다 편리성)

## 데이터 모델 (핵심)

- **Team**: id, name, logo, members
- **Player**: id, name, number, preferredPositions, team, avatar
- **Match**: id, date, location, opponent, ourScore, opponentScore, quarters
- **QuarterLineup**: matchId, quarter, formationIndex, slotToPlayerId
- **PlayerStat**: matchId, playerId, goals, assists, isMom
- **Profile**: playerId, preferredFoot, height, tags, seasonStats

## 비기능 요구

- 오프라인 우선 (경기장 인터넷 불안정)
- 앱 미설치 용병도 라인업에 추가 가능
- 캡처/공유 최적화 (프로필 카드, 라인업 공유)
