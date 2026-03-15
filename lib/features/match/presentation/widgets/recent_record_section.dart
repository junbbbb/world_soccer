import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/section_title.dart';

class RecentRecordSection extends StatelessWidget {
  const RecentRecordSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingSection,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('최근 전적'),
          Container(
            width: double.infinity,
            height: 120,
            decoration: ShapeDecoration(
              color: AppColors.surface,
              shape: SmoothRectangleBorder(
                borderRadius: AppRadius.smoothMd,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
