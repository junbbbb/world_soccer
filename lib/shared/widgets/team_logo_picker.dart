import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'team_logo_view.dart' show extensionFromPath;

typedef PickedLogoImage = ({Uint8List bytes, String ext});

/// 갤러리에서 이미지 선택. 취소/에러 시 null.
/// 에러는 호출자 화면의 SnackBar 로 표시, 성공 시 햅틱 피드백.
///
/// 팀 로고 기본값은 512/85. 프로필은 크롭 단계가 뒤에 붙으므로 1500/92 권장.
Future<PickedLogoImage?> pickTeamLogoImage(
  BuildContext context, {
  int maxWidth = 512,
  int maxHeight = 512,
  int imageQuality = 85,
}) async {
  try {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: maxWidth.toDouble(),
      maxHeight: maxHeight.toDouble(),
      imageQuality: imageQuality,
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    HapticFeedback.selectionClick();
    return (bytes: bytes, ext: extensionFromPath(file.path));
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('사진을 불러오지 못했어요: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    return null;
  }
}
