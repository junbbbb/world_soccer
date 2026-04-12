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
}

/// 경기 결과.
enum MatchResult {
  win('W'),
  draw('D'),
  loss('L');

  const MatchResult(this.code);
  final String code;
}

/// 경기 상태.
enum MatchStatus {
  upcoming,
  completed,
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
}

/// 시즌 반기.
enum SeasonHalf {
  first('상반기'),
  second('하반기');

  const SeasonHalf(this.label);
  final String label;
}

/// 랭킹 기준.
enum RankType {
  goals,
  assists,
  mom,
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
