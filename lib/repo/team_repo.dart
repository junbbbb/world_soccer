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
  Future<Team> create({
    required String name,
    String? logoUrl,
    String? logoColor,
    String? description,
  });

  /// 팀 정보 수정 (null 이 아닌 필드만 반영).
  Future<Team> updateInfo({
    required String teamId,
    String? name,
    String? logoUrl,
    String? logoColor,
    String? description,
  });

  /// 팀 가입.
  Future<void> join({required String teamId, required String playerId});

  /// 팀 탈퇴 (본인 또는 admin 이 멤버 제거).
  Future<void> leave({required String teamId, required String playerId});

  /// 팀 로고 이미지 업로드. Storage 에 저장하고 public URL 반환.
  ///
  /// [bytes] 이미지 바이트, [extension] 예: 'jpg', 'png', 'webp'.
  /// admin 만 업로드 가능 (RLS 로 강제).
  Future<String> uploadLogo({
    required String teamId,
    required List<int> bytes,
    required String extension,
  });

  /// 팀 통계.
  Future<TeamStats> getStats(String teamId);

  /// 초대 코드 생성.
  Future<String> createInviteCode({
    required String teamId,
    String role = 'member',
  });

  /// 초대 코드로 팀 가입.
  /// 반환: {'team_id': '...', 'team_name': '...', 'role': '...'}
  Future<Map<String, dynamic>> joinByInviteCode(String inviteCode);
}
