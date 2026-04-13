import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/dev_settings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

// ══════════════════════════════════════════════
// 더미 데이터
// ══════════════════════════════════════════════

enum _MatchResult { win, draw, loss }

class _H2HMatch {
  final String date;
  final String competition;
  final String homeTeam;
  final String awayTeam;
  final int homeScore;
  final int awayScore;
  final _MatchResult result; // 우리팀 기준

  const _H2HMatch({
    required this.date,
    required this.competition,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
    required this.result,
  });
}

const _dummyMatches = <_H2HMatch>[
  _H2HMatch(
    date: '2026.03.14',
    competition: '리그전',
    homeTeam: 'FC칼로',
    awayTeam: 'FC쏘아',
    homeScore: 3,
    awayScore: 1,
    result: _MatchResult.win,
  ),
  _H2HMatch(
    date: '2025.12.07',
    competition: '리그전',
    homeTeam: 'FC쏘아',
    awayTeam: 'FC칼로',
    homeScore: 2,
    awayScore: 2,
    result: _MatchResult.draw,
  ),
  _H2HMatch(
    date: '2025.09.20',
    competition: '친선전',
    homeTeam: 'FC칼로',
    awayTeam: 'FC쏘아',
    homeScore: 0,
    awayScore: 2,
    result: _MatchResult.loss,
  ),
  _H2HMatch(
    date: '2025.06.14',
    competition: '리그전',
    homeTeam: 'FC쏘아',
    awayTeam: 'FC칼로',
    homeScore: 1,
    awayScore: 3,
    result: _MatchResult.win,
  ),
  _H2HMatch(
    date: '2025.03.08',
    competition: '리그전',
    homeTeam: 'FC칼로',
    awayTeam: 'FC쏘아',
    homeScore: 2,
    awayScore: 1,
    result: _MatchResult.win,
  ),
];

const _totalWins = 3;
const _totalDraws = 1;
const _totalLosses = 1;
const _totalMatches = 5;

// ══════════════════════════════════════════════
// RecentRecordSection (상대전적 탭)
// ══════════════════════════════════════════════

class RecentRecordSection extends ConsumerWidget {
  const RecentRecordSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showDummy = ref.watch(showDummyDataProvider);
    if (!showDummy) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Summary Strip ──
          const _H2HSummary(
            ourTeam: 'FC칼로',
            theirTeam: 'FC쏘아',
            wins: _totalWins,
            draws: _totalDraws,
            losses: _totalLosses,
            total: _totalMatches,
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── 최근 매치 리스트 ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              '최근 경기',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (var i = 0; i < _dummyMatches.length; i++) ...[
            _H2HMatchRow(match: _dummyMatches[i]),
            if (i < _dummyMatches.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                child: Divider(
                  height: 1,
                  thickness: 0.5,
                  color: AppColors.surface,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// H2H Summary — 전적 숫자 + 비율 바
// ══════════════════════════════════════════════

class _H2HSummary extends StatelessWidget {
  const _H2HSummary({
    required this.ourTeam,
    required this.theirTeam,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.total,
  });

  final String ourTeam;
  final String theirTeam;
  final int wins;
  final int draws;
  final int losses;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          // 전적 숫자 행
          Row(
            children: [
              // 우리 팀 승
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '$wins',
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '승',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              // 무승부
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '$draws',
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textTertiary,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '무',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              // 상대 팀 승 (= 우리 패)
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '$losses',
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '패',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.base),

          // 비율 바
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              child: Row(
                children: [
                  if (wins > 0)
                    Expanded(
                      flex: wins,
                      child: const ColoredBox(color: AppColors.primary),
                    ),
                  if (draws > 0)
                    Expanded(
                      flex: draws,
                      child: const ColoredBox(color: AppColors.iconInactive),
                    ),
                  if (losses > 0)
                    Expanded(
                      flex: losses,
                      child: const ColoredBox(color: AppColors.textPrimary),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // 팀명 양쪽
          Row(
            children: [
              Text(
                ourTeam,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                '최근 $total경기',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const Spacer(),
              Text(
                theirTeam,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// H2H Match Row — 최근 경기 한 줄
// ══════════════════════════════════════════════

class _H2HMatchRow extends StatelessWidget {
  const _H2HMatchRow({required this.match});

  final _H2HMatch match;

  Color get _resultColor {
    switch (match.result) {
      case _MatchResult.win:
        return const Color(0xFF34C759); // 승 — 초록
      case _MatchResult.draw:
        return AppColors.textTertiary; // 무 — 회색
      case _MatchResult.loss:
        return const Color(0xFFFF3B30); // 패 — 빨강
    }
  }

  String get _resultLabel {
    switch (match.result) {
      case _MatchResult.win:
        return 'W';
      case _MatchResult.draw:
        return 'D';
      case _MatchResult.loss:
        return 'L';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          // 결과 도트 + 라벨
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _resultColor.withValues(alpha: 0.15),
            ),
            alignment: Alignment.center,
            child: Text(
              _resultLabel,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: _resultColor,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // 날짜 + 대회
          SizedBox(
            width: 72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  match.date,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                Text(
                  match.competition,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // 홈팀 — 스코어 — 어웨이팀
          Text(
            match.homeTeam,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: ShapeDecoration(
              color: AppColors.surfaceLight,
              shape: SmoothRectangleBorder(
                borderRadius: AppRadius.smoothXs,
              ),
            ),
            child: Text(
              '${match.homeScore} : ${match.awayScore}',
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            match.awayTeam,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
