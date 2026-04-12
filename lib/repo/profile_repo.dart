import '../types/enums.dart';

/// 프로필 저장소 인터페이스.
/// 조회는 PlayerRepo.getById() 사용. 여기는 수정만.
abstract class ProfileRepo {
  /// 프로필 수정.
  Future<void> update({
    required String playerId,
    String? name,
    int? number,
    String? avatarUrl,
    List<Position>? preferredPositions,
    PreferredFoot? preferredFoot,
    int? height,
  });
}
