import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
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
    // Fade out original layout near the end (70% ~ 100%)
    final expandedOpacity = 1.0 - ((progress - 0.7) * 3.33).clamp(0.0, 1.0);
    // Fade in collapsed layout at the very end (80% ~ 100%)
    final collapsedOpacity = ((progress - 0.8) * 5.0).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        boxShadow: const [
          BoxShadow(
            color: Color(0x406C849C),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          if (onBack != null)
            GestureDetector(
              onTap: onBack,
              child: const Padding(
                padding: EdgeInsets.only(right: 12),
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
              const SizedBox(width: 8),
              Image.asset('assets/images/fc_calor.png', width: 28, height: 28),
            ],
          ),
          const SizedBox(width: 16),
          Text(
            '오후 8:00',
            style: AppTextStyles.teamName.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              Image.asset('assets/images/fc_bosong.png', width: 28, height: 28),
              const SizedBox(width: 8),
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
          // Top bar: back button + NEXT MATCH + menu
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 4,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (onBack != null)
                  GestureDetector(
                    onTap: onBack,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                Text(
                  'NEXT MATCH',
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
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
              left: 24, // Increased margin
              right: 24, // Increased margin
              top: 24, // Increased top padding
              bottom: 48, // Increased bottom padding
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const TeamLogoBadge(
                  teamName: '칼로FC',
                  logoPath: 'assets/images/fc_calor.png',
                ),
                const Spacer(),
                // Match info center
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text(
                        '오후',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 0.8,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      '8:00',
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '2/7(토) 성내유수지',
                      style: const TextStyle(
                        fontFamily: 'SCDream',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
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
