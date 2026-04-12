import '../types/team.dart';

/// 팀 저장소 인터페이스.
abstract class TeamRepo {
  /// 내가 소속된 팀 목록.
  Future<List<Team>> getMyTeams(String playerId);

  /// 팀 상세.
  Future<Team> getById(String teamId);

  /// 팀 멤버 목록.
  Future<List<TeamMember>> getMembers(String teamId);

  /// 팀 생성.
  Future<Team> create({required String name, String? logoUrl});

  /// 팀 가입.
  Future<void> join({required String teamId, required String playerId});

  /// 팀 통계.
  Future<TeamStats> getStats(String teamId);
}
