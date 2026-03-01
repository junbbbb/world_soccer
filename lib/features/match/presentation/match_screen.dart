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
  bool _showJoinAnimation = false;
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
      _isJoinComplete = true; // 트리에 위젯 추가
    });

    // 프레임 반영 후 투명도 애니메이션 시작
    await Future.delayed(const Duration(milliseconds: 50));
    if (mounted) {
      setState(() {
        _showJoinAnimation = true;
      });
    }

    // 2초 정도 성공 화면 보여줌 (스케일 애니메이션 및 체크 애니메이션 진행)
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      setState(() {
        _showJoinAnimation = false; // 투명하게 페이드아웃 시작
      });
    }

    // 페이드 아웃 될 동안 대기 (400ms)
    await Future.delayed(const Duration(milliseconds: 400));

    if (mounted) {
      setState(() {
        _isJoinComplete = false; // 트리에서 아예 제거
        _hasJoined = true; // 완료 상태 업데이트
      });
    }
  }

  void _handleCancelJoin() {
    _collapseBar();

    setState(() {
      _hasJoined = false;
      _isJoinComplete = false;
      _showJoinAnimation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Background and Content bounded by SafeArea
            Positioned.fill(
              child: Container(
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
                    ),
                  ),
                ),
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
            // 참가 완료 애니메이션 (프리미엄 스타일)
            if (_isJoinComplete)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: _showJoinAnimation ? 1.0 : 0.0,
                    curve: Curves.easeInOut,
                    child: Container(
                      color: Colors.white.withValues(
                        alpha: 0.2,
                      ), // 전체 화면은 매우 옅은 흰색
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // V 표시와 텍스트 주변만 하얗게 잡아주는 부드러운 글로우(빛 번짐) 효과
                          Container(
                            width: 400,
                            height: 400,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withValues(
                                    alpha: 1.0,
                                  ), // 중앙은 완전 하얗게
                                  Colors.white.withValues(alpha: 0.8),
                                  Colors.white.withValues(
                                    alpha: 0.0,
                                  ), // 바깥으로 갈수록 투명하게 풀림
                                ],
                                stops: const [0.25, 0.55, 1.0],
                              ),
                            ),
                          ),
                          Center(
                            child: TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 700),
                              curve: Curves.elasticOut,
                              tween: Tween<double>(
                                begin: 0.5,
                                end: _showJoinAnimation ? 1.0 : 0.8,
                              ),
                              builder: (context, scale, child) {
                                return Transform.scale(
                                  scale: scale,
                                  child: child,
                                );
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 96,
                                    height: 96,
                                    decoration: BoxDecoration(
                                      color: AppColors.accentBlue,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.accentBlue
                                              .withValues(alpha: 0.4),
                                          blurRadius: 32,
                                          spreadRadius: 8,
                                          offset: const Offset(0, 12),
                                        ),
                                        BoxShadow(
                                          color: Colors.white.withValues(
                                            alpha: 0.2,
                                          ),
                                          blurRadius: 0,
                                          spreadRadius: 2,
                                          offset: const Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: SizedBox(
                                        width: 44,
                                        height: 44,
                                        child: CheckMark(
                                          active: _showJoinAnimation,
                                          curve: Curves.easeOutQuart,
                                          duration: const Duration(
                                            milliseconds: 600,
                                          ),
                                          strokeWidth: 4.5,
                                          activeColor: Colors.white,
                                          inactiveColor: Colors.transparent,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  Text(
                                    '참가 확정 완료!',
                                    style: AppTextStyles.title.copyWith(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '경기 일정을 놓치지 마세요',
                                    style: AppTextStyles.body.copyWith(
                                      fontSize: 16,
                                      color: AppColors.textSecondary,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ],
                              ),
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
