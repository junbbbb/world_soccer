import 'package:flutter/material.dart';

import '../theme/app_radius.dart';

/// floating SnackBar 헬퍼. 프로젝트 표준 UX.
///
/// `ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(..., behavior: floating))`
/// 보일러플레이트를 `context.showError('메시지')` 1줄로 축약.
/// Shape 은 앱 기본 `AppRadius.smoothMd` 고정.
extension SnackbarContext on BuildContext {
  void showError(String message) => _show(message);
  void showInfo(String message) => _show(message);

  void _show(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smoothMd),
      ),
    );
  }
}
