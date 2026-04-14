import '../types/enums.dart';
import '../types/match.dart';
import '../types/player.dart';

/// 선수/참가 저장소 인터페이스.
abstract class PlayerRepo {
  /// 선수 정보 조회.
  Future<Player> getById(String playerId);

  /// 활성 팀 설정 (홈에서 어느 팀을 보여줄지).
  Future<void> setActiveTeam({
    required String playerId,
    required String teamId,
  });

  /// 활성 팀 조회 (null 가능 — 아직 선택 안 함).
  Future<String?> getActiveTeamId(String playerId);

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
