import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/team_logo_badge.dart';

class MatchHeaderDelegate extends SliverPersistentHeaderDelegate {
  const MatchHeaderDelegate();

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 160;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    // Fade out original layout near the end (70% ~ 100%)
    final expandedOpacity = 1.0 - ((progress - 0.7) * 3.33).clamp(0.0, 1.0);
    // Fade in collapsed layout at the very end (80% ~ 100%)
    final collapsedOpacity = ((progress - 0.8) * 5.0).clamp(0.0, 1.0);

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
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
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text('칼로FC', style: AppTextStyles.teamName),
              const SizedBox(width: 8),
              Image.asset('assets/images/fc_calor.png', width: 28, height: 28),
            ],
          ),
          Text(
            '오후 8:00',
            style: AppTextStyles.teamName.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          Row(
            children: [
              Image.asset('assets/images/fc_bosong.png', width: 28, height: 28),
              const SizedBox(width: 8),
              Text('뽀잉FC', style: AppTextStyles.teamName),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpanded(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          // Top bar: NEXT MATCH + menu
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24, // Increased horizontal margin
              vertical: 4, // Reduced from 12
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment
                  .center, // Ensure perfect horizontal alignment
              children: [
                Text(
                  'NEXT MATCH',
                  style: GoogleFonts.antonSc(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFFAD96D),
                    shadows: [
                      const Shadow(
                        offset: Offset(1.0, 1.0),
                        blurRadius: 0.0,
                        color: Color(0xFFB90000),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 26, // Reduced size
                    height: 26, // Reduced size
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.1), // 000000 10%
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 14, height: 1.5, color: Colors.white),
                        const SizedBox(height: 4), // Adjusted gap
                        Container(width: 14, height: 1.5, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // VS section
          Padding(
            padding: const EdgeInsets.only(
              left: 24, // Increased margin
              right: 24, // Increased margin
              top: 24, // Increased top padding
              bottom: 32, // Increased bottom padding
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const TeamLogoBadge(
                  teamName: '칼로FC',
                  logoPath: 'assets/images/fc_calor.png',
                ),
                const SizedBox(width: 60), // More controlled distance
                // Match info center
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '오후 8:00',
                      style: AppTextStyles.teamName.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '2월 7일',
                      style: AppTextStyles.teamName.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '성내유수지',
                      style: AppTextStyles.teamName.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 60), // More controlled distance
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
