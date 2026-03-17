import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// 경기 시간 정보 블록 (오후 뱃지 + 시간 + 날짜/장소)
/// NextMatchCard, MatchHeader에서 공용 사용
class MatchTimeInfo extends StatelessWidget {
  const MatchTimeInfo({
    super.key,
    this.period,
    required this.time,
    required this.datePlace,
  });

  final String? period;
  final String time;
  final String datePlace;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (period != null)
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.overlayDark,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(period!, style: AppTextStyles.timeBadge),
          ),
        Text(time, style: AppTextStyles.timeDisplay),
        Text(datePlace, style: AppTextStyles.matchInfo),
      ],
    );
  }
}
