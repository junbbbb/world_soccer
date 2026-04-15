/// 경기 모델.

import 'enums.dart';

class Match {
  final String id;
  final String teamId;
  final DateTime date;
  final int durationMinutes;
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
    this.durationMinutes = 120,
    required this.location,
    required this.opponentName,
    this.opponentLogoUrl,
    this.ourScore,
    this.opponentScore,
    required this.status,
    required this.createdAt,
  });

  /// 경기 종료 시각.
  DateTime get endTime => date.add(Duration(minutes: durationMinutes));

  /// 결과 입력 완료 여부.
  bool get hasResult => ourScore != null && opponentScore != null;

  /// 다음날 오전 6시 — 홈 카드 유지 기준.
  DateTime get visibilityDeadline {
    final nextDay = DateTime(date.year, date.month, date.day + 1, 6);
    // 종료 시간이 자정 이후면 그 날 오전 6시
    if (endTime.hour >= 0 && endTime.hour < 6) {
      return DateTime(endTime.year, endTime.month, endTime.day, 6);
    }
    return nextDay;
  }

  /// UI 표시용 상태 (현재 시간 기반).
  MatchDisplayState get displayState {
    if (status == MatchStatus.cancelled) return MatchDisplayState.cancelled;
    if (status == MatchStatus.earlyEnded) return MatchDisplayState.earlyEnded;
    if (status == MatchStatus.completed) return MatchDisplayState.completed;

    final now = DateTime.now();
    if (now.isBefore(date)) return MatchDisplayState.upcoming;
    if (now.isBefore(endTime)) return MatchDisplayState.inProgress;
    return MatchDisplayState.ended;
  }

  /// 홈 카드에 표시 가능 여부 (종료/결과입력 후 다음날 06시까지).
  bool get isVisibleOnHome {
    final now = DateTime.now();
    final ds = displayState;
    if (ds == MatchDisplayState.upcoming ||
        ds == MatchDisplayState.inProgress) {
      return true;
    }
    // 종료됨 / 조기종료 / 결과입력 완료 — 다음날 06시까지 유지
    if (ds == MatchDisplayState.ended ||
        ds == MatchDisplayState.earlyEnded ||
        ds == MatchDisplayState.completed) {
      return now.isBefore(visibilityDeadline);
    }
    return false;
  }

  /// 경기탭 "종료" 분류 여부.
  bool get isFinished =>
      displayState != MatchDisplayState.upcoming &&
      displayState != MatchDisplayState.inProgress;

  bool get isPast => isFinished;

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

  /// 1-indexed 쿼터 번호 (1~4). DB `match_participations.available_quarters` 와 동일.
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
