import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class MatchTabBar extends StatelessWidget {
  const MatchTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      labelStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
      labelColor: AppColors.textPrimary,
      unselectedLabelStyle: AppTextStyles.body,
      unselectedLabelColor: AppColors.textTertiary,
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.textPrimary, width: 2),
        borderRadius: BorderRadius.zero,
      ),
      tabAlignment: TabAlignment.start,
      isScrollable: true,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 16),
      dividerHeight: 0,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      tabs: const [
        Tab(text: '경기정보'),
        Tab(text: '상대전적'),
        Tab(text: '스탯'),
      ],
    );
  }
}
