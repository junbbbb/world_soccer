import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

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
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xxxl,
          horizontal: AppSpacing.lg,
        ),
        decoration: ShapeDecoration(
          color: AppColors.surface,
          shape: SmoothRectangleBorder(
            borderRadius: AppRadius.smoothMd,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '라인업 & 전술 공개 전이에요',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            // 관리자용: 라인업 만들기 진입
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                context.push('/match/lineup-builder');
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: ShapeDecoration(
                  color: AppColors.textPrimary,
                  shape: SmoothRectangleBorder(
                    borderRadius: AppRadius.smoothSm,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '라인업 만들기',
                      style: AppTextStyles.captionBold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
