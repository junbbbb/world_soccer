/// 경기 모델.

import 'enums.dart';

class Match {
  final String id;
  final String teamId;
  final DateTime date;
  final String location;
  final String opponentName;
  final String? opponentLogoUrl;
  final int? ourScore;
  final int? opponentScore;
  final MatchStatus status;
  final DateTime createdAt;

  const Match({
    required this.id,
    required this.teamId,
    required this.date,
    required this.location,
    required this.opponentName,
    this.opponentLogoUrl,
    this.ourScore,
    this.opponentScore,
    required this.status,
    required this.createdAt,
  });

  bool get isPast => status == MatchStatus.completed;

  MatchResult? get result {
    if (ourScore == null || opponentScore == null) return null;
    if (ourScore! > opponentScore!) return MatchResult.win;
    if (ourScore! < opponentScore!) return MatchResult.loss;
    return MatchResult.draw;
  }

  String get dayOfWeek {
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return days[date.weekday - 1];
  }

  String get timeString {
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

/// 경기 참가 신청.
class MatchParticipation {
  final String matchId;
  final String playerId;
  final List<Position> preferredPositions;
  final List<int> availableQuarters; // 1-indexed

  // UI 표시용 조인 필드
  final String? playerName;
  final String? playerAvatarUrl;
  final int? playerNumber;

  const MatchParticipation({
    required this.matchId,
    required this.playerId,
    required this.preferredPositions,
    required this.availableQuarters,
    this.playerName,
    this.playerAvatarUrl,
    this.playerNumber,
  });
}

/// 선수별 경기 기록.
class PlayerMatchStats {
  final String matchId;
  final String playerId;
  final int goals;
  final int assists;
  final bool isMom;

  // UI 표시용 조인 필드
  final String? playerName;
  final String? playerAvatarUrl;

  const PlayerMatchStats({
    required this.matchId,
    required this.playerId,
    this.goals = 0,
    this.assists = 0,
    this.isMom = false,
    this.playerName,
    this.playerAvatarUrl,
  });
}

/// 참가 신청 결과 (바텀시트 반환용).
class JoinMatchResult {
  final Set<Position> preferredPositions;
  final Set<int> availableQuarters;

  const JoinMatchResult({
    required this.preferredPositions,
    required this.availableQuarters,
  });
}

/// H2H 전적 요약.
class H2HSummary {
  final int wins;
  final int draws;
  final int losses;
  final int totalMatches;

  const H2HSummary({
    required this.wins,
    required this.draws,
    required this.losses,
    required this.totalMatches,
  });
}
