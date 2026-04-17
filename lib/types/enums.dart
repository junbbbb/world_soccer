/// 공통 enum 정의.

/// 포지션 그룹 (라인업 분배용).
enum PositionGroup {
  gk('GK'),
  df('DF'),
  mf('MF'),
  fw('FW');

  const PositionGroup(this.label);
  final String label;
}

/// 세부 포지션 (참가 신청용).
enum Position {
  gk('GK', PositionGroup.gk),
  lb('LB', PositionGroup.df),
  cb('CB', PositionGroup.df),
  rb('RB', PositionGroup.df),
  dm('DM', PositionGroup.mf),
  cm('CM', PositionGroup.mf),
  am('AM', PositionGroup.mf),
  lw('LW', PositionGroup.fw),
  st('ST', PositionGroup.fw),
  rw('RW', PositionGroup.fw);

  const Position(this.label, this.group);
  final String label;
  final PositionGroup group;

  static Position? fromLabel(String label) {
    for (final p in Position.values) {
      if (p.label == label) return p;
    }
    return null;
  }
}

/// 경기 결과.
enum MatchResult {
  win('W'),
  draw('D'),
  loss('L');

  const MatchResult(this.code);
  final String code;
}

/// 경기 상태 (DB 저장용).
enum MatchStatus {
  upcoming,
  completed,
  cancelled,
  earlyEnded,
}

/// 경기 표시 상태 (UI 계산용, DB에 저장하지 않음).
enum MatchDisplayState {
  upcoming,
  inProgress,
  ended,       // 종료됐으나 결과 미입력
  completed,
  cancelled,
  earlyEnded,
}

/// 팀 내 역할 (3단계).
enum TeamRole {
  admin,     // 운영진: 경기 생성, 라인업 편성, 결과 입력, 멤버 관리
  member,    // 일반유저: 참가 신청, 조회, 프로필 관리
  mercenary, // 용병: 조회만, 가입 후 기록 쌓기 시작
}

/// 주발.
enum PreferredFoot {
  right('오른발'),
  left('왼발'),
  both('양발');

  const PreferredFoot(this.label);
  final String label;

  static PreferredFoot? fromLabel(String label) {
    for (final f in PreferredFoot.values) {
      if (f.label == label) return f;
    }
    return null;
  }
}

/// 시즌 반기.
///
/// - `label` = UI/뷰(`season_player_stats.half`) 용 한글
/// - `dbCode` = RPC 파라미터 ('H1'/'H2'). i18n 안전
enum SeasonHalf {
  first('상반기', 'H1'),
  second('하반기', 'H2');

  const SeasonHalf(this.label, this.dbCode);
  final String label;
  final String dbCode;
}

/// 랭킹 기준.
enum RankType {
  goals,
  assists,
  mom,
}

/// 반기 뱃지 (팀·반기 1등 카테고리).
///
/// - `label` = UI 표시용 한글
/// - `code` = DB RPC 반환값 (i18n 안전 안정 코드)
///
/// 최소 3경기 출전 + 해당 카테고리 값 > 0 + 공동 1위 포함.
enum PlayerTitle {
  topScorer('득점왕', 'top_scorer'),
  topAssister('어시왕', 'top_assister'),
  topAttendance('출석왕', 'top_attendance'),
  topMom('MOM왕', 'top_mom');

  const PlayerTitle(this.label, this.code);
  final String label;
  final String code;

  static PlayerTitle? fromCode(String code) {
    for (final t in PlayerTitle.values) {
      if (t.code == code) return t;
    }
    return null;
  }
}

/// 라인업 공정성 상태.
enum FairnessStatus {
  unassigned, // 0쿼
  under, //      1쿼
  ok, //         2~3쿼
  full; //       4쿼

  static FairnessStatus fromPlayCount(int playCount) {
    if (playCount <= 0) return unassigned;
    if (playCount == 1) return under;
    if (playCount >= 4) return full;
    return ok;
  }
}

/// 채팅 메시지 읽음 상태.
enum MessageReadStatus { sent, delivered, read }

/// 채팅 메시지 타입.
enum MessageType { text, event }
