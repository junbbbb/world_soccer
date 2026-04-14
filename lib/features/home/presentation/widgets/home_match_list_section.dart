import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/dev_settings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/opponent_logo.dart';
import '../../../../shared/widgets/section_title.dart';

// ── 더미 데이터 ──

class _MatchData {
  final String id;
  final DateTime date;
  final String dayOfWeek;
  final String time;
  final String location;
  final String opponentName;
  final String opponentLogo;
  final String? result;
  final String? score;
  final int participants;
  final int maxParticipants;
  final bool isJoined;

  const _MatchData({
    required this.id,
    required this.date,
    required this.dayOfWeek,
    required this.time,
    required this.location,
    required this.opponentName,
    required this.opponentLogo,
    this.result,
    this.score,
    required this.participants,
    required this.maxParticipants,
    this.isJoined = false,
  });

  bool get isPast => result != null;
}

List<_MatchData> get _matches => [
  _MatchData(id: 'm12', date: DateTime(2026, 4, 4), dayOfWeek: '토', time: '20:00', location: '성내유수지', opponentName: '드림FC', opponentLogo: 'assets/images/logo_ssoa.png', participants: 8, maxParticipants: 16),
  _MatchData(id: 'm11', date: DateTime(2026, 3, 28), dayOfWeek: '토', time: '20:00', location: '잠실축구장', opponentName: '올스타FC', opponentLogo: 'assets/images/logo_ssoa.png', participants: 12, maxParticipants: 16, isJoined: true),
  _MatchData(id: 'm9', date: DateTime(2026, 3, 14), dayOfWeek: '토', time: '20:00', location: '성내유수지', opponentName: 'FC쏘아', opponentLogo: 'assets/images/logo_ssoa.png', result: 'W', score: '3 - 1', participants: 16, maxParticipants: 16, isJoined: true),
  _MatchData(id: 'm8', date: DateTime(2026, 3, 7), dayOfWeek: '토', time: '20:00', location: '잠실축구장', opponentName: '올스타FC', opponentLogo: 'assets/images/logo_ssoa.png', result: 'L', score: '1 - 2', participants: 14, maxParticipants: 16, isJoined: true),
  _MatchData(id: 'm7', date: DateTime(2026, 2, 28), dayOfWeek: '토', time: '20:00', location: '성내유수지', opponentName: '드림FC', opponentLogo: 'assets/images/logo_ssoa.png', result: 'W', score: '4 - 2', participants: 15, maxParticipants: 16),
  _MatchData(id: 'm6', date: DateTime(2026, 2, 21), dayOfWeek: '토', time: '20:00', location: '성내유수지', opponentName: 'FC쏘아', opponentLogo: 'assets/images/logo_ssoa.png', result: 'D', score: '2 - 2', participants: 16, maxParticipants: 16, isJoined: true),
];

// ── 섹션 위젯 ──

class HomeMatchListSection extends ConsumerWidget {
  const HomeMatchListSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showDummy = ref.watch(showDummyDataProvider);
    if (!showDummy) return const SizedBox.shrink();

    final matches = _matches;
    final upcoming = matches.where((m) => !m.isPast).toList();
    final past = matches.where((m) => m.isPast).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 예정 경기
        if (upcoming.isNotEmpty) ...[
          Padding(
            padding: AppSpacing.paddingPage,
            child: const SectionTitle('예정 경기'),
          ),
          ...upcoming.map((m) => _MatchCard(match: m)),
          const SizedBox(height: AppSpacing.xxl),
        ],
        // 지난 경기
        if (past.isNotEmpty) ...[
          Padding(
            padding: AppSpacing.paddingPage,
            child: const SectionTitle('지난 경기'),
          ),
          ...past.map((m) => _MatchCard(match: m)),
        ],
      ],
    );
  }
}

// ── 경기 카드 ──

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match});

  final _MatchData match;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/match'),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.base),
        decoration: ShapeDecoration(
          color: AppColors.surfaceLight,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.smoothLg),
        ),
        child: Column(
          children: [
            Text(
              '${match.date.month}/${match.date.day}(${match.dayOfWeek}) · ${match.time} · ${match.location}',
              style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text('FC칼로', style: AppTextStyles.label.copyWith(color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      ClipRRect(
                        borderRadius: AppRadius.smoothXs,
                        child: Image.asset('assets/images/logo_calo.png', width: 32, height: 32, fit: BoxFit.cover),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                  child: match.isPast
                      ? Text(match.score!, style: AppTextStyles.sectionTitle.copyWith(color: AppColors.textPrimary))
                      : Text('VS', style: AppTextStyles.heading.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.w800)),
                ),
                Expanded(
                  child: Row(
                    children: [
                      OpponentLogo(
                        teamName: match.opponentName,
                        size: 32,
                        borderRadius: AppRadius.smoothXs,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: Text(match.opponentName, style: AppTextStyles.label.copyWith(color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (match.isPast) _buildResultBadge(),
                if (!match.isPast)
                  Text(
                    '${match.participants}/${match.maxParticipants}명 참가',
                    style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: ShapeDecoration(
                    color: match.isJoined ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.smoothFull),
                  ),
                  child: Text(
                    match.isJoined ? '참가' : '미참가',
                    style: AppTextStyles.caption.copyWith(
                      color: match.isJoined ? AppColors.primary : AppColors.textTertiary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultBadge() {
    final isWin = match.result == 'W';
    final isDraw = match.result == 'D';

    final String label;
    final Color bgColor;
    final Color textColor;

    if (isWin) {
      label = '승리';
      bgColor = AppColors.primary;
      textColor = Colors.white;
    } else if (isDraw) {
      label = '무승부';
      bgColor = AppColors.surface;
      textColor = AppColors.textSecondary;
    } else {
      label = '패배';
      bgColor = AppColors.surface;
      textColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: ShapeDecoration(
        color: bgColor,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smoothFull),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(color: textColor, fontWeight: FontWeight.w700),
      ),
    );
  }
}
