import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/dev_settings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../runtime/providers.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../../../types/enums.dart';
import '../../../../types/match.dart' show Match;

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
    opponentLogo: 'assets/images/logo_ssoa.png',
  ),
  _MatchResult(
    result: 'L',
    score: '1 - 2',
    opponentLogo: 'assets/images/logo_calo.png',
  ),
  _MatchResult(
    result: 'W',
    score: '4 - 0',
    opponentLogo: 'assets/images/logo_ssoa.png',
  ),
  _MatchResult(
    result: 'D',
    score: '2 - 2',
    opponentLogo: 'assets/images/logo_calo.png',
  ),
  _MatchResult(
    result: 'W',
    score: '2 - 1',
    opponentLogo: 'assets/images/logo_ssoa.png',
  ),
];

class TeamRecentResultsSection extends ConsumerWidget {
  const TeamRecentResultsSection({super.key, this.hasResults = true});

  /// 신생팀(전적 없음) 케이스를 위한 빈 상태 토글.
  final bool hasResults;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showDummy = ref.watch(showDummyDataProvider);

    if (!showDummy) {
      // 실제 데이터: 완료 경기에서 최근 전적 추출
      final matches = ref.watch(teamMatchesProvider).when<List<Match>>(
            data: (list) => list,
            loading: () => [],
            error: (_, __) => [],
          );
      final completed = matches
          .where((m) => m.status == MatchStatus.completed)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      final recent = completed.take(5).toList();

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
          if (recent.isEmpty)
            const _EmptyResultsCard()
          else
            SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: recent.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (_, index) {
                  final m = recent[index];
                  final r = m.result;
                  final label = r == MatchResult.win
                      ? 'W'
                      : r == MatchResult.loss
                          ? 'L'
                          : 'D';
                  final score =
                      '${m.ourScore ?? 0} - ${m.opponentScore ?? 0}';
                  return _ResultCapsule(
                    result: _MatchResult(
                      result: label,
                      score: score,
                      opponentLogo: 'assets/images/logo_ssoa.png',
                    ),
                  );
                },
              ),
            ),
        ],
      );
    }

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
        if (hasResults)
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
          )
        else
          const _EmptyResultsCard(),
      ],
    );
  }
}

// ── 빈 상태 (신생팀: 아직 전적 없음) ──
// 데이터 있을 때 칩 행과 100% 동일한 시각 언어
// (같은 SizedBox 높이, surfaceLight + smoothSm + 16/10 패딩 캡슐).
// 단일 액션 칩 — "최근 전적" 섹션 헤더가 이미 컨텍스트를 제공하므로
// 별도 정보 칩 없이 액션 하나로 충분.
class _EmptyResultsCard extends StatelessWidget {
  const _EmptyResultsCard();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              context.push('/match/result-input');
            },
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
                  const Icon(
                    Icons.add_rounded,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '첫 기록 추가하기',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
