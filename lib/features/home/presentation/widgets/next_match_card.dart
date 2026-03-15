import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/team_logo_badge.dart';

class NextMatchCard extends StatelessWidget {
  const NextMatchCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/match'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        decoration: ShapeDecoration(
          gradient: AppColors.headerGradient,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius.all(
              SmoothRadius(cornerRadius: 20, cornerSmoothing: 1.0),
            ),
          ),
        ),
        child: Column(
          children: [
            // Top bar: NEXT MATCH
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'NEXT MATCH',
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFAD96D),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white54,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text(
                        '오후',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 0.8,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      '8:00',
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '2/7(토) 성내유수지',
                      style: AppTextStyles.teamName.copyWith(fontSize: 12),
                    ),
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
            // 구분선
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Divider(
                color: Colors.white.withValues(alpha: 0.2),
                height: 1,
              ),
            ),
            // 참가하기 버튼
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '참가 하기',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 12,
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
