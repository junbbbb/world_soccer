import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
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
                      // 경기정보 탭
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            LineupSection(),
                            AttendanceSection(),
                            SizedBox(height: 40),
                          ],
                        ),
                      ),
                      // 상대전적 탭
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            RecentRecordSection(),
                            SizedBox(height: 40),
                          ],
                        ),
                      ),
                      // 스탯 탭 (placeholder)
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
  double get minExtent => 72;

  @override
  double get maxExtent => 72;

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
