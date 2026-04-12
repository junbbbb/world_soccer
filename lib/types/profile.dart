/// 프로필/시즌 스탯 모델.

class SeasonStats {
  final int appearances;
  final int goals;
  final int assists;
  final int mom;

  const SeasonStats({
    required this.appearances,
    required this.goals,
    required this.assists,
    required this.mom,
  });
}

/// 최근 경기 퍼포먼스 (프로필 화면용).
class RecentPerformance {
  final String opponent;
  final String? opponentLogoUrl;
  final DateTime date;
  final int goals;
  final int assists;
  final bool isMom;

  const RecentPerformance({
    required this.opponent,
    this.opponentLogoUrl,
    required this.date,
    required this.goals,
    required this.assists,
    required this.isMom,
  });
}

/// 선수 랭킹 항목.
class PlayerRank {
  final String name;
  final String position;
  final String? avatarPath;
  final int value;

  const PlayerRank({
    required this.name,
    required this.position,
    this.avatarPath,
    required this.value,
  });
}
