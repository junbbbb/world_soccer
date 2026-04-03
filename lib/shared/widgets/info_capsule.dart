import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';

/// 반투명 캡슐 뱃지 (예: "13/16명", "참가완료")
class InfoCapsule extends StatelessWidget {
  const InfoCapsule({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelRegular.copyWith(color: Colors.white),
      ),
    );
  }
}
