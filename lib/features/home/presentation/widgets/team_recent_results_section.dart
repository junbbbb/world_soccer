import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/section_title.dart';

class _MatchResult {
  final String result;
  final String score;
  final String opponentLogo;

  const _MatchResult({
    required this.result,
    required this.score,
    required this.opponentLogo,
  });
}

const _dummyResults = [
  _MatchResult(
    result: 'W',
    score: '3 - 1',
    opponentLogo: 'assets/images/fc_bosong.png',
  ),
  _MatchResult(
    result: 'L',
    score: '1 - 2',
    opponentLogo: 'assets/images/fc_calor.png',
  ),
  _MatchResult(
    result: 'W',
    score: '4 - 0',
    opponentLogo: 'assets/images/fc_bosong.png',
  ),
  _MatchResult(
    result: 'D',
    score: '2 - 2',
    opponentLogo: 'assets/images/fc_calor.png',
  ),
  _MatchResult(
    result: 'W',
    score: '2 - 1',
    opponentLogo: 'assets/images/fc_bosong.png',
  ),
];

class TeamRecentResultsSection extends StatelessWidget {
  const TeamRecentResultsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.xs,
          ),
          child: SectionTitle('최근 전적'),
        ),
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: _dummyResults.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              if (index == _dummyResults.length) {
                return GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: 10,
                    ),
                    decoration: ShapeDecoration(
                      color: AppColors.surfaceLight,
                      shape: SmoothRectangleBorder(
                        borderRadius: AppRadius.smoothSm,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '더보기',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                      ],
                    ),
                  ),
                );
              }
              return _ResultCapsule(result: _dummyResults[index]);
            },
          ),
        ),
        const SizedBox(height: 0),
      ],
    );
  }
}

class _ResultCapsule extends StatelessWidget {
  const _ResultCapsule({required this.result});

  final _MatchResult result;

  String get _resultLabel {
    switch (result.result) {
      case 'W':
        return '승';
      case 'L':
        return '패';
      case 'D':
        return '무';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 10),
      decoration: ShapeDecoration(
        color: AppColors.surfaceLight,
        shape: SmoothRectangleBorder(
          borderRadius: AppRadius.smoothSm,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _resultLabel,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.base),
          Text(
            result.score,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.base),
          ClipSmoothRect(
            radius: AppRadius.smoothXs,
            child: Image.asset(
              result.opponentLogo,
              width: 22,
              height: 22,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
