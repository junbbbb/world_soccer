import 'dart:ui';

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/section_title.dart';

// ── 더미 데이터 ──

const _teamStats = _TeamStats(
  totalMatches: 12,
  wins: 7,
  draws: 2,
  losses: 3,
  goalsFor: 28,
  goalsAgainst: 14,
  cleanSheets: 4,
);

const _myStats = _MyStats(
  name: '이병준',
  position: 'MF',
  number: 7,
  avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif',
  appearances: 10,
  goals: 5,
  assists: 3,
  mom: 2,
);

const _topScorers = [
  _PlayerRank(name: '이병준', position: 'MF', avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif', value: 5),
  _PlayerRank(name: '김태호', position: 'FW', avatarPath: 'assets/images/avatars/MOSQUERA_Headshot_web_b3sucu1j.avif', value: 4),
  _PlayerRank(name: '박정우', position: 'FW', avatarPath: 'assets/images/avatars/SALIBA_Headshot_web_khl9z1vw.avif', value: 3),
  _PlayerRank(name: '최민수', position: 'MF', avatarPath: 'assets/images/avatars/RAYA_Headshot_web_njztl3wr.avif', value: 3),
  _PlayerRank(name: '윤서준', position: 'MF', avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif', value: 2),
];

const _topAssisters = [
  _PlayerRank(name: '윤서준', position: 'MF', avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif', value: 5),
  _PlayerRank(name: '이병준', position: 'MF', avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif', value: 3),
  _PlayerRank(name: '김태호', position: 'FW', avatarPath: 'assets/images/avatars/MOSQUERA_Headshot_web_b3sucu1j.avif', value: 2),
  _PlayerRank(name: '박정우', position: 'FW', avatarPath: 'assets/images/avatars/SALIBA_Headshot_web_khl9z1vw.avif', value: 2),
  _PlayerRank(name: '최민수', position: 'MF', avatarPath: 'assets/images/avatars/RAYA_Headshot_web_njztl3wr.avif', value: 1),
];

const _recentPerformances = [
  _MatchPerformance(
    opponent: 'FC쏘아',
    date: '3/14',
    goals: 1,
    assists: 1,
    isMom: true,
  ),
  _MatchPerformance(
    opponent: '올스타FC',
    date: '3/7',
    goals: 0,
    assists: 0,
  ),
  _MatchPerformance(
    opponent: '드림FC',
    date: '2/28',
    goals: 2,
    assists: 0,
    isMom: true,
  ),
  _MatchPerformance(
    opponent: 'FC쏘아',
    date: '2/21',
    goals: 0,
    assists: 1,
  ),
  _MatchPerformance(
    opponent: '올스타FC',
    date: '2/14',
    goals: 1,
    assists: 0,
  ),
];

// ── 모델 ──

class _TeamStats {
  final int totalMatches;
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;
  final int cleanSheets;

  const _TeamStats({
    required this.totalMatches,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.cleanSheets,
  });

  double get winRate => wins / totalMatches;
  double get avgGoalsFor => goalsFor / totalMatches;
  double get avgGoalsAgainst => goalsAgainst / totalMatches;
}

class _MyStats {
  final String name;
  final String position;
  final int number;
  final String avatarPath;
  final int appearances;
  final int goals;
  final int assists;
  final int mom;

  const _MyStats({
    required this.name,
    required this.position,
    required this.number,
    required this.avatarPath,
    required this.appearances,
    required this.goals,
    required this.assists,
    required this.mom,
  });

  int get appearanceRate =>
      (appearances / _teamStats.totalMatches * 100).round();
}

class _PlayerRank {
  final String name;
  final String position;
  final String avatarPath;
  final int value;

  const _PlayerRank({
    required this.name,
    required this.position,
    required this.avatarPath,
    required this.value,
  });
}

class _MatchPerformance {
  final String opponent;
  final String date;
  final int goals;
  final int assists;
  final bool isMom;

  const _MatchPerformance({
    required this.opponent,
    required this.date,
    required this.goals,
    required this.assists,
    this.isMom = false,
  });
}

// ── StatsTab ──

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  int _segmentIndex = 0;

  // header(56) + segment(44) + gap(24) = 124
  static const _fullHeaderHeight = 124.0;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        IndexedStack(
          index: _segmentIndex,
          children: [
            _TeamStatsView(
              scrollPaddingTop: topPadding + _fullHeaderHeight,
            ),
            _MyStatsView(
              scrollPaddingTop: topPadding + _fullHeaderHeight,
            ),
          ],
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: Colors.white.withValues(alpha: 0.85),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
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
                            '스탯',
                            style: AppTextStyles.pageTitle.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: AppSpacing.paddingPage,
                      child: _SegmentControl(
                        selectedIndex: _segmentIndex,
                        onChanged: (i) => setState(() => _segmentIndex = i),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── 세그먼트 컨트롤 ──

class _SegmentControl extends StatelessWidget {
  const _SegmentControl({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: ShapeDecoration(
        color: AppColors.surface,
        shape: SmoothRectangleBorder(
          borderRadius: AppRadius.smoothMd,
        ),
      ),
      child: Row(
        children: [
          _SegmentButton(
            label: '팀 스탯',
            isSelected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          _SegmentButton(
            label: '내 스탯',
            isSelected: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: isSelected
              ? ShapeDecoration(
                  color: Colors.white,
                  shape: SmoothRectangleBorder(
                    borderRadius: AppRadius.smoothSm,
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                )
              : null,
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}

// ── 팀 스탯 뷰 ──

class _TeamStatsView extends StatelessWidget {
  const _TeamStatsView({this.scrollPaddingTop = 0});

  final double scrollPaddingTop;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: scrollPaddingTop),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 전적 요약
          Padding(
            padding: AppSpacing.paddingPage,
            child: _RecordOverviewCard(stats: _teamStats),
          ),
          const SizedBox(height: AppSpacing.xxl),
          // 시즌 기록
          Padding(
            padding: AppSpacing.paddingPage,
            child: const SectionTitle('시즌 기록'),
          ),
          Padding(
            padding: AppSpacing.paddingPage,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.base,
              ),
              decoration: ShapeDecoration(
                color: AppColors.surfaceLight,
                shape: SmoothRectangleBorder(
                  borderRadius: AppRadius.smoothMd,
                ),
              ),
              child: Column(
                children: [
                  _statRow('총 득점', '${_teamStats.goalsFor}'),
                  _statDivider(),
                  _statRow('총 실점', '${_teamStats.goalsAgainst}'),
                  _statDivider(),
                  _statRow('평균 득점', _teamStats.avgGoalsFor.toStringAsFixed(1)),
                  _statDivider(),
                  _statRow('평균 실점', _teamStats.avgGoalsAgainst.toStringAsFixed(1)),
                  _statDivider(),
                  _statRow('최다 득점', '5골 (vs FC쏘아)'),
                  _statDivider(),
                  _statRow('클린 시트', '${_teamStats.cleanSheets}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          // 득점 랭킹
          Padding(
            padding: AppSpacing.paddingPage,
            child: const SectionTitle('득점 랭킹'),
          ),
          ...List.generate(_topScorers.length, (i) {
            final player = _topScorers[i];
            return _RankingRow(
              rank: i + 1,
              player: player,
              unit: '골',
            );
          }),
          const SizedBox(height: AppSpacing.xxl),
          // 어시스트 랭킹
          Padding(
            padding: AppSpacing.paddingPage,
            child: const SectionTitle('어시스트 랭킹'),
          ),
          ...List.generate(_topAssisters.length, (i) {
            final player = _topAssisters[i];
            return _RankingRow(
              rank: i + 1,
              player: player,
              unit: '도움',
            );
          }),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.heading.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statDivider() {
    return Divider(
      height: 0.5,
      color: AppColors.textPrimary.withValues(alpha: 0.06),
    );
  }
}

// ── 전적 요약 카드 ──

class _RecordOverviewCard extends StatelessWidget {
  const _RecordOverviewCard({required this.stats});

  final _TeamStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: ShapeDecoration(
        color: AppColors.surfaceLight,
        shape: SmoothRectangleBorder(
          borderRadius: AppRadius.smoothMd,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '전체 ${stats.totalMatches}경기',
                style: AppTextStyles.heading.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '승률 ${(stats.winRate * 100).round()}%',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          // 승/무/패 바
          ClipSmoothRect(
            radius: AppRadius.smoothFull,
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: stats.wins,
                    child: Container(color: AppColors.primary),
                  ),
                  Expanded(
                    flex: stats.draws,
                    child: Container(color: AppColors.iconInactive),
                  ),
                  Expanded(
                    flex: stats.losses,
                    child: Container(color: const Color(0xFFE5484D)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _RecordLabel(
                color: AppColors.primary,
                label: '${stats.wins}승',
              ),
              const SizedBox(width: AppSpacing.base),
              _RecordLabel(
                color: AppColors.iconInactive,
                label: '${stats.draws}무',
              ),
              const SizedBox(width: AppSpacing.base),
              _RecordLabel(
                color: const Color(0xFFE5484D),
                label: '${stats.losses}패',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecordLabel extends StatelessWidget {
  const _RecordLabel({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.captionMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ── 스탯 카드 ──

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.sub,
  });

  final String label;
  final String value;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: ShapeDecoration(
        color: AppColors.surfaceLight,
        shape: SmoothRectangleBorder(
          borderRadius: AppRadius.smoothMd,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.sectionTitle.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              sub!,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── 내 스탯 뷰 ──

class _MyStatsView extends StatelessWidget {
  const _MyStatsView({this.scrollPaddingTop = 0});

  final double scrollPaddingTop;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: scrollPaddingTop),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 프로필 헤더
          Padding(
            padding: AppSpacing.paddingPage,
            child: Row(
              children: [
                ClipSmoothRect(
                  radius: AppRadius.smoothMd,
                  child: Image.asset(
                    _myStats.avatarPath,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: AppSpacing.base),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _myStats.name,
                      style: AppTextStyles.heading.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '${_myStats.position} · #${_myStats.number}',
                      style: AppTextStyles.captionMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          // 칭호 배지
          Padding(
            padding: AppSpacing.paddingPage,
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: const [
                _TitleBadge(label: '득점왕', color: Color(0xFFFFF3E0), textColor: Color(0xFFE65100)),
                _TitleBadge(label: '어시왕', color: Color(0xFFE3F2FD), textColor: Color(0xFF1565C0)),
                _TitleBadge(label: '우측면 파괴자', color: Color(0xFFFFEBEE), textColor: Color(0xFFC62828)),
                _TitleBadge(label: '성장왕', color: Color(0xFFE8F5E9), textColor: Color(0xFF2E7D32)),
                _TitleBadge(label: '프리킥 장인', color: Color(0xFFF3E5F5), textColor: Color(0xFF7B1FA2)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // 스탯 리스트
          Padding(
            padding: AppSpacing.paddingPage,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.base,
              ),
              decoration: ShapeDecoration(
                color: AppColors.surfaceLight,
                shape: SmoothRectangleBorder(
                  borderRadius: AppRadius.smoothMd,
                ),
              ),
              child: Column(
                children: [
                  _statRow('출전', '${_myStats.appearances}경기'),
                  _statDivider(),
                  _statRow('골', '${_myStats.goals}'),
                  _statDivider(),
                  _statRow('어시스트', '${_myStats.assists}'),
                  _statDivider(),
                  _statRow('MOM', '${_myStats.mom}'),
                  _statDivider(),
                  _statRow('출전율', '${_myStats.appearanceRate}%'),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          // 최근 경기 기록
          Padding(
            padding: AppSpacing.paddingPage,
            child: const SectionTitle('최근 경기 기록'),
          ),
          ...List.generate(_recentPerformances.length, (i) {
            final perf = _recentPerformances[i];
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  border: i < _recentPerformances.length - 1
                      ? Border(
                          bottom: BorderSide(
                            color:
                                AppColors.textPrimary.withValues(alpha: 0.06),
                          ),
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'vs ${perf.opponent}',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            perf.date,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (perf.isMom) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFFFC107),
                          shape: SmoothRectangleBorder(
                            borderRadius: AppRadius.smoothSm,
                          ),
                        ),
                        child: Text(
                          'MOM',
                          style: AppTextStyles.captionBold.copyWith(
                            color: const Color(0xFF795500),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                    ],
                    _PerfBadge(
                      icon: Icons.sports_soccer,
                      value: '${perf.goals}',
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _PerfBadge(
                      icon: Icons.handshake_outlined,
                      value: '${perf.assists}',
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.heading.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statDivider() {
    return Divider(
      height: 0.5,
      color: AppColors.textPrimary.withValues(alpha: 0.06),
    );
  }
}

// ── 랭킹 행 (아바타 포함) ──

class _RankingRow extends StatelessWidget {
  const _RankingRow({
    required this.rank,
    required this.player,
    required this.unit,
  });

  final int rank;
  final _PlayerRank player;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$rank',
              style: AppTextStyles.label.copyWith(
                color: rank <= 3
                    ? AppColors.primary
                    : AppColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          ClipSmoothRect(
            radius: AppRadius.smoothSm,
            child: Image.asset(
              player.avatarPath,
              width: 36,
              height: 36,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              player.name,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            '${player.value}$unit',
            style: AppTextStyles.label.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 칭호 배지 ──

class _TitleBadge extends StatelessWidget {
  const _TitleBadge({
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: ShapeDecoration(
        color: color,
        shape: SmoothRectangleBorder(
          borderRadius: AppRadius.smoothSm,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.captionMedium.copyWith(
          color: textColor,
        ),
      ),
    );
  }
}

class _PerfBadge extends StatelessWidget {
  const _PerfBadge({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          value,
          style: AppTextStyles.captionMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
