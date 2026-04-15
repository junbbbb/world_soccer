import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../runtime/providers.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/team_logo_view.dart';
import '../../../types/profile.dart';
import '../../../types/team.dart';
import 'widgets/team_settings_sheet.dart';

// TeamStats, PlayerRank → types/ 에서 import. TeamMember → types/team.dart.

// ── TeamTab ──

class TeamTab extends ConsumerStatefulWidget {
  const TeamTab({super.key});

  @override
  ConsumerState<TeamTab> createState() => _TeamTabState();
}

class _TeamTabState extends ConsumerState<TeamTab> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _headerHeight = 108.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final scrollTop = topPadding + _headerHeight + AppSpacing.sm;

    return ColoredBox(
      color: Colors.white,
      child: Stack(
        children: [
          // ── 탭 본문 ──
          TabBarView(
            controller: _tabController,
            children: [
              _OverviewView(scrollPaddingTop: scrollTop),
              _TeamStatsView(scrollPaddingTop: scrollTop),
              _MembersView(scrollPaddingTop: scrollTop),
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
                  color: Colors.white.withValues(alpha: 0.85),
                  padding: EdgeInsets.only(top: topPadding + AppSpacing.sm),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg),
                        child: Row(
                          children: [
                            Text(
                              '팀',
                              style: AppTextStyles.pageTitle
                                  .copyWith(color: AppColors.textPrimary),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () async {
                                HapticFeedback.selectionClick();
                                final team = await ref
                                    .read(currentTeamProvider.future);
                                if (!context.mounted) return;
                                if (team == null) {
                                  // 팀 없으면 바로 "새 팀 만들기" 화면
                                  context.push('/team/create');
                                  return;
                                }
                                showTeamSettingsSheet(context, team);
                              },
                              behavior: HitTestBehavior.opaque,
                              child: const Icon(
                                Icons.settings_outlined,
                                color: AppColors.textTertiary,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // 첫 탭 텍스트가 페이지 edge(AppSpacing.lg=20)와 맞도록
                      // labelPadding(base=16) 차액만큼(xs=4) 외부 패딩.
                      Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.xs),
                        child: TabBar(
                          controller: _tabController,
                          labelStyle: AppTextStyles.body
                              .copyWith(fontWeight: FontWeight.w700),
                          labelColor: AppColors.textPrimary,
                          unselectedLabelStyle: AppTextStyles.body,
                          unselectedLabelColor: AppColors.textTertiary,
                          indicator: const UnderlineTabIndicator(
                            borderSide: BorderSide(
                                color: AppColors.textPrimary, width: 2),
                            borderRadius: BorderRadius.zero,
                          ),
                          tabAlignment: TabAlignment.start,
                          isScrollable: true,
                          padding: EdgeInsets.zero,
                          labelPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.base),
                          dividerColor:
                              AppColors.textPrimary.withValues(alpha: 0.06),
                          overlayColor:
                              WidgetStateProperty.all(Colors.transparent),
                          tabs: const [
                            Tab(text: '오버뷰'),
                            Tab(text: '팀 스탯'),
                            Tab(text: '멤버'),
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
}

// ══════════════════════════════════════════════
// 탭 1: 오버뷰
// ══════════════════════════════════════════════

class _OverviewView extends ConsumerWidget {
  const _OverviewView({required this.scrollPaddingTop});
  final double scrollPaddingTop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamAsync = ref.watch(currentTeamProvider);
    final team = teamAsync.maybeWhen(data: (t) => t, orElse: () => null);

    // 팀 없음 — 새 팀 만들기 CTA
    if (team == null) {
      return Padding(
        padding: EdgeInsets.only(top: scrollPaddingTop + 60),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '아직 팀이 없어요',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textTertiary),
              ),
              const SizedBox(height: AppSpacing.md),
              GestureDetector(
                onTap: () => context.push('/team/create'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  decoration: ShapeDecoration(
                    color: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.smoothSm,
                    ),
                  ),
                  child: Text(
                    '새 팀 만들기',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.only(top: scrollPaddingTop),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TeamInfoSection(team: team),
          const SizedBox(height: AppSpacing.xxl),
          const _InviteLinkCard(),
          const SizedBox(height: AppSpacing.xxl),
          _TeamSummarySection(teamId: team.id),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}

// ── 팀 정보 섹션 ──

class _TeamInfoSection extends ConsumerWidget {
  const _TeamInfoSection({required this.team});
  final Team team;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(teamMembersByTeamProvider(team.id));
    final memberCount = membersAsync.maybeWhen(
      data: (list) => list.length,
      orElse: () => 0,
    );
    final yearText = '${team.createdAt.year}년 창단';

    return Padding(
      padding: AppSpacing.paddingPage,
      child: Column(
        children: [
          TeamLogoView(
            team: team,
            size: 80,
            borderRadius: AppRadius.smoothLg,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            team.name,
            style: AppTextStyles.sectionTitle.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          if ((team.description ?? '').isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              team.description!,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyRegular.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          Text(
            yearText,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _InfoBadge(label: '멤버 $memberCount명'),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: ShapeDecoration(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smoothFull),
      ),
      child: Text(
        label,
        style: AppTextStyles.captionMedium
            .copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

// ── 팀원 초대 버튼 ──

class _InviteLinkCard extends StatelessWidget {
  const _InviteLinkCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingPage,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (_) => const _InviteBottomSheet(),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: ShapeDecoration(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.smoothMd),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_add_alt_1_rounded,
                  size: 18, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '팀원 초대',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 초대 바텀시트 ──

class _InviteBottomSheet extends StatelessWidget {
  const _InviteBottomSheet();

  static const _inviteUrl = 'peacefc.app/invite/fc-calor-abc123';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 핸들바
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.base),
                  decoration: BoxDecoration(
                    color: AppColors.iconInactive,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                '팀원 초대하기',
                style: AppTextStyles.sectionTitle
                    .copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '링크를 공유하고 새로운 팀원을 초대하세요',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textTertiary),
              ),
              const SizedBox(height: AppSpacing.xl),

              // 초대 링크 박스
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: AppSpacing.md,
                ),
                decoration: ShapeDecoration(
                  color: AppColors.surfaceLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.smoothSm,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link_rounded,
                        size: 18, color: AppColors.textTertiary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _inviteUrl,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('링크가 복사되었습니다'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.smoothXs,
                          ),
                        ),
                        child: Text(
                          '복사',
                          style: AppTextStyles.captionBold
                              .copyWith(color: AppColors.textPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.base),

              // 공유 버튼들
              Row(
                children: [
                  Expanded(
                    child: _InviteShareButton(
                      icon: Icons.chat_bubble_rounded,
                      label: '카카오톡',
                      color: const Color(0xFFFEE500),
                      textColor: const Color(0xFF3C1E1E),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _InviteShareButton(
                      icon: Icons.ios_share_rounded,
                      label: '공유하기',
                      color: Colors.white,
                      textColor: AppColors.textPrimary,
                      hasBorder: true,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InviteShareButton extends StatelessWidget {
  const _InviteShareButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
    this.hasBorder = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  final bool hasBorder;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
        decoration: ShapeDecoration(
          color: color,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.smoothSm,
            side: hasBorder
                ? const BorderSide(color: AppColors.iconInactive)
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 팀 기록 요약 ──

class _TeamSummarySection extends ConsumerWidget {
  const _TeamSummarySection({required this.teamId});
  final String teamId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(teamStatsByTeamProvider(teamId));
    final stats = statsAsync.maybeWhen(
      data: (s) => s,
      orElse: () => null,
    );
    final totalRecord = stats == null
        ? '—'
        : '${stats.wins}승 ${stats.draws}무 ${stats.losses}패';
    final winRateText = stats == null || stats.totalMatches == 0
        ? '—'
        : '${(stats.winRate * 100).round()}%';

    return Padding(
      padding: AppSpacing.paddingPage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('팀 기록'),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(label: '통산 전적', value: totalRecord),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _SummaryCard(label: '승률', value: winRateText),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: ShapeDecoration(
        color: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smoothMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textTertiary)),
          const SizedBox(height: AppSpacing.xs),
          Text(value,
              style: AppTextStyles.heading
                  .copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 탭 2: 팀 스탯
// ══════════════════════════════════════════════

class _TeamStatsView extends ConsumerWidget {
  const _TeamStatsView({required this.scrollPaddingTop});
  final double scrollPaddingTop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamAsync = ref.watch(currentTeamProvider);
    final team = teamAsync.maybeWhen(data: (t) => t, orElse: () => null);

    if (team == null) {
      return Padding(
        padding: EdgeInsets.only(top: scrollPaddingTop + 60),
        child: Center(
          child: Text('팀을 먼저 만들어주세요',
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textTertiary)),
        ),
      );
    }

    final statsAsync = ref.watch(teamStatsByTeamProvider(team.id));
    final goalsAsync = ref.watch(teamGoalRankingProvider(team.id));
    final assistsAsync = ref.watch(teamAssistRankingProvider(team.id));

    final stats = statsAsync.maybeWhen(
      data: (s) => s,
      orElse: () => const TeamStats(
        totalMatches: 0,
        wins: 0,
        draws: 0,
        losses: 0,
        goalsFor: 0,
        goalsAgainst: 0,
        cleanSheets: 0,
      ),
    );
    final goals = goalsAsync.maybeWhen(
      data: (list) => list,
      orElse: () => const <PlayerRank>[],
    );
    final assists = assistsAsync.maybeWhen(
      data: (list) => list,
      orElse: () => const <PlayerRank>[],
    );

    return SingleChildScrollView(
      padding: EdgeInsets.only(top: scrollPaddingTop),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 전적 요약
          Padding(
            padding: AppSpacing.paddingPage,
            child: _RecordOverviewCard(stats: stats),
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
                shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.smoothMd),
              ),
              child: Column(
                children: [
                  _statRow('총 득점', '${stats.goalsFor}'),
                  _statDivider(),
                  _statRow('총 실점', '${stats.goalsAgainst}'),
                  _statDivider(),
                  _statRow('평균 득점', stats.avgGoalsFor.toStringAsFixed(1)),
                  _statDivider(),
                  _statRow(
                      '평균 실점', stats.avgGoalsAgainst.toStringAsFixed(1)),
                  _statDivider(),
                  _statRow('클린 시트', '${stats.cleanSheets}'),
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
          if (goals.isEmpty)
            _emptyRankingText('기록된 득점이 없습니다')
          else
            ...List.generate(goals.length, (i) {
              return _RankingRow(rank: i + 1, player: goals[i], unit: '골');
            }),
          const SizedBox(height: AppSpacing.xxl),

          // 어시스트 랭킹
          Padding(
            padding: AppSpacing.paddingPage,
            child: const SectionTitle('어시스트 랭킹'),
          ),
          if (assists.isEmpty)
            _emptyRankingText('기록된 어시스트가 없습니다')
          else
            ...List.generate(assists.length, (i) {
              return _RankingRow(
                  rank: i + 1, player: assists[i], unit: '도움');
            }),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  static Widget _emptyRankingText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
      ),
    );
  }

  static Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Text(label,
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textSecondary)),
          const Spacer(),
          Text(value,
              style: AppTextStyles.heading
                  .copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  static Widget _statDivider() {
    return Divider(
      height: 0.5,
      color: AppColors.textPrimary.withValues(alpha: 0.06),
    );
  }
}

// ── 전적 요약 카드 ──

class _RecordOverviewCard extends StatelessWidget {
  const _RecordOverviewCard({required this.stats});
  final TeamStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: ShapeDecoration(
        color: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smoothMd),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('전체 ${stats.totalMatches}경기',
                  style: AppTextStyles.heading
                      .copyWith(color: AppColors.textPrimary)),
              Text('승률 ${(stats.winRate * 100).round()}%',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          ClipRRect(
            borderRadius: AppRadius.smoothFull,
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(
                      flex: stats.wins,
                      child: Container(color: AppColors.primary)),
                  Expanded(
                      flex: stats.draws,
                      child: Container(color: AppColors.iconInactive)),
                  Expanded(
                      flex: stats.losses,
                      child: Container(color: const Color(0xFFE5484D))),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _RecordLabel(color: AppColors.primary, label: '${stats.wins}승'),
              const SizedBox(width: AppSpacing.base),
              _RecordLabel(
                  color: AppColors.iconInactive, label: '${stats.draws}무'),
              const SizedBox(width: AppSpacing.base),
              _RecordLabel(
                  color: const Color(0xFFE5484D), label: '${stats.losses}패'),
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
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(label,
            style: AppTextStyles.captionMedium
                .copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}

// ── 랭킹 행 ──

class _RankingRow extends StatelessWidget {
  const _RankingRow({
    required this.rank,
    required this.player,
    required this.unit,
  });

  final int rank;
  final PlayerRank player;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$rank',
              style: AppTextStyles.label.copyWith(
                color:
                    rank <= 3 ? AppColors.primary : AppColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _playerAvatar(player.avatarPath, player.name, size: 36),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(player.name,
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textPrimary)),
          ),
          Text('${player.value}$unit',
              style: AppTextStyles.label
                  .copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 탭 3: 멤버
// ══════════════════════════════════════════════

class _MembersView extends ConsumerWidget {
  const _MembersView({required this.scrollPaddingTop});
  final double scrollPaddingTop;

  static const _positionOrder = ['GK', 'DF', 'MF', 'FW'];
  static const _positionLabels = {
    'GK': '골키퍼',
    'DF': '수비수',
    'MF': '미드필더',
    'FW': '공격수',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamAsync = ref.watch(currentTeamProvider);
    final team = teamAsync.maybeWhen(data: (t) => t, orElse: () => null);

    if (team == null) {
      return Padding(
        padding: EdgeInsets.only(top: scrollPaddingTop + 60),
        child: Center(
          child: Text('팀을 먼저 만들어주세요',
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textTertiary)),
        ),
      );
    }

    final membersAsync = ref.watch(teamMembersByTeamProvider(team.id));

    return membersAsync.when(
      loading: () => Padding(
        padding: EdgeInsets.only(top: scrollPaddingTop + 60),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: EdgeInsets.only(top: scrollPaddingTop + 60),
        child: Center(
          child: Text('멤버를 불러오지 못했습니다\n$e',
              textAlign: TextAlign.center,
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textTertiary)),
        ),
      ),
      data: (members) {
        // position 이 없거나 매핑 안 되는 멤버는 '기타'
        final byPos = <String, List<TeamMember>>{};
        for (final m in members) {
          final key = _positionLabels.containsKey(m.playerPosition)
              ? m.playerPosition!
              : '기타';
          byPos.putIfAbsent(key, () => []).add(m);
        }

        return SingleChildScrollView(
          padding: EdgeInsets.only(top: scrollPaddingTop),
          child: Padding(
            padding: AppSpacing.paddingPage,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 멤버 초대 버튼
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (_) => const _InviteBottomSheet(),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md),
                    decoration: ShapeDecoration(
                      color: AppColors.surface,
                      shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.smoothMd),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_add_alt_1_rounded,
                            size: 18, color: AppColors.textSecondary),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '팀원 초대',
                          style: AppTextStyles.labelMedium
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                if (members.isEmpty) ...[
                  const SizedBox(height: AppSpacing.xxl),
                  Center(
                    child: Text(
                      '아직 멤버가 없습니다',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textTertiary),
                    ),
                  ),
                ] else
                  ..._positionOrder
                      .followedBy(const ['기타'])
                      .map((pos) {
                    final list = byPos[pos];
                    if (list == null || list.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    final label = _positionLabels[pos] ?? pos;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          '$label (${list.length})',
                          style: AppTextStyles.captionMedium
                              .copyWith(color: AppColors.textTertiary),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ...list.map((m) => _MemberRow(member: m)),
                      ],
                    );
                  }),
                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.member});
  final TeamMember member;

  @override
  Widget build(BuildContext context) {
    final name = member.playerName ?? '이름 없음';
    final pos = member.playerPosition ?? '-';
    final num = member.playerNumber;
    final subtitle = num != null ? '$pos · #$num' : pos;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          _playerAvatar(member.playerAvatarUrl, name, size: 40),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: AppSpacing.xxs),
                Text(subtitle,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 선수 아바타. URL 있으면 네트워크, 없으면 이니셜 원.
/// 형태는 원형(ClipOval) — 다른 화면의 아바타와 일관.
Widget _playerAvatar(String? url, String name, {required double size}) {
  final initial = name.isNotEmpty ? name[0] : '?';
  final fallback = Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      color: AppColors.surface,
      shape: BoxShape.circle,
    ),
    child: Text(
      initial,
      style: TextStyle(
        fontFamily: 'Pretendard',
        fontSize: size * 0.4,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        height: 1.0,
      ),
    ),
  );
  if (url == null || url.isEmpty) return fallback;
  if (url.startsWith('http')) {
    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }
  return ClipOval(
    child: Image.asset(
      url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
    ),
  );
}
