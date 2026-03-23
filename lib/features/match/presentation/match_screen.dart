import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/widgets/info_capsule.dart';
import '../../../../shared/widgets/match_time_info.dart';
import '../../../../shared/widgets/team_logo_badge.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'widgets/attendance_section.dart';
import 'widgets/lineup_section.dart';
import 'widgets/match_header.dart';
import 'widgets/participation_section.dart';
import 'widgets/match_tab_bar.dart';
import 'widgets/recent_record_section.dart';

class MatchDetailScreen extends StatefulWidget {
  const MatchDetailScreen({super.key});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen>
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: SafeArea(
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
                      ),
                    ),
                    // Hero VS 섹션 — 자연스럽게 스크롤
                    const SliverToBoxAdapter(
                      child: _HeroSection(),
                    ),
                    const SliverPersistentHeader(
                      pinned: true,
                      delegate: _TabBarDelegate(child: MatchTabBar()),
                    ),
                  ];
                },
                body: Container(
                  color: Colors.white,
                  child: const TabBarView(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            LineupSection(),
                            AttendanceSection(),
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

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
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
          const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Center(
                  child: TeamLogoBadge(
                    teamName: 'FC칼로',
                    logoPath: 'assets/images/logo_calo.png',
                    size: 64,
                  ),
                ),
              ),
              MatchTimeInfo(
                time: '20:00',
                datePlace: '2/7(토) 성내유수지',
              ),
              Expanded(
                child: Center(
                  child: TeamLogoBadge(
                    teamName: 'FC쏘아',
                    logoPath: 'assets/images/logo_ssoa.png',
                    size: 64,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const Row(
            children: [
              InfoCapsule(text: '13/16명'),
              SizedBox(width: AppSpacing.sm),
              InfoCapsule(text: '참가완료'),
              SizedBox(width: AppSpacing.sm),
              InfoCapsule(text: '리벤지 매치'),
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
