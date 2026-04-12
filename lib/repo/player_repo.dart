import '../types/enums.dart';
import '../types/match.dart';
import '../types/player.dart';

/// 선수/참가 저장소 인터페이스.
abstract class PlayerRepo {
  /// 선수 정보 조회.
  Future<Player> getById(String playerId);

  /// 경기 참가 신청.
  Future<void> joinMatch({
    required String matchId,
    required String playerId,
    required List<Position> preferredPositions,
    required List<int> availableQuarters,
  });

  /// 경기 참가 취소.
  Future<void> leaveMatch({
    required String matchId,
    required String playerId,
  });

  /// 경기 참가자 목록.
  Future<List<MatchParticipation>> getParticipations(String matchId);
}
