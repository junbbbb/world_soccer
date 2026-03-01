import 'package:checkmark/checkmark.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'widgets/attendance_section.dart';
import 'widgets/bottom_action_bar.dart';
import 'widgets/lineup_section.dart';
import 'widgets/match_header.dart';
import 'widgets/match_tab_bar.dart';
import 'widgets/recent_record_section.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  final _barKey = GlobalKey<BottomActionBarState>();
  bool _isBarExpanded = false;
  bool _isJoinComplete = false;
  bool _hasJoined = false; // Add variable to track successfully joined status

  void _onExpandChanged(bool expanded) {
    setState(() {
      _isBarExpanded = expanded;
    });
  }

  void _collapseBar() {
    _barKey.currentState?.collapse();
  }

  void _handleJoinRequest() async {
    // 하단 바를 먼저 닫고 애니메이션을 시작합니다.
    _collapseBar();

    // 약간의 딜레이 후 참가 완료 애니메이션 표시
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _isJoinComplete = true;
    });

    // 애니메이션이 끝나면 자동으로 상태를 원래대로 돌려놓고, 버튼 상태를 업데이트합니다. (약 1.5초 후)
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() {
        _isJoinComplete = false;
        _hasJoined = true;
      });
    }
  }

  void _handleCancelJoin() {
    _collapseBar();
    setState(() {
      _hasJoined = false;
      _isJoinComplete = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        child: SafeArea(
          bottom: false,
          child: DefaultTabController(
            length: 3,
            child: Scaffold(
              backgroundColor: Colors.white,
              body: Stack(
                children: [
                  NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        const SliverPersistentHeader(
                          pinned: true,
                          delegate: MatchHeaderDelegate(),
                        ),
                        const SliverPersistentHeader(
                          pinned: true,
                          delegate: _TabBarDelegate(child: MatchTabBar()),
                        ),
                      ];
                    },
                    body: const TabBarView(
                      children: [
                        // 경기정보 탭
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              LineupSection(),
                              AttendanceSection(),
                              RecentRecordSection(),
                              SizedBox(
                                height: 120,
                              ), // Bottom padding to scroll past the fixed action bar
                            ],
                          ),
                        ),
                        // 상대전적 탭 (placeholder)
                        Center(child: Text('상대전적')),
                        // 채팅 탭 (placeholder)
                        Center(child: Text('채팅')),
                      ],
                    ),
                  ),
                  // Dark scrim overlay (covers full screen including behind bottom bar corners)
                  if (_isBarExpanded)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: _collapseBar,
                        child: AnimatedOpacity(
                          opacity: _isBarExpanded ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 250),
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ),
                  // Bottom action bar inside Stack so scrim covers behind rounded corners
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: BottomActionBar(
                      key: _barKey,
                      isJoined: _hasJoined,
                      onExpandChanged: _onExpandChanged,
                      onJoinRequested: _handleJoinRequest,
                      onCancelJoined: _handleCancelJoin,
                    ),
                  ),
                  // 참가 완료 애니메이션 (토스 스타일)
                  if (_isJoinComplete)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.3), // 배경 살짝 딤처리
                        child: Center(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: CheckMark(
                                    active: true,
                                    curve: Curves.easeOutCubic,
                                    duration: Duration(milliseconds: 500),
                                    strokeWidth: 4,
                                    activeColor: AppColors.accentBlue,
                                    inactiveColor: Colors.transparent,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '참가 완료',
                                  style: AppTextStyles.title.copyWith(
                                    fontSize: 15,
                                    color: AppColors.textPrimary,
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
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      child: ClipSmoothRect(
        radius: const SmoothBorderRadius.only(
          topLeft: SmoothRadius(cornerRadius: 16, cornerSmoothing: 1.0),
          topRight: SmoothRadius(cornerRadius: 16, cornerSmoothing: 1.0),
        ),
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
