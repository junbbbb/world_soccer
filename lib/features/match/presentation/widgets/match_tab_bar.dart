import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class MatchTabBar extends StatelessWidget {
  const MatchTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(
        top: AppSpacing.base,
        bottom: AppSpacing.base,
        left: AppSpacing.xl,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: TabBar(
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textTertiary,
          labelStyle: AppTextStyles.label,
          unselectedLabelStyle: AppTextStyles.labelMedium,
          indicator: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xxs,
          ),
          labelPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          dividerHeight: 0,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          tabs: const [
            Tab(height: 48, text: '경기정보'),
            Tab(height: 48, text: '상대전적'),
            Tab(height: 48, text: '스탯'),
          ],
        ),
      ),
    );
  }
}
