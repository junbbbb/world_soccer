/// 팀 모델.

import 'enums.dart';

class Team {
  final String id;
  final String name;
  final String? logoUrl;
  final DateTime createdAt;

  const Team({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.createdAt,
  });
}

/// 팀 멤버십 (다대다 관계).
class TeamMember {
  final String teamId;
  final String playerId;
  final TeamRole role;
  final DateTime joinedAt;

  // UI 표시용 조인 필드 (nullable)
  final String? playerName;
  final String? playerAvatarUrl;
  final int? playerNumber;
  final String? playerPosition;

  const TeamMember({
    required this.teamId,
    required this.playerId,
    required this.role,
    required this.joinedAt,
    this.playerName,
    this.playerAvatarUrl,
    this.playerNumber,
    this.playerPosition,
  });
}

/// 팀 통계 (집계 뷰).
class TeamStats {
  final int totalMatches;
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;
  final int cleanSheets;

  const TeamStats({
    required this.totalMatches,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.cleanSheets,
  });

  double get winRate => totalMatches > 0 ? wins / totalMatches : 0;
  double get avgGoalsFor => totalMatches > 0 ? goalsFor / totalMatches : 0;
  double get avgGoalsAgainst =>
      totalMatches > 0 ? goalsAgainst / totalMatches : 0;
}
