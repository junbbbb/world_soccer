import 'dart:ui';

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/section_title.dart';

// ── 더미 데이터 ──

const _teamInfo = _TeamInfo(
  name: 'FC칼로',
  foundedYear: 2020,
  region: '서울 강동구',
  memberCount: 24,
  activityDay: '매주 토요일',
  totalRecord: '48승 12무 8패',
  seasonBest: '5연승',
);

const _teamStats = _TeamStatsData(
  totalMatches: 12,
  wins: 7,
  draws: 2,
  losses: 3,
  goalsFor: 28,
  goalsAgainst: 14,
  cleanSheets: 4,
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

const _dummyMembers = [
  _Member(name: '박서준', position: 'GK', number: 1, avatarPath: 'assets/images/avatars/RAYA_Headshot_web_njztl3wr.avif'),
  _Member(name: '한준혁', position: 'GK', number: 21, avatarPath: 'assets/images/avatars/RAYA_Headshot_web_njztl3wr.avif'),
  _Member(name: '윤태경', position: 'DF', number: 2, avatarPath: 'assets/images/avatars/SALIBA_Headshot_web_khl9z1vw.avif'),
  _Member(name: '정도현', position: 'DF', number: 4, avatarPath: 'assets/images/avatars/SALIBA_Headshot_web_khl9z1vw.avif'),
  _Member(name: '김재윤', position: 'DF', number: 5, avatarPath: 'assets/images/avatars/SALIBA_Headshot_web_khl9z1vw.avif'),
  _Member(name: '이현우', position: 'DF', number: 15, avatarPath: 'assets/images/avatars/SALIBA_Headshot_web_khl9z1vw.avif'),
  _Member(name: '송민호', position: 'DF', number: 23, avatarPath: 'assets/images/avatars/SALIBA_Headshot_web_khl9z1vw.avif'),
  _Member(name: '이병준', position: 'MF', number: 7, avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif'),
  _Member(name: '최민수', position: 'MF', number: 8, avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif'),
  _Member(name: '윤서준', position: 'MF', number: 10, avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif'),
  _Member(name: '강지훈', position: 'MF', number: 14, avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif'),
  _Member(name: '조원빈', position: 'MF', number: 16, avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif'),
  _Member(name: '배준서', position: 'MF', number: 18, avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif'),
  _Member(name: '임시우', position: 'MF', number: 22, avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif'),
  _Member(name: '김태호', position: 'FW', number: 9, avatarPath: 'assets/images/avatars/MOSQUERA_Headshot_web_b3sucu1j.avif'),
  _Member(name: '박정우', position: 'FW', number: 11, avatarPath: 'assets/images/avatars/MOSQUERA_Headshot_web_b3sucu1j.avif'),
  _Member(name: '신유찬', position: 'FW', number: 17, avatarPath: 'assets/images/avatars/MOSQUERA_Headshot_web_b3sucu1j.avif'),
  _Member(name: '오준영', position: 'FW', number: 19, avatarPath: 'assets/images/avatars/MOSQUERA_Headshot_web_b3sucu1j.avif'),
];

// ── 모델 ──

class _TeamInfo {
  final String name;
  final int foundedYear;
  final String region;
  final int memberCount;
  final String activityDay;
  final String totalRecord;
  final String seasonBest;

  const _TeamInfo({
    required this.name,
    required this.foundedYear,
    required this.region,
    required this.memberCount,
    required this.activityDay,
    required this.totalRecord,
    required this.seasonBest,
  });
}

class _TeamStatsData {
  final int totalMatches;
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;
  final int cleanSheets;

  const _TeamStatsData({
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

class _Member {
  final String name;
  final String position;
  final int number;
  final String avatarPath;

  const _Member({
    required this.name,
    required this.position,
    required this.number,
    required this.avatarPath,
  });
}

// ── TeamTab ──

class TeamTab extends StatefulWidget {
  const TeamTab({super.key});

  @override
  State<TeamTab> createState() => _TeamTabState();
}

class _TeamTabState extends State<TeamTab> with SingleTickerProviderStateMixin {
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

    return ColoredBox(
      color: Colors.white,
      child: Stack(
        children: [
          // ── 탭 본문 ──
          TabBarView(
            controller: _tabController,
            children: [
              _OverviewView(
                  scrollPaddingTop: topPadding + _headerHeight + AppSpacing.sm),
              _TeamStatsView(
                  scrollPaddingTop: topPadding + _headerHeight + AppSpacing.sm),
              _MembersView(
                  scrollPaddingTop: topPadding + _headerHeight + AppSpacing.sm),
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
                            const Icon(
                              Icons.settings_outlined,
                              color: AppColors.textTertiary,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TabBar(
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

class _OverviewView extends StatelessWidget {
  const _OverviewView({required this.scrollPaddingTop});
  final double scrollPaddingTop;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: scrollPaddingTop),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TeamInfoSection(),
          SizedBox(height: AppSpacing.xxl),
          _InviteLinkCard(),
          SizedBox(height: AppSpacing.xxl),
          _TeamSummarySection(),
          SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}

// ── 팀 정보 섹션 ──

class _TeamInfoSection extends StatelessWidget {
  const _TeamInfoSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingPage,
      child: Column(
        children: [
          ClipSmoothRect(
            radius: AppRadius.smoothLg,
            child: Image.asset(
              'assets/images/logo_calo.png',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _teamInfo.name,
            style: AppTextStyles.sectionTitle.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${_teamInfo.foundedYear}년 창단 · ${_teamInfo.region}',
            style: AppTextStyles.bodyRegular.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _InfoBadge(label: '${_teamInfo.memberCount}명'),
              const SizedBox(width: AppSpacing.sm),
              _InfoBadge(label: _teamInfo.activityDay),
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
        shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothFull),
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
            shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothMd),
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
                  shape: SmoothRectangleBorder(
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
                          shape: SmoothRectangleBorder(
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
          shape: SmoothRectangleBorder(
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

class _TeamSummarySection extends StatelessWidget {
  const _TeamSummarySection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingPage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('팀 기록'),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                    label: '통산 전적', value: _teamInfo.totalRecord),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child:
                    _SummaryCard(label: '시즌 최고', value: _teamInfo.seasonBest),
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
        shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothMd),
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

class _TeamStatsView extends StatelessWidget {
  const _TeamStatsView({required this.scrollPaddingTop});
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
                    borderRadius: AppRadius.smoothMd),
              ),
              child: Column(
                children: [
                  _statRow('총 득점', '${_teamStats.goalsFor}'),
                  _statDivider(),
                  _statRow('총 실점', '${_teamStats.goalsAgainst}'),
                  _statDivider(),
                  _statRow('평균 득점',
                      _teamStats.avgGoalsFor.toStringAsFixed(1)),
                  _statDivider(),
                  _statRow('평균 실점',
                      _teamStats.avgGoalsAgainst.toStringAsFixed(1)),
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
            return _RankingRow(
                rank: i + 1, player: _topScorers[i], unit: '골');
          }),
          const SizedBox(height: AppSpacing.xxl),

          // 어시스트 랭킹
          Padding(
            padding: AppSpacing.paddingPage,
            child: const SectionTitle('어시스트 랭킹'),
          ),
          ...List.generate(_topAssisters.length, (i) {
            return _RankingRow(
                rank: i + 1, player: _topAssisters[i], unit: '도움');
          }),
          const SizedBox(height: AppSpacing.xxxl),
        ],
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
  final _TeamStatsData stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: ShapeDecoration(
        color: AppColors.surfaceLight,
        shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothMd),
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
          ClipSmoothRect(
            radius: AppRadius.smoothFull,
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
  final _PlayerRank player;
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
          ClipSmoothRect(
            radius: AppRadius.smoothSm,
            child: Image.asset(player.avatarPath,
                width: 36, height: 36, fit: BoxFit.cover),
          ),
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

class _MembersView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: scrollPaddingTop),
      child: Padding(
        padding: AppSpacing.paddingPage,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 멤버 추가 버튼
            GestureDetector(
              onTap: () {
                // TODO: 멤버 추가
              },
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: ShapeDecoration(
                  color: AppColors.surface,
                  shape: SmoothRectangleBorder(
                      borderRadius: AppRadius.smoothMd),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add,
                        size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '멤버 추가',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            ..._positionOrder.map((pos) {
              final members =
                  _dummyMembers.where((m) => m.position == pos).toList();
              if (members.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${_positionLabels[pos]} (${members.length})',
                    style: AppTextStyles.captionMedium
                        .copyWith(color: AppColors.textTertiary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...members.map((m) => _MemberRow(member: m)),
                ],
              );
            }),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.member});
  final _Member member;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          ClipSmoothRect(
            radius: AppRadius.smoothSm,
            child: Image.asset(member.avatarPath,
                width: 40, height: 40, fit: BoxFit.cover),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name,
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: AppSpacing.xxs),
                Text('${member.position} · #${member.number}',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.phone_outlined,
              size: 20, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}
