import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/team_logo_badge.dart';

class NextMatchCard extends StatelessWidget {
  const NextMatchCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/match'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.base,
        ),
        decoration: ShapeDecoration(
          gradient: AppColors.headerGradient,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius.all(
              SmoothRadius(
                cornerRadius: AppRadius.lg,
                cornerSmoothing: 1.0,
              ),
            ),
          ),
        ),
        child: Column(
          children: [
            // VS section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const TeamLogoBadge(
                  teamName: '칼로FC',
                  logoPath: 'assets/images/fc_calor.png',
                  size: 44,
                ),
                const SizedBox(width: 40),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.overlayDark,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text('오후', style: AppTextStyles.timeBadge),
                    ),
                    Text('8:00', style: AppTextStyles.timeDisplay),
                    Text('2/7(토) 성내유수지', style: AppTextStyles.matchInfo),
                  ],
                ),
                const SizedBox(width: 40),
                const TeamLogoBadge(
                  teamName: '뽀잉FC',
                  logoPath: 'assets/images/fc_bosong.png',
                  size: 44,
                ),
              ],
            ),
            // 구분선 (그라데이션)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.base),
              child: Container(
                height: 1,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                    colors: AppColors.dividerGradientColors,
                  ),
                ),
              ),
            ),
            // 참가하기 버튼
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.base),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '참가 하기',
                    style: AppTextStyles.label.copyWith(color: Colors.white),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(
                    Icons.arrow_right_alt_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
