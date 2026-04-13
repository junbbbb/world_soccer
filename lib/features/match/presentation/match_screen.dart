import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/info_capsule.dart';
import '../../../../shared/widgets/match_badges.dart';
import '../../../../shared/widgets/match_time_info.dart';
import '../../../../shared/widgets/team_logo_badge.dart';
import '../../../config/dev_settings.dart';
import '../../../runtime/providers.dart';
import '../../../types/match.dart' show Match;
import '../../../types/team.dart' show Team;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'match_create_screen.dart';
import 'widgets/attendance_section.dart';
import 'widgets/lineup_section.dart';
import 'widgets/match_header.dart';
import 'widgets/participation_section.dart';
import 'widgets/match_tab_bar.dart';
import 'widgets/recent_record_section.dart';

class MatchDetailScreen extends ConsumerStatefulWidget {
  const MatchDetailScreen({super.key, this.matchId});
  final String? matchId;

  @override
  ConsumerState<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends ConsumerState<MatchDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _isJoined = false;
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.92), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.05), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggleJoin() {
    setState(() => _isJoined = !_isJoined);
    _animController.forward(from: 0);
    if (_isJoined) {
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final showDummy = ref.watch(showDummyDataProvider);
    final matchList = ref.watch(teamMatchesProvider).when<List<Match>>(
          data: (list) => list, loading: () => [], error: (_, __) => []);
    final match = widget.matchId != null
        ? matchList.where((m) => m.id == widget.matchId).firstOrNull
        : null;
    final isFinished = !showDummy && match != null && match.isFinished;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: isFinished ? null : SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.base,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: ScaleTransition(
              scale: _scaleAnim,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _toggleJoin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isJoined ? AppColors.surface : AppColors.primary,
                    foregroundColor:
                        _isJoined ? AppColors.textSecondary : Colors.white,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: SmoothRectangleBorder(
                      borderRadius: AppRadius.smoothButton,
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _isJoined
                        ? Row(
                            key: const ValueKey('joined'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_rounded, size: 20),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                '참가완료',
                                style: AppTextStyles.buttonPrimary.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            '참가하기',
                            key: const ValueKey('join'),
                            style: AppTextStyles.buttonPrimary,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: AppColors.matchHeroGradient,
          ),
          child: SafeArea(
            bottom: false,
            child: DefaultTabController(
              length: 3,
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: MatchTopBarDelegate(
                        onBack: () => Navigator.of(context).pop(),
                        onEdit: widget.matchId != null
                            ? () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => MatchCreateScreen(
                                      matchId: widget.matchId,
                                    ),
                                  ),
                                )
                            : null,
                        onStatusChange: (status) async {
                          HapticFeedback.mediumImpact();
                          if (widget.matchId != null) {
                            try {
                              final matchRepo = ref.read(matchRepoProvider);
                              await matchRepo.updateStatus(
                                matchId: widget.matchId!,
                                status: status,
                              );
                              ref.invalidate(teamMatchesProvider);
                            } catch (_) {}
                          }
                          if (!context.mounted) return;
                          final label = status == 'cancelled' ? '취소' : '조기 종료';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('경기가 $label 처리되었습니다'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ),
                    // Hero VS 섹션 — 자연스럽게 스크롤
                    SliverToBoxAdapter(
                      child: _HeroSection(matchId: widget.matchId),
                    ),
                    const SliverPersistentHeader(
                      pinned: true,
                      delegate: _TabBarDelegate(child: MatchTabBar()),
                    ),
                  ];
                },
                body: Container(
                  color: Colors.white,
                  child: TabBarView(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            const LineupSection(),
                            AttendanceSection(matchId: widget.matchId),
                            ParticipationSection(),
                            SizedBox(height: AppSpacing.xxxxl),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            RecentRecordSection(),
                            SizedBox(height: AppSpacing.xxxxl),
                          ],
                        ),
                      ),
                      Center(child: Text('스탯')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends ConsumerWidget {
  const _HeroSection({this.matchId});
  final String? matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showDummy = ref.watch(showDummyDataProvider);

    // 실제 데이터
    final team = showDummy
        ? null
        : ref.watch(currentTeamProvider).when<Team?>(
              data: (t) => t, loading: () => null, error: (_, __) => null);
    final matchList = ref.watch(teamMatchesProvider).when<List<Match>>(
          data: (list) => list, loading: () => [], error: (_, __) => []);
    final match = matchId != null
        ? matchList.where((m) => m.id == matchId).firstOrNull
        : null;

    final ourName = showDummy ? 'FC칼로' : (team?.name ?? '...');
    final opponentName = showDummy ? 'FC쏘아' : (match?.opponentName ?? '상대팀');
    final timeStr = showDummy ? '20:00' : (match?.timeString ?? '--:--');
    final datePlaceStr = showDummy
        ? '2/7(토) 성내유수지'
        : match != null
            ? '${match.date.month}/${match.date.day}(${match.dayOfWeek}) ${match.location}'
            : '';

    // 스코어 표시
    final hasScore = match?.hasResult ?? false;
    final scoreStr = hasScore ? '${match!.ourScore} : ${match.opponentScore}' : null;

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.matchHeroGradient,
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.base,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Center(
                  child: TeamLogoBadge(
                    teamName: ourName,
                    logoPath: showDummy ? 'assets/images/logo_calo.png' : null,
                    logoUrl: showDummy ? null : team?.logoUrl,
                    size: 64,
                  ),
                ),
              ),
              if (scoreStr != null)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      scoreStr,
                      style: AppTextStyles.timeDisplay.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      datePlaceStr,
                      style: AppTextStyles.matchInfo,
                    ),
                  ],
                )
              else
                MatchTimeInfo(
                  time: timeStr,
                  datePlace: datePlaceStr,
                ),
              Expanded(
                child: Center(
                  child: TeamLogoBadge(
                    teamName: opponentName,
                    logoPath: showDummy ? 'assets/images/logo_ssoa.png' : null,
                    size: 64,
                    isOpponent: !showDummy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              if (showDummy) ...[
                const InfoCapsule(text: '13/16명'),
                const SizedBox(width: AppSpacing.sm),
                const InfoCapsule(text: '참가완료'),
                const SizedBox(width: AppSpacing.sm),
                const InfoCapsule(text: '리벤지 매치'),
              ] else ...[
                ...buildMatchBadges(matchList, match),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 58;

  @override
  double get maxExtent => 58;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 그라데이션 구분선 (hero ↔ 탭바 경계)
          const SizedBox(
            height: 2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                  colors: AppColors.headerDividerColors,
                ),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}

