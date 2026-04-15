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

class _MatchTabState extends ConsumerState<MatchTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final Set<String> _joinedIds = {'m11', 'm10', 'm9', 'm8', 'm6', 'm5', 'm3'};

  static const _headerHeight = 108.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        : realMatchList.map(_fromMatch).toList();

    // 예정/종료 분리
    final all = showDummy ? _dummyMatches : realMatches;
    final upcoming = all.where((m) => !m.isPast).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final completed = all.where((m) => m.isPast).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final scrollTop = topPadding + _headerHeight + AppSpacing.sm;

    return ColoredBox(
      color: AppColors.surface,
      child: Stack(
        children: [
          // ── 본문: 탭별 리스트 ──
          TabBarView(
            controller: _tabController,
            children: [
              _MatchListView(
                matches: upcoming,
                emptyText: '예정된 경기가 없습니다',
                scrollPaddingTop: scrollTop,
                joinedIds: _joinedIds,
                onTapMatch: (id) => context.push('/match', extra: id),
                onToggleJoin: _toggleJoin,
                ourName: ourName,
                ourLogo: ourLogo,
                showDummy: showDummy,
              ),
              _MatchListView(
                matches: completed,
                emptyText: '종료된 경기가 없습니다',
                scrollPaddingTop: scrollTop,
                joinedIds: _joinedIds,
                onTapMatch: (id) => context.push('/match', extra: id),
                onToggleJoin: null,
                ourName: ourName,
                ourLogo: ourLogo,
                showDummy: showDummy,
              ),
            ],
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
                  padding: EdgeInsets.only(top: topPadding + AppSpacing.sm),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: Row(
                          children: [
                            Text(
                              '경기',
                              style: AppTextStyles.pageTitle.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
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
                      const SizedBox(height: AppSpacing.md),
                      // 첫 탭 텍스트가 페이지 edge(AppSpacing.lg=20)와 맞도록
                      // labelPadding(base=16) 차액만큼(xs=4) 외부 패딩.
                      Padding(
                        padding:
                            const EdgeInsets.only(left: AppSpacing.xs),
                        child: TabBar(
                          controller: _tabController,
                          labelStyle: AppTextStyles.body
                              .copyWith(fontWeight: FontWeight.w700),
                          labelColor: AppColors.textPrimary,
                          unselectedLabelStyle: AppTextStyles.body,
                          unselectedLabelColor: AppColors.textTertiary,
                          indicator: const UnderlineTabIndicator(
                            borderSide: BorderSide(
                              color: AppColors.textPrimary,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.zero,
                          ),
                          tabAlignment: TabAlignment.start,
                          isScrollable: true,
                          padding: EdgeInsets.zero,
                          labelPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.base,
                          ),
                          dividerColor:
                              AppColors.textPrimary.withValues(alpha: 0.06),
                          overlayColor:
                              WidgetStateProperty.all(Colors.transparent),
                          tabs: const [
                            Tab(text: '예정'),
                            Tab(text: '종료'),
                          ],
                        ),
                      ),
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

  _MatchData _fromMatch(Match m) {
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
  }
}

// ── 경기 리스트 (탭 하나) ──

class _MatchListView extends StatelessWidget {
  const _MatchListView({
    required this.matches,
    required this.emptyText,
    required this.scrollPaddingTop,
    required this.joinedIds,
    required this.onTapMatch,
    required this.onToggleJoin,
    required this.ourName,
    required this.ourLogo,
    required this.showDummy,
  });

  final List<_MatchData> matches;
  final String emptyText;
  final double scrollPaddingTop;
  final Set<String> joinedIds;
  final ValueChanged<String> onTapMatch;
  final ValueChanged<String>? onToggleJoin;
  final String ourName;
  final String? ourLogo;
  final bool showDummy;

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: scrollPaddingTop + 60),
        child: Center(
          child: Text(
            emptyText,
            style: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.only(
        top: scrollPaddingTop,
        bottom: AppSpacing.xxxxl,
      ),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.md,
          ),
          child: _MatchCard(
            match: match,
            isJoined: joinedIds.contains(match.id),
            onTap: () => onTapMatch(match.id),
            onToggleJoin: onToggleJoin == null || match.isPast
                ? null
                : () => onToggleJoin!(match.id),
            ourName: ourName,
            ourLogo: ourLogo,
            showDummy: showDummy,
          ),
        );
      },
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
                margin: const EdgeInsets.only(
                    left: AppSpacing.sm, right: AppSpacing.md),
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
                            match.displayLabel ??
                                (match.isPast ? '완료' : '예정'),
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
        color: isOpponent ? const Color(0xFFFFECEC) : AppColors.surface,
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
              color: isWinner ? AppColors.textPrimary : AppColors.textTertiary,
            ),
          ),
      ],
    );
  }
}
