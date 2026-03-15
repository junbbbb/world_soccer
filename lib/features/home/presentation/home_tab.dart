import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'widgets/next_match_card.dart';
import 'widgets/team_posts_section.dart';
import 'widgets/team_recent_results_section.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // 상단 헤더 (로고 영역)
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              top: AppSpacing.sm,
              bottom: AppSpacing.base,
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/fc_calor.png',
                  width: 32,
                  height: 32,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '칼로FC',
                  style: AppTextStyles.pageTitle.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.textTertiary,
                  size: 24,
                ),
              ],
            ),
          ),
          const Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  NextMatchCard(),
                  SizedBox(height: AppSpacing.xxl),
                  TeamRecentResultsSection(),
                  SizedBox(height: AppSpacing.xxl),
                  TeamPostsSection(),
                  SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
