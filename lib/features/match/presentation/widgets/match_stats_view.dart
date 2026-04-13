import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/dev_settings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/section_title.dart';

// ── 더미 데이터 ──

class _TeamStats {
  final int totalMatches, wins, draws, losses, goalsFor, goalsAgainst, cleanSheets;
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

class _PlayerRank {
  final String name, position, avatarPath;
  final int value;
  const _PlayerRank({
    required this.name,
    required this.position,
    required this.avatarPath,
    required this.value,
  });
}

class _MyStats {
  final String name, position, avatarPath;
  final int number, appearances, goals, assists, mom;
  const _MyStats({
    required this.name,
    required this.position,
    required this.avatarPath,
    required this.number,
    required this.appearances,
    required this.goals,
    required this.assists,
    required this.mom,
  });
  int get appearanceRate => (appearances / _teamStats.totalMatches * 100).round();
}

class _MatchPerformance {
  final String opponent, date;
  final int goals, assists;
  final bool isMom;
  const _MatchPerformance({
    required this.opponent,
    required this.date,
    required this.goals,
    required this.assists,
    this.isMom = false,
  });
}

const _teamStats = _TeamStats(
  totalMatches: 12, wins: 7, draws: 2, losses: 3,
  goalsFor: 28, goalsAgainst: 14, cleanSheets: 4,
);

const _myStats = _MyStats(
  name: '이병준', position: 'MF', number: 7,
  avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif',
  appearances: 10, goals: 5, assists: 3, mom: 2,
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
  _MatchPerformance(opponent: 'FC쏘아', date: '3/14', goals: 1, assists: 1, isMom: true),
  _MatchPerformance(opponent: '올스타FC', date: '3/7', goals: 0, assists: 0),
  _MatchPerformance(opponent: '드림FC', date: '2/28', goals: 2, assists: 0, isMom: true),
  _MatchPerformance(opponent: 'FC쏘아', date: '2/21', goals: 0, assists: 1),
  _MatchPerformance(opponent: '올스타FC', date: '2/14', goals: 1, assists: 0),
];

// ── surfaceLight 카드 데코레이션 (선 없음) ──

final _cardDecoration = ShapeDecoration(
  color: AppColors.surfaceLight,
  shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothLg),
);

// ── MatchStatsView ──

class MatchStatsView extends ConsumerWidget {
  const MatchStatsView({
    super.key,
    this.scrollPaddingTop = 0,
    this.subIndex = 0,
  });

  final double scrollPaddingTop;
  final int subIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showDummy = ref.watch(showDummyDataProvider);
    if (!showDummy) {
      return Padding(
        padding: EdgeInsets.only(top: scrollPaddingTop + 60),
        child: Center(
          child: Text(
            '데이터가 없습니다',
            style: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
          ),
        ),
      );
    }

    return IndexedStack(
      index: subIndex,
      children: [
        _TeamStatsContent(scrollPaddingTop: scrollPaddingTop),
        _MyStatsContent(scrollPaddingTop: scrollPaddingTop),
      ],
    );
  }
}

// ── 팀 스탯 ──

class _TeamStatsContent extends StatelessWidget {
  const _TeamStatsContent({this.scrollPaddingTop = 0});
  final double scrollPaddingTop;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: scrollPaddingTop, bottom: AppSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 전적 오버뷰
          Padding(
            padding: AppSpacing.paddingPage,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.base),
              decoration: _cardDecoration,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '전체 ${_teamStats.totalMatches}경기',
                        style: AppTextStyles.heading.copyWith(color: AppColors.textPrimary),
                      ),
                      Text(
                        '승률 ${(_teamStats.winRate * 100).round()}%',
                        style: AppTextStyles.captionBold.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.base),
                  ClipSmoothRect(
                    radius: AppRadius.smoothFull,
                    child: SizedBox(
                      height: 8,
                      child: Row(
                        children: [
                          Expanded(flex: _teamStats.wins, child: Container(color: AppColors.primary)),
                          if (_teamStats.draws > 0)
                            Expanded(flex: _teamStats.draws, child: Container(color: AppColors.iconInactive)),
                          Expanded(flex: _teamStats.losses, child: Container(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      _RecordLabel(color: AppColors.primary, label: '${_teamStats.wins}승'),
                      const SizedBox(width: AppSpacing.base),
                      _RecordLabel(color: AppColors.iconInactive, label: '${_teamStats.draws}무'),
                      const SizedBox(width: AppSpacing.base),
                      _RecordLabel(color: AppColors.error, label: '${_teamStats.losses}패'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // 시즌 기록
          const Padding(padding: AppSpacing.paddingPage, child: SectionTitle('시즌 기록')),
          Padding(
            padding: AppSpacing.paddingPage,
            child: Container(
              decoration: _cardDecoration,
              child: Column(
                children: [
                  _StatRow(label: '총 득점', value: '${_teamStats.goalsFor}'),
                  _divider(),
                  _StatRow(label: '총 실점', value: '${_teamStats.goalsAgainst}'),
                  _divider(),
                  _StatRow(label: '평균 득점', value: _teamStats.avgGoalsFor.toStringAsFixed(1)),
                  _divider(),
                  _StatRow(label: '평균 실점', value: _teamStats.avgGoalsAgainst.toStringAsFixed(1)),
                  _divider(),
                  _StatRow(label: '최다 득점', value: '5골 (vs FC쏘아)'),
                  _divider(),
                  _StatRow(label: '클린 시트', value: '${_teamStats.cleanSheets}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // 득점 랭킹
          const Padding(padding: AppSpacing.paddingPage, child: SectionTitle('득점 랭킹')),
          Padding(
            padding: AppSpacing.paddingPage,
            child: Container(
              decoration: _cardDecoration,
              child: Column(
                children: List.generate(_topScorers.length, (i) {
                  return Column(
                    children: [
                      _RankingRow(rank: i + 1, player: _topScorers[i], unit: '골'),
                      if (i < _topScorers.length - 1) _divider(),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // 어시스트 랭킹
          const Padding(padding: AppSpacing.paddingPage, child: SectionTitle('어시스트 랭킹')),
          Padding(
            padding: AppSpacing.paddingPage,
            child: Container(
              decoration: _cardDecoration,
              child: Column(
                children: List.generate(_topAssisters.length, (i) {
                  return Column(
                    children: [
                      _RankingRow(rank: i + 1, player: _topAssisters[i], unit: '도움'),
                      if (i < _topAssisters.length - 1) _divider(),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 내 스탯 ──

class _MyStatsContent extends StatelessWidget {
  const _MyStatsContent({this.scrollPaddingTop = 0});
  final double scrollPaddingTop;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: scrollPaddingTop, bottom: AppSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 프로필
          Padding(
            padding: AppSpacing.paddingPage,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.base),
              decoration: _cardDecoration,
              child: Row(
                children: [
                  ClipSmoothRect(
                    radius: AppRadius.smoothSm,
                    child: Image.asset(_myStats.avatarPath, width: 56, height: 56, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: AppSpacing.base),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_myStats.name}  #${_myStats.number}',
                          style: AppTextStyles.heading.copyWith(color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          _myStats.position,
                          style: AppTextStyles.captionMedium.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  _MiniStat(label: '골', value: '${_myStats.goals}'),
                  const SizedBox(width: AppSpacing.lg),
                  _MiniStat(label: '도움', value: '${_myStats.assists}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 칭호
          Padding(
            padding: AppSpacing.paddingPage,
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: const [
                _TitleBadge(label: '득점왕', bg: Color(0xFFFFF3E0), fg: Color(0xFFE65100)),
                _TitleBadge(label: '어시왕', bg: Color(0xFFE3F2FD), fg: Color(0xFF1565C0)),
                _TitleBadge(label: '우측면 파괴자', bg: Color(0xFFFFEBEE), fg: Color(0xFFC62828)),
                _TitleBadge(label: '성장왕', bg: Color(0xFFE8F5E9), fg: Color(0xFF2E7D32)),
                _TitleBadge(label: '프리킥 장인', bg: Color(0xFFF3E5F5), fg: Color(0xFF7B1FA2)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // 스탯
          const Padding(padding: AppSpacing.paddingPage, child: SectionTitle('시즌 기록')),
          Padding(
            padding: AppSpacing.paddingPage,
            child: Container(
              decoration: _cardDecoration,
              child: Column(
                children: [
                  _StatRow(label: '출전', value: '${_myStats.appearances}경기'),
                  _divider(),
                  _StatRow(label: '골', value: '${_myStats.goals}'),
                  _divider(),
                  _StatRow(label: '어시스트', value: '${_myStats.assists}'),
                  _divider(),
                  _StatRow(label: 'MOM', value: '${_myStats.mom}'),
                  _divider(),
                  _StatRow(label: '출전율', value: '${_myStats.appearanceRate}%'),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // 최근 경기 기록
          const Padding(padding: AppSpacing.paddingPage, child: SectionTitle('최근 경기 기록')),
          Padding(
            padding: AppSpacing.paddingPage,
            child: Container(
              decoration: _cardDecoration,
              child: Column(
                children: List.generate(_recentPerformances.length, (i) {
                  final perf = _recentPerformances[i];
                  return Column(
                    children: [
                      _PerformanceRow(perf: perf),
                      if (i < _recentPerformances.length - 1) _divider(),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 공용 divider ──

Widget _divider() {
  return Divider(
    height: 1,
    thickness: 1,
    indent: AppSpacing.base,
    endIndent: AppSpacing.base,
    color: AppColors.textPrimary.withValues(alpha: 0.06),
  );
}

// ── 스탯 행 (아이콘 없이 텍스트만) ──

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.md),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
          const Spacer(),
          Text(value, style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          )),
        ],
      ),
    );
  }
}

// ── 랭킹 행 (원형 장식 없이 텍스트 순위만) ──

class _RankingRow extends StatelessWidget {
  const _RankingRow({required this.rank, required this.player, required this.unit});
  final int rank;
  final _PlayerRank player;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$rank',
              style: AppTextStyles.label.copyWith(
                color: rank <= 3 ? AppColors.primary : AppColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          ClipSmoothRect(
            radius: AppRadius.smoothSm,
            child: Image.asset(player.avatarPath, width: 36, height: 36, fit: BoxFit.cover),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(player.name, style: AppTextStyles.body.copyWith(color: AppColors.textPrimary)),
                Text(player.position, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
              ],
            ),
          ),
          Text(
            '${player.value}$unit',
            style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

// ── 전적 라벨 (색 점 + 텍스트) ──

class _RecordLabel extends StatelessWidget {
  const _RecordLabel({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTextStyles.captionMedium.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}

// ── 칭호 뱃지 (이모지/아이콘 없이 텍스트만) ──

class _TitleBadge extends StatelessWidget {
  const _TitleBadge({required this.label, required this.bg, required this.fg});
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: ShapeDecoration(
        color: bg,
        shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothFull),
      ),
      child: Text(
        label,
        style: AppTextStyles.captionMedium.copyWith(color: fg),
      ),
    );
  }
}

// ── 미니 스탯 (프로필 카드 우측) ──

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: AppTextStyles.heading.copyWith(color: AppColors.textPrimary, fontSize: 18)),
        const SizedBox(height: AppSpacing.xxs),
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
      ],
    );
  }
}

// ── 경기 퍼포먼스 행 ──

class _PerformanceRow extends StatelessWidget {
  const _PerformanceRow({required this.perf});
  final _MatchPerformance perf;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('vs ${perf.opponent}', style: AppTextStyles.body.copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: AppSpacing.xxs),
                Text(perf.date, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
              ],
            ),
          ),
          if (perf.isMom) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: ShapeDecoration(
                color: AppColors.momBackground,
                shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothFull),
              ),
              child: Text(
                'MOM',
                style: AppTextStyles.captionBold.copyWith(color: AppColors.momText, fontSize: 11),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Text('${perf.goals}골', style: AppTextStyles.captionMedium.copyWith(color: AppColors.textPrimary)),
          const SizedBox(width: AppSpacing.md),
          Text('${perf.assists}도움', style: AppTextStyles.captionMedium.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
