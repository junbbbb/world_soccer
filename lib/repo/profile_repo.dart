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

  /// 아바타 이미지 업로드. public URL 반환.
  ///
  /// [bytes] 이미지 바이트, [extension] 예: 'jpg', 'png', 'webp'.
  /// 본인 폴더(`{playerId}/`) 에만 쓸 수 있도록 RLS 로 강제됨.
  Future<String> uploadAvatar({
    required String playerId,
    required List<int> bytes,
    required String extension,
  });
}
