import 'dart:ui';

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

// ── 더미 데이터 모델 ──

class _MatchData {
  final String id;
  final DateTime date;
  final String dayOfWeek;
  final String time;
  final String location;
  final String opponentName;
  final String opponentLogo;
  final String? result;
  final int? ourScore;
  final int? theirScore;
  final int participants;
  final int maxParticipants;

  const _MatchData({
    required this.id,
    required this.date,
    required this.dayOfWeek,
    required this.time,
    required this.location,
    required this.opponentName,
    required this.opponentLogo,
    this.result,
    this.ourScore,
    this.theirScore,
    required this.participants,
    required this.maxParticipants,
  });

  bool get isPast => result != null;
}

final _dummyMatches = [
  _MatchData(id: 'm12', date: DateTime(2026, 4, 4), dayOfWeek: '토', time: '20:00', location: '성내유수지', opponentName: '드림FC', opponentLogo: 'assets/images/logo_ssoa.png', participants: 8, maxParticipants: 16),
  _MatchData(id: 'm11', date: DateTime(2026, 3, 28), dayOfWeek: '토', time: '20:00', location: '잠실축구장', opponentName: '올스타FC', opponentLogo: 'assets/images/logo_ssoa.png', participants: 12, maxParticipants: 16),
  _MatchData(id: 'm10', date: DateTime(2026, 3, 21), dayOfWeek: '토', time: '20:00', location: '성내유수지', opponentName: 'FC쏘아', opponentLogo: 'assets/images/logo_ssoa.png', participants: 15, maxParticipants: 16),
  _MatchData(id: 'm9', date: DateTime(2026, 3, 14), dayOfWeek: '토', time: '20:00', location: '성내유수지', opponentName: 'FC쏘아', opponentLogo: 'assets/images/logo_ssoa.png', result: 'W', ourScore: 3, theirScore: 1, participants: 16, maxParticipants: 16),
  _MatchData(id: 'm8', date: DateTime(2026, 3, 7), dayOfWeek: '토', time: '20:00', location: '잠실축구장', opponentName: '올스타FC', opponentLogo: 'assets/images/logo_ssoa.png', result: 'L', ourScore: 1, theirScore: 2, participants: 14, maxParticipants: 16),
  _MatchData(id: 'm7', date: DateTime(2026, 2, 28), dayOfWeek: '토', time: '20:00', location: '성내유수지', opponentName: '드림FC', opponentLogo: 'assets/images/logo_ssoa.png', result: 'W', ourScore: 4, theirScore: 2, participants: 15, maxParticipants: 16),
  _MatchData(id: 'm6', date: DateTime(2026, 2, 21), dayOfWeek: '토', time: '20:00', location: '성내유수지', opponentName: 'FC쏘아', opponentLogo: 'assets/images/logo_ssoa.png', result: 'D', ourScore: 2, theirScore: 2, participants: 16, maxParticipants: 16),
  _MatchData(id: 'm5', date: DateTime(2026, 2, 14), dayOfWeek: '토', time: '20:00', location: '잠실축구장', opponentName: '올스타FC', opponentLogo: 'assets/images/logo_ssoa.png', result: 'W', ourScore: 2, theirScore: 0, participants: 13, maxParticipants: 16),
  _MatchData(id: 'm4', date: DateTime(2026, 2, 7), dayOfWeek: '토', time: '20:00', location: '성내유수지', opponentName: '드림FC', opponentLogo: 'assets/images/logo_ssoa.png', result: 'L', ourScore: 0, theirScore: 1, participants: 14, maxParticipants: 16),
  _MatchData(id: 'm3', date: DateTime(2026, 1, 31), dayOfWeek: '토', time: '20:00', location: '잠실축구장', opponentName: 'FC쏘아', opponentLogo: 'assets/images/logo_ssoa.png', result: 'W', ourScore: 5, theirScore: 1, participants: 16, maxParticipants: 16),
  _MatchData(id: 'm2', date: DateTime(2026, 1, 24), dayOfWeek: '토', time: '20:00', location: '성내유수지', opponentName: '올스타FC', opponentLogo: 'assets/images/logo_ssoa.png', result: 'W', ourScore: 3, theirScore: 0, participants: 15, maxParticipants: 16),
];

// ── MatchTab ──

class MatchTab extends StatefulWidget {
  const MatchTab({super.key});

  @override
  State<MatchTab> createState() => _MatchTabState();
}

class _MatchTabState extends State<MatchTab> {
  late List<DateTime> _months;
  late int _monthIndex;
  final Set<String> _joinedIds = {'m11', 'm10', 'm9', 'm8', 'm6', 'm5', 'm3'};

  static const _headerHeight = 64.0;

  @override
  void initState() {
    super.initState();
    final monthSet = <String, DateTime>{};
    for (final m in _dummyMatches) {
      final key = '${m.date.year}-${m.date.month}';
      monthSet.putIfAbsent(key, () => DateTime(m.date.year, m.date.month));
    }
    _months = monthSet.values.toList()..sort((a, b) => b.compareTo(a));
    _monthIndex = _months.indexWhere((d) => d.year == 2026 && d.month == 3);
    if (_monthIndex < 0) _monthIndex = 0;
  }

  DateTime get _selectedMonth => _months[_monthIndex];

  List<_MatchData> get _monthMatches {
    final m = _selectedMonth;
    return _dummyMatches
        .where((d) => d.date.year == m.year && d.date.month == m.month)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  void _prevMonth() {
    if (_monthIndex < _months.length - 1) {
      HapticFeedback.selectionClick();
      setState(() => _monthIndex++);
    }
  }

  void _nextMonth() {
    if (_monthIndex > 0) {
      HapticFeedback.selectionClick();
      setState(() => _monthIndex--);
    }
  }

  void _toggleJoin(String id) {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_joinedIds.contains(id)) {
        _joinedIds.remove(id);
      } else {
        _joinedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final matches = _monthMatches;

    return ColoredBox(
      color: AppColors.surface,
      child: Stack(
        children: [
          // ── 본문 ──
          ListView.builder(
            padding: EdgeInsets.only(
              top: topPadding + _headerHeight + AppSpacing.sm,
              bottom: AppSpacing.xxxxl,
            ),
            itemCount: matches.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _MonthHeader(
                  month: _selectedMonth,
                  canPrev: _monthIndex < _months.length - 1,
                  canNext: _monthIndex > 0,
                  onPrev: _prevMonth,
                  onNext: _nextMonth,
                );
              }
              final match = matches[index - 1];
              return Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  bottom: AppSpacing.md,
                ),
                child: _MatchCard(
                  match: match,
                  isJoined: _joinedIds.contains(match.id),
                  onTap: () => context.push('/match'),
                  onToggleJoin:
                      match.isPast ? null : () => _toggleJoin(match.id),
                ),
              );
            },
          ),

          // ── 헤더 ──
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
                      Image.asset('assets/images/logo_calo.png',
                          width: 32, height: 32),
                      const SizedBox(width: AppSpacing.sm),
                      Text('경기',
                          style: AppTextStyles.pageTitle
                              .copyWith(color: AppColors.textPrimary)),
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

// ── 월 헤더 (← 3월 →) ──

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.month,
    required this.canPrev,
    required this.canNext,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime month;
  final bool canPrev, canNext;
  final VoidCallback onPrev, onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.base),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: canPrev ? onPrev : null,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xs),
              child: Icon(Icons.chevron_left_rounded,
                  size: 24,
                  color: canPrev
                      ? AppColors.textPrimary
                      : AppColors.iconInactive),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '${month.year}년 ${month.month}월',
            style:
                AppTextStyles.heading.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: canNext ? onNext : null,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xs),
              child: Icon(Icons.chevron_right_rounded,
                  size: 24,
                  color: canNext
                      ? AppColors.textPrimary
                      : AppColors.iconInactive),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 경기 카드 ──
// 왼쪽: 일자 | 구분선 | 오른쪽: 시간 + 장소/인원 + 우리팀 + 상대팀

class _MatchCard extends StatelessWidget {
  const _MatchCard({
    required this.match,
    required this.isJoined,
    required this.onTap,
    this.onToggleJoin,
  });

  final _MatchData match;
  final bool isJoined;
  final VoidCallback onTap;
  final VoidCallback? onToggleJoin;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothSm),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // ── 왼쪽: 일자 ──
              SizedBox(
                width: 36,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '${match.date.day}',
                      style: AppTextStyles.sectionTitle.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      match.dayOfWeek,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),

              // ── 구분선 ──
              Container(
                width: 1,
                margin: const EdgeInsets.only(left: AppSpacing.sm, right: AppSpacing.md),
                color: AppColors.surface,
              ),

              // ── 오른쪽: 정보 영역 ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1행: 시간 + 상태 라벨
                    Row(
                      children: [
                        Text(
                          match.time,
                          style: AppTextStyles.heading.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        if (!match.isPast && isJoined)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: ShapeDecoration(
                              color: const Color(0xFFE8F8EE),
                              shape: SmoothRectangleBorder(
                                  borderRadius: AppRadius.smoothXs),
                            ),
                            child: Text(
                              '참가완료',
                              style: AppTextStyles.caption.copyWith(
                                color: const Color(0xFF22A55B),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        if (!match.isPast && isJoined)
                          const SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: ShapeDecoration(
                            color: match.isPast
                                ? AppColors.surface
                                : AppColors.primary.withValues(alpha: 0.08),
                            shape: SmoothRectangleBorder(
                                borderRadius: AppRadius.smoothXs),
                          ),
                          child: Text(
                            match.isPast ? '완료' : '예정',
                            style: AppTextStyles.caption.copyWith(
                              color: match.isPast
                                  ? AppColors.textTertiary
                                  : AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // 2행: 장소 · 참가인원
                    Text(
                      '${match.location} · ${match.participants}/${match.maxParticipants}명',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),

                    // 3행: 우리팀
                    _TeamRow(
                      logo: 'assets/images/logo_calo.png',
                      name: 'FC칼로',
                      score: match.isPast ? match.ourScore : null,
                      isWinner: match.result == 'W',
                      isPast: match.isPast,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // 4행: 상대팀
                    _TeamRow(
                      logo: match.opponentLogo,
                      name: match.opponentName,
                      score: match.isPast ? match.theirScore : null,
                      isWinner: match.result == 'L',
                      isPast: match.isPast,
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

// ── 팀 행 (로고 + 팀명 + 스코어) ──

class _TeamRow extends StatelessWidget {
  const _TeamRow({
    required this.logo,
    required this.name,
    this.score,
    required this.isWinner,
    required this.isPast,
  });

  final String logo;
  final String name;
  final int? score;
  final bool isWinner;
  final bool isPast;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipSmoothRect(
          radius: AppRadius.smoothXs,
          child: Image.asset(logo,
              width: 22, height: 22, fit: BoxFit.cover),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            name,
            style: AppTextStyles.labelMedium.copyWith(
              color: isPast && !isWinner
                  ? AppColors.textTertiary
                  : AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (score != null)
          Text(
            '$score',
            style: AppTextStyles.label.copyWith(
              color: isWinner
                  ? AppColors.textPrimary
                  : AppColors.textTertiary,
            ),
          ),
      ],
    );
  }
}

