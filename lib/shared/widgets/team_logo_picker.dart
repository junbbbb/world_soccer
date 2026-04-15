import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'team_logo_view.dart' show extensionFromPath;

typedef PickedLogoImage = ({Uint8List bytes, String ext});

/// 갤러리에서 팀 로고 이미지 선택. 취소/에러 시 null.
/// 에러는 호출자 화면의 SnackBar 로 표시, 성공 시 햅틱 피드백.
Future<PickedLogoImage?> pickTeamLogoImage(BuildContext context) async {
  try {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
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
