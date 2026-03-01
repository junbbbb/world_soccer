import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class MatchTabBar extends StatelessWidget {
  const MatchTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.only(
            topLeft: SmoothRadius(cornerRadius: 16, cornerSmoothing: 1.0),
            topRight: SmoothRadius(cornerRadius: 16, cornerSmoothing: 1.0),
          ),
        ),
      ),
      child: TabBar(
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.body.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: AppTextStyles.body.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        indicatorColor: AppColors.textPrimary,
        indicatorWeight: 2,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 30),
        dividerHeight: 0,
        tabs: const [
          Tab(height: 60, text: '경기정보'),
          Tab(height: 60, text: '상대전적'),
          Tab(height: 60, text: '채팅'),
        ],
      ),
    );
  }
}
