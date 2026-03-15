import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'widgets/attendance_section.dart';
import 'widgets/lineup_section.dart';
import 'widgets/match_header.dart';
import 'widgets/match_tab_bar.dart';
import 'widgets/recent_record_section.dart';

class MatchDetailScreen extends StatelessWidget {
  const MatchDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.base,
              AppSpacing.xl,
              AppSpacing.sm,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: SmoothRectangleBorder(
                    borderRadius: AppRadius.smoothButton,
                  ),
                ),
                child: Text('참가하기', style: AppTextStyles.buttonPrimary),
              ),
            ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.headerGradient,
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
                      delegate: MatchHeaderDelegate(
                        onBack: () => Navigator.of(context).pop(),
                      ),
                    ),
                    // 그라데이션 구분선 (hero <-> 탭바 경계)
                    const SliverToBoxAdapter(
                      child: ColoredBox(
                        color: Colors.white,
                        child: SizedBox(
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
                      ),
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

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 80;

  @override
  double get maxExtent => 80;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
