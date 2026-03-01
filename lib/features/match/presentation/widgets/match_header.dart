import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/team_logo_badge.dart';

class MatchHeader extends StatelessWidget {
  const MatchHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      child: SafeArea(
        bottom: false,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
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
                          color: Colors.black.withValues(
                            alpha: 0.1,
                          ), // 000000 10%
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 14,
                              height: 1.5,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 4), // Adjusted gap
                            Container(
                              width: 14,
                              height: 1.5,
                              color: Colors.white,
                            ),
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
                        // Removed SizedBox to reduce vertical spacing
                        Text(
                          '2월 7일',
                          style: AppTextStyles.teamName.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.white70,
                          ),
                        ),
                        // Removed SizedBox to reduce vertical spacing
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
        ),
      ),
    );
  }
}
