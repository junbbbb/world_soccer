import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class LineupSection extends StatelessWidget {
  const LineupSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.base,
        bottom: AppSpacing.xl,
      ),
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: ShapeDecoration(
          color: AppColors.surface,
          shape: SmoothRectangleBorder(
            borderRadius: AppRadius.smoothMd,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '라인업&전술 공개 전이에요',
          style: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
        ),
      ),
    );
  }
}
