import 'dart:ui';

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/section_title.dart';

// ── 더미 데이터 모델 ──

class _MatchData {
  final String id;
  final DateTime date;
  final String dayOfWeek;
  final String time;
  final String location;
  final String opponentName;
  final String opponentLogo;
  final String? result; // 'W', 'L', 'D'
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

final _dummyMatches = [
  // 예정 경기
  _MatchData(
    id: 'm12',
    date: DateTime(2026, 4, 4),
    dayOfWeek: '토',
    time: '20:00',
    location: '성내유수지',
    opponentName: '드림FC',
    opponentLogo: 'assets/images/logo_ssoa.png',
    participants: 8,
    maxParticipants: 16,
  ),
  _MatchData(
    id: 'm11',
    date: DateTime(2026, 3, 28),
    dayOfWeek: '토',
    time: '20:00',
    location: '잠실축구장',
    opponentName: '올스타FC',
    opponentLogo: 'assets/images/logo_ssoa.png',
    participants: 12,
    maxParticipants: 16,
    isJoined: true,
  ),
  _MatchData(
    id: 'm10',
    date: DateTime(2026, 3, 21),
    dayOfWeek: '토',
    time: '20:00',
    location: '성내유수지',
    opponentName: 'FC쏘아',
    opponentLogo: 'assets/images/logo_ssoa.png',
    participants: 15,
    maxParticipants: 16,
    isJoined: true,
  ),
  // 지난 경기
  _MatchData(
    id: 'm9',
    date: DateTime(2026, 3, 14),
    dayOfWeek: '토',
    time: '20:00',
    location: '성내유수지',
    opponentName: 'FC쏘아',
    opponentLogo: 'assets/images/logo_ssoa.png',
    result: 'W',
    score: '3 - 1',
    participants: 16,
    maxParticipants: 16,
    isJoined: true,
  ),
  _MatchData(
    id: 'm8',
    date: DateTime(2026, 3, 7),
    dayOfWeek: '토',
    time: '20:00',
    location: '잠실축구장',
    opponentName: '올스타FC',
    opponentLogo: 'assets/images/logo_ssoa.png',
    result: 'L',
    score: '1 - 2',
    participants: 14,
    maxParticipants: 16,
    isJoined: true,
  ),
  _MatchData(
    id: 'm7',
    date: DateTime(2026, 2, 28),
    dayOfWeek: '토',
    time: '20:00',
    location: '성내유수지',
    opponentName: '드림FC',
    opponentLogo: 'assets/images/logo_ssoa.png',
    result: 'W',
    score: '4 - 2',
    participants: 15,
    maxParticipants: 16,
  ),
  _MatchData(
    id: 'm6',
    date: DateTime(2026, 2, 21),
    dayOfWeek: '토',
    time: '20:00',
    location: '성내유수지',
    opponentName: 'FC쏘아',
    opponentLogo: 'assets/images/logo_ssoa.png',
    result: 'D',
    score: '2 - 2',
    participants: 16,
    maxParticipants: 16,
    isJoined: true,
  ),
  _MatchData(
    id: 'm5',
    date: DateTime(2026, 2, 14),
    dayOfWeek: '토',
    time: '20:00',
    location: '잠실축구장',
    opponentName: '올스타FC',
    opponentLogo: 'assets/images/logo_ssoa.png',
    result: 'W',
    score: '2 - 0',
    participants: 13,
    maxParticipants: 16,
    isJoined: true,
  ),
  _MatchData(
    id: 'm4',
    date: DateTime(2026, 2, 7),
    dayOfWeek: '토',
    time: '20:00',
    location: '성내유수지',
    opponentName: '드림FC',
    opponentLogo: 'assets/images/logo_ssoa.png',
    result: 'L',
    score: '0 - 1',
    participants: 14,
    maxParticipants: 16,
  ),
  _MatchData(
    id: 'm3',
    date: DateTime(2026, 1, 31),
    dayOfWeek: '토',
    time: '20:00',
    location: '잠실축구장',
    opponentName: 'FC쏘아',
    opponentLogo: 'assets/images/logo_ssoa.png',
    result: 'W',
    score: '5 - 1',
    participants: 16,
    maxParticipants: 16,
    isJoined: true,
  ),
  _MatchData(
    id: 'm2',
    date: DateTime(2026, 1, 24),
    dayOfWeek: '토',
    time: '20:00',
    location: '성내유수지',
    opponentName: '올스타FC',
    opponentLogo: 'assets/images/logo_ssoa.png',
    result: 'W',
    score: '3 - 0',
    participants: 15,
    maxParticipants: 16,
  ),
];

// ── MatchTab ──

class MatchTab extends StatelessWidget {
  const MatchTab({super.key});

  static const _headerHeight = 56.0;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final upcoming =
        _dummyMatches.where((m) => !m.isPast).toList().reversed.toList();
    final past = _dummyMatches.where((m) => m.isPast).toList();

    return ColoredBox(
      color: AppColors.surface,
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(top: topPadding + _headerHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: AppSpacing.paddingPage,
                  child: SectionTitle(
                    '예정 경기',
                    trailing: GestureDetector(
                      onTap: () {
                        // TODO: 더보기 네비게이션
                      },
                      child: Text(
                        '더보기',
                        style: AppTextStyles.captionMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ),
                ...upcoming.map((m) => _MatchCard(match: m)),
                const SizedBox(height: AppSpacing.xxl),
                Padding(
                  padding: AppSpacing.paddingPage,
                  child: SectionTitle(
                    '지난 경기',
                    trailing: GestureDetector(
                      onTap: () {
                        // TODO: 더보기 네비게이션
                      },
                      child: Text(
                        '더보기',
                        style: AppTextStyles.captionMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ),
                ...past.map((m) => _MatchCard(match: m)),
                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: AppColors.surface.withValues(alpha: 0.85),
                  padding: EdgeInsets.only(
                    top: topPadding + AppSpacing.sm,
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    bottom: AppSpacing.base,
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/logo_calo.png',
                        width: 32,
                        height: 32,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '경기 일정',
                        style: AppTextStyles.pageTitle.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 경기 카드 (EPL 스타일) ──

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match});

  final _MatchData match;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/match'),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 6,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.base,
        ),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: SmoothRectangleBorder(
            borderRadius: AppRadius.smoothLg,
          ),
        ),
        child: Column(
          children: [
            // 날짜 · 시간 · 장소
            Text(
              '${match.date.month}/${match.date.day}(${match.dayOfWeek}) · ${match.time} · ${match.location}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // 팀명 - 로고 - 스코어 - 로고 - 팀명
            Row(
              children: [
                // 우리팀 (오른쪽 정렬)
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          'FC칼로',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      ClipSmoothRect(
                        radius: AppRadius.smoothXs,
                        child: Image.asset(
                          'assets/images/logo_calo.png',
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
                // 스코어 or VS
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base,
                  ),
                  child: match.isPast
                      ? Text(
                          match.score!,
                          style: AppTextStyles.sectionTitle.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        )
                      : Text(
                          'VS',
                          style: AppTextStyles.heading.copyWith(
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
                // 상대팀 (왼쪽 정렬)
                Expanded(
                  child: Row(
                    children: [
                      ClipSmoothRect(
                        radius: AppRadius.smoothXs,
                        child: Image.asset(
                          match.opponentLogo,
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: Text(
                          match.opponentName,
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // 결과 뱃지 + 참가 여부
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (match.isPast) _buildResultBadge(),
                if (!match.isPast)
                  Text(
                    '${match.participants}/${match.maxParticipants}명 참가',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(width: AppSpacing.sm),
                _buildJoinedBadge(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: ShapeDecoration(
        color: match.isJoined
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.surface,
        shape: SmoothRectangleBorder(
          borderRadius: AppRadius.smoothFull,
        ),
      ),
      child: Text(
        match.isJoined ? '참가' : '미참가',
        style: AppTextStyles.caption.copyWith(
          color: match.isJoined ? AppColors.primary : AppColors.textTertiary,
          fontWeight: FontWeight.w700,
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
        shape: SmoothRectangleBorder(
          borderRadius: AppRadius.smoothFull,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
