import '../repo/player_repo.dart';
import '../repo/team_repo.dart';
import '../types/enums.dart';
import '../types/team.dart';

/// 팀 비즈니스 로직.
class TeamService {
  final TeamRepo teamRepo;
  final PlayerRepo playerRepo;

  TeamService({required this.teamRepo, required this.playerRepo});

  /// 팀 탈퇴.
  ///
  /// 규칙:
  /// - 일반 멤버/용병은 언제든 탈퇴 가능.
  /// - admin 이 여러 명이면 admin 도 탈퇴 가능.
  /// - 마지막 admin 이고 다른 멤버가 남아있으면 [LastAdminException].
  /// - 혼자 남은 admin 은 탈퇴 가능 (팀은 빈 상태로 남음).
  /// - 애초에 해당 팀 소속이 아니면 [StateError].
  Future<void> leaveTeam({
    required String teamId,
    required String playerId,
  }) async {
    final members = await teamRepo.getMembers(teamId);
    final me = members.where((m) => m.playerId == playerId).firstOrNull;
    if (me == null) {
      throw StateError('팀 소속이 아닙니다');
    }
    final admins = members.where((m) => m.role == TeamRole.admin).toList();
    final otherMembers =
        members.where((m) => m.playerId != playerId).toList();
    final isLastAdmin = me.role == TeamRole.admin && admins.length == 1;
    if (isLastAdmin && otherMembers.isNotEmpty) {
      throw const LastAdminException();
    }
    await teamRepo.leave(teamId: teamId, playerId: playerId);
  }

  /// 활성 팀 변경. 본인이 소속된 팀이어야 함.
  Future<void> switchTeam({
    required String playerId,
    required String teamId,
  }) async {
    final myTeams = await teamRepo.getMyTeams(playerId);
    final isMember = myTeams.any((t) => t.id == teamId);
    if (!isMember) {
      throw const NotAMemberException();
    }
    await playerRepo.setActiveTeam(playerId: playerId, teamId: teamId);
  }

  /// 새 팀 생성. 기존 팀 소속 여부와 무관.
  Future<Team> createTeam({
    required String name,
    String? logoColor,
    String? description,
  }) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('팀 이름이 비어있습니다');
    }
    final trimmedDesc = description?.trim();
    final desc =
        (trimmedDesc == null || trimmedDesc.isEmpty) ? null : trimmedDesc;
    return teamRepo.create(
      name: trimmedName,
      logoColor: logoColor,
      description: desc,
    );
  }
}

/// 팀의 유일한 admin 이 탈퇴를 시도할 때 발생.
class LastAdminException implements Exception {
  const LastAdminException();

  @override
  String toString() =>
      '마지막 관리자는 탈퇴할 수 없습니다. 다른 멤버를 관리자로 지정하거나 팀을 삭제하세요.';
}

/// 소속되지 않은 팀으로 전환을 시도할 때 발생.
class NotAMemberException implements Exception {
  const NotAMemberException();

  @override
  String toString() => '소속되지 않은 팀으로는 전환할 수 없습니다.';
}
