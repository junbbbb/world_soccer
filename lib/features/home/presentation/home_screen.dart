import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../chat/presentation/chat_tab.dart';
import '../../match/presentation/match_tab.dart';
import '../../stats/presentation/stats_tab.dart';
import '../../team/presentation/team_tab.dart';
import 'home_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            HomeTab(),
            MatchTab(),
            StatsTab(),
            ChatTab(),
            TeamTab(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: AppShadows.bottomBar,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: AppColors.textPrimary,
            unselectedItemColor: AppColors.iconInactive,
            selectedLabelStyle: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: AppTextStyles.caption,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: [
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/icons/mingcute_home-1-fill.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    _currentIndex == 0
                        ? AppColors.textPrimary
                        : AppColors.iconInactive,
                    BlendMode.srcIn,
                  ),
                ),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.calendar_month_rounded,
                  size: 24,
                  color: _currentIndex == 1
                      ? AppColors.textPrimary
                      : AppColors.iconInactive,
                ),
                label: '경기',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/icons/ic_round-bar-chart.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    _currentIndex == 2
                        ? AppColors.textPrimary
                        : AppColors.iconInactive,
                    BlendMode.srcIn,
                  ),
                ),
                label: '스탯',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  label: const Text(
                    '9',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: const Color(0xFFE5484D),
                  child: SvgPicture.asset(
                    'assets/icons/ri_chat-1-fill.svg',
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      _currentIndex == 3
                          ? AppColors.textPrimary
                          : AppColors.iconInactive,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                label: '채팅',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.shield,
                  size: 24,
                  color: _currentIndex == 4
                      ? AppColors.textPrimary
                      : AppColors.iconInactive,
                ),
                label: '팀',
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
