import '../repo/match_repo.dart';
import '../repo/player_repo.dart';
import '../types/enums.dart';
import '../types/match.dart';

/// 경기 비즈니스 로직.
class MatchService {
  final MatchRepo matchRepo;
  final PlayerRepo playerRepo;

  MatchService({required this.matchRepo, required this.playerRepo});

  /// 예정 경기 목록.
  Future<List<Match>> getUpcomingMatches(String teamId) async {
    final all = await matchRepo.getByTeam(teamId);
    return all.where((m) => m.status == MatchStatus.upcoming).toList();
  }

  /// 완료 경기 목록.
  Future<List<Match>> getCompletedMatches(String teamId) async {
    final all = await matchRepo.getByTeam(teamId);
    return all.where((m) => m.status == MatchStatus.completed).toList();
  }

  /// 경기 결과 입력.
  Future<void> submitResult({
    required String matchId,
    required int ourScore,
    required int opponentScore,
  }) {
    if (ourScore < 0 || opponentScore < 0) {
      throw ArgumentError('스코어는 음수일 수 없습니다');
    }
    return matchRepo.updateResult(
      matchId: matchId,
      ourScore: ourScore,
      opponentScore: opponentScore,
    );
  }

  /// 경기 참가 신청.
  Future<void> joinMatch({
    required String matchId,
    required String playerId,
    required List<Position> preferredPositions,
    required List<int> availableQuarters,
  }) {
    if (preferredPositions.isEmpty) {
      throw ArgumentError('선호 포지션을 최소 1개 선택해야 합니다');
    }
    if (availableQuarters.isEmpty) {
      throw ArgumentError('참가 가능 쿼터를 최소 1개 선택해야 합니다');
    }
    return playerRepo.joinMatch(
      matchId: matchId,
      playerId: playerId,
      preferredPositions: preferredPositions,
      availableQuarters: availableQuarters,
    );
  }

  /// 경기 참가 취소.
  Future<void> leaveMatch({
    required String matchId,
    required String playerId,
  }) {
    return playerRepo.leaveMatch(matchId: matchId, playerId: playerId);
  }

  /// 상대 전적 (H2H) 요약.
  Future<H2HSummary> getH2HSummary({
    required String teamId,
    required String opponentName,
  }) async {
    final matches = await matchRepo.getH2H(
      teamId: teamId,
      opponentName: opponentName,
    );

    var wins = 0, draws = 0, losses = 0;
    for (final m in matches) {
      final r = m.result;
      if (r == MatchResult.win) {
        wins++;
      } else if (r == MatchResult.draw) {
        draws++;
      } else if (r == MatchResult.loss) {
        losses++;
      }
    }

    return H2HSummary(
      wins: wins,
      draws: draws,
      losses: losses,
      totalMatches: matches.length,
    );
  }
}
