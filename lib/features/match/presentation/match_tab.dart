import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/dev_settings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../runtime/providers.dart';
import '../../../shared/widgets/opponent_logo.dart';
import '../../../types/enums.dart' show MatchDisplayState, MatchResult;
import '../../../types/match.dart' show Match;
import '../../../types/team.dart' show Team;

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
    this.isFinished = false,
    this.displayLabel,
  });

  final bool isFinished;
  final String? displayLabel;

  bool get isPast => result != null || isFinished;
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

class MatchTab extends ConsumerStatefulWidget {
  const MatchTab({super.key});

  @override
  ConsumerState<MatchTab> createState() => _MatchTabState();
}

class _MatchTabState extends ConsumerState<MatchTab> {
  late List<DateTime> _months;
  late int _monthIndex;
  final Set<String> _joinedIds = {'m11', 'm10', 'm9', 'm8', 'm6', 'm5', 'm3'};

  /// 0 = 예정, 1 = 종료
  int _tabIndex = 0;

  static const _headerHeight = 108.0;

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
    final showDummy = ref.watch(showDummyDataProvider);
    final topPadding = MediaQuery.of(context).padding.top;

    // 팀 데이터 (한 번만 watch)
    final team = showDummy
        ? null
        : ref.watch(currentTeamProvider).when<Team?>(
              data: (t) => t,
              loading: () => null,
              error: (_, __) => null,
            );
    final ourName = team?.name ?? 'FC칼로';
    final ourLogo = team?.logoUrl;

    // 실제 DB 데이터
    final asyncMatches = ref.watch(teamMatchesProvider);
    final realMatchList = asyncMatches.when<List<Match>>(
      data: (list) => list,
      loading: () => [],
      error: (_, __) => [],
    );
    final realMatches = showDummy
        ? <_MatchData>[]
        : realMatchList.map((m) {
            final ds = m.displayState;
            String? resultLabel;
            if (m.hasResult) {
              resultLabel = m.result == MatchResult.win
                  ? 'W'
                  : m.result == MatchResult.loss
                      ? 'L'
                      : 'D';
            }
            String? label;
            if (ds == MatchDisplayState.cancelled) label = '취소';
            if (ds == MatchDisplayState.earlyEnded) label = '조기종료';
            if (ds == MatchDisplayState.ended) label = '종료';
            if (ds == MatchDisplayState.inProgress) label = '진행 중';

            return _MatchData(
              id: m.id,
              date: m.date,
              dayOfWeek: m.dayOfWeek,
              time: m.timeString,
              location: m.location,
              opponentName: m.opponentName,
              opponentLogo: m.opponentLogoUrl ?? 'assets/images/logo_ssoa.png',
              result: resultLabel,
              ourScore: m.ourScore,
              theirScore: m.opponentScore,
              participants: 0,
              maxParticipants: 16,
              isFinished: m.isFinished,
              displayLabel: label,
            );
          }).toList();

    // 실제 데이터: 예정/종료 분리, 예정은 날짜 오름차순, 종료는 최신순
    final upcomingReal = realMatches.where((m) => !m.isPast).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final completedReal = realMatches.where((m) => m.isPast).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // 더미: 기존 월별 필터
    final dummyMatches = showDummy ? _monthMatches : <_MatchData>[];

    // 실제 데이터 모드에서 현재 탭에 따라 표시할 리스트
    final displayMatches = showDummy
        ? dummyMatches
        : (_tabIndex == 0 ? upcomingReal : completedReal);

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
            itemCount: showDummy
                ? displayMatches.length + 1
                : (displayMatches.isEmpty ? 1 : displayMatches.length),
            itemBuilder: (context, index) {
              if (showDummy && index == 0) {
                return _MonthHeader(
                  month: _selectedMonth,
                  canPrev: _monthIndex < _months.length - 1,
                  canNext: _monthIndex > 0,
                  onPrev: _prevMonth,
                  onNext: _nextMonth,
                );
              }

              final matchIndex = showDummy ? index - 1 : index;

              // 빈 상태
              if (displayMatches.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Center(
                    child: Text(
                      _tabIndex == 0 ? '예정된 경기가 없습니다' : '종료된 경기가 없습니다',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                );
              }

              final match = displayMatches[matchIndex];
              return Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  bottom: AppSpacing.md,
                ),
                child: _MatchCard(
                  match: match,
                  isJoined: _joinedIds.contains(match.id),
                  onTap: () => context.push('/match', extra: match.id),
                  onToggleJoin:
                      match.isPast ? null : () => _toggleJoin(match.id),
                  ourName: ourName,
                  ourLogo: ourLogo,
                  showDummy: showDummy,
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: topPadding + AppSpacing.sm,
                          left: AppSpacing.lg,
                          right: AppSpacing.lg,
                          bottom: AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            Text('경기',
                                style: AppTextStyles.pageTitle
                                    .copyWith(color: AppColors.textPrimary)),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => context.push('/match/create'),
                              behavior: HitTestBehavior.opaque,
                              child: const Padding(
                                padding: EdgeInsets.all(AppSpacing.xs),
                                child: Icon(
                                  Icons.add_rounded,
                                  size: 28,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!showDummy)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          child: _SegmentControl(
                            selectedIndex: _tabIndex,
                            labels: const ['예정', '종료'],
                            onChanged: (i) {
                              HapticFeedback.selectionClick();
                              setState(() => _tabIndex = i);
                            },
                          ),
                        ),
                      const SizedBox(height: AppSpacing.sm),
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
    this.ourName = 'FC칼로',
    this.ourLogo,
    this.showDummy = true,
  });

  final _MatchData match;
  final bool isJoined;
  final VoidCallback onTap;
  final VoidCallback? onToggleJoin;
  final String ourName;
  final String? ourLogo;
  final bool showDummy;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.smoothSm),
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
                              shape: RoundedRectangleBorder(
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
                            shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.smoothXs),
                          ),
                          child: Text(
                            match.displayLabel ?? (match.isPast ? '완료' : '예정'),
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
                      logo: showDummy ? 'assets/images/logo_calo.png' : null,
                      logoUrl: showDummy ? null : ourLogo,
                      name: ourName,
                      score: match.isPast ? match.ourScore : null,
                      isWinner: match.result == 'W',
                      isPast: match.isPast,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // 4행: 상대팀
                    _TeamRow(
                      logo: showDummy ? match.opponentLogo : null,
                      name: match.opponentName,
                      score: match.isPast ? match.theirScore : null,
                      isWinner: match.result == 'L',
                      isPast: match.isPast,
                      isOpponent: true,
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
    this.logo,
    this.logoUrl,
    required this.name,
    this.score,
    required this.isWinner,
    required this.isPast,
    this.isOpponent = false,
  });

  final String? logo;
  final String? logoUrl;
  final String name;
  final int? score;
  final bool isWinner;
  final bool isPast;
  final bool isOpponent;

  Widget _buildLogo() {
    if (isOpponent && (logoUrl == null || logoUrl!.isEmpty)) {
      return OpponentLogo(
        teamName: name,
        size: 22,
        borderRadius: AppRadius.smoothXs,
      );
    }
    if (logo != null) {
      return ClipRRect(
        borderRadius: AppRadius.smoothXs,
        child: Image.asset(logo!, width: 22, height: 22, fit: BoxFit.cover),
      );
    }
    if (logoUrl != null && logoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: AppRadius.smoothXs,
        child: Image.network(
          logoUrl!,
          width: 22,
          height: 22,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _defaultLogo(),
        ),
      );
    }
    return _defaultLogo();
  }

  Widget _defaultLogo() {
    return Container(
      width: 22,
      height: 22,
      decoration: ShapeDecoration(
        color: isOpponent
            ? const Color(0xFFFFECEC)
            : AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smoothXs),
      ),
      child: Icon(
        isOpponent ? Icons.sports_soccer : Icons.shield_rounded,
        size: 14,
        color: AppColors.textTertiary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildLogo(),
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

// ── 세그먼트 컨트롤 (예정/종료) ──

class _SegmentControl extends StatelessWidget {
  const _SegmentControl({
    required this.selectedIndex,
    required this.labels,
    required this.onChanged,
  });

  final int selectedIndex;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.smoothSm,
        ),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final selected = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: Container(
                alignment: Alignment.center,
                decoration: selected
                    ? ShapeDecoration(
                        color: AppColors.textPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.smoothXs,
                        ),
                      )
                    : null,
                child: Text(
                  labels[i],
                  style: AppTextStyles.captionBold.copyWith(
                    color: selected ? Colors.white : AppColors.textTertiary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

