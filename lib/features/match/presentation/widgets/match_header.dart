import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/team_logo_badge.dart';

class MatchHeaderDelegate extends SliverPersistentHeaderDelegate {
  const MatchHeaderDelegate({this.onBack});

  final VoidCallback? onBack;

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 196;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final expandedOpacity = 1.0 - ((progress - 0.7) * 3.33).clamp(0.0, 1.0);
    final collapsedOpacity = ((progress - 0.8) * 5.0).clamp(0.0, 1.0);

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        boxShadow: AppShadows.header,
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          if (expandedOpacity > 0)
            Positioned(
              top: -shrinkOffset,
              left: 0,
              right: 0,
              height: maxExtent,
              child: Opacity(
                opacity: expandedOpacity,
                child: _buildExpanded(context),
              ),
            ),
          if (collapsedOpacity > 0)
            Positioned.fill(
              child: Opacity(
                opacity: collapsedOpacity,
                child: _buildCollapsed(context),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCollapsed(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          if (onBack != null)
            GestureDetector(
              onTap: onBack,
              child: const Padding(
                padding: EdgeInsets.only(right: AppSpacing.md),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          const Spacer(),
          Row(
            children: [
              Text('칼로FC', style: AppTextStyles.teamName),
              const SizedBox(width: AppSpacing.sm),
              Image.asset('assets/images/fc_calor.png', width: 28, height: 28),
            ],
          ),
          const SizedBox(width: AppSpacing.xxl),
          Text(
            '오후 8:00',
            style: AppTextStyles.teamName.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: AppSpacing.xxl),
          Row(
            children: [
              Image.asset('assets/images/fc_bosong.png', width: 28, height: 28),
              const SizedBox(width: AppSpacing.sm),
              Text('뽀잉FC', style: AppTextStyles.teamName),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildExpanded(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          // Top bar: back button + menu
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (onBack != null)
                  GestureDetector(
                    onTap: onBack,
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: const Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          // VS section
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              top: AppSpacing.base,
              bottom: AppSpacing.xxxl,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const TeamLogoBadge(
                  teamName: '칼로FC',
                  logoPath: 'assets/images/fc_calor.png',
                ),
                const SizedBox(width: AppSpacing.xxl),
                // Match info center
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
                const SizedBox(width: AppSpacing.xxl),
                const TeamLogoBadge(
                  teamName: '뽀잉FC',
                  logoPath: 'assets/images/fc_bosong.png',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant MatchHeaderDelegate oldDelegate) => false;
}
