import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/info_capsule.dart';
import '../../../../shared/widgets/match_time_info.dart';
import '../../../../shared/widgets/team_logo_badge.dart';

class NextMatchCard extends StatelessWidget {
  const NextMatchCard({super.key});

  static final _cardRadius = SmoothBorderRadius(
    cornerRadius: AppRadius.md,
    cornerSmoothing: 1.0,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GestureDetector(
        onTap: () => context.push('/match'),
        child: ClipSmoothRect(
          radius: _cardRadius,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── 상단: VS 영역 ──
              DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    AppSpacing.xxl,
                    AppSpacing.sm,
                    AppSpacing.xl,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Center(
                              child: TeamLogoBadge(
                                teamName: 'FC칼로',
                                logoPath: 'assets/images/logo_calo.png',
                                size: 52,
                              ),
                            ),
                          ),
                          MatchTimeInfo(
                            time: '20:00',
                            datePlace: '2/7(토) 성내유수지',
                          ),
                          Expanded(
                            child: Center(
                              child: TeamLogoBadge(
                                teamName: 'FC쏘아',
                                logoPath: 'assets/images/logo_ssoa.png',
                                size: 52,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            InfoCapsule(text: '13/16명'),
                            const SizedBox(width: AppSpacing.sm),
                            InfoCapsule(text: '참가완료'),
                            const SizedBox(width: AppSpacing.sm),
                            InfoCapsule(text: '리벤지 매치'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 구분선 (2px, 그라데이션) ──
              Container(
                height: 1,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1572D1), // 0%
                      Color(0xFF1E64AC), // 25%
                      Color(0xFF1E64AC), // 50%
                      Color(0xFF1E64AC), // 75%
                      Color(0xFF1572D1), // 100%
                    ],
                    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                  ),
                ),
              ),

              // ── 하단: 참가하기 버튼 ──
              Container(
                height: 55,
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.02, -0.78),
                    radius: 3.5,
                    colors: [
                      Color(0xFF1869BE),
                      AppColors.primary,
                    ],
                    stops: [0.4375, 1.0],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '참가 하기',
                      style:
                          AppTextStyles.body.copyWith(color: Colors.white),
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
      ),
    );
  }
}

