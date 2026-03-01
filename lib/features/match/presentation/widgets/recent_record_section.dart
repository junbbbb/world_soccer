import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/section_title.dart';

class RecentRecordSection extends StatelessWidget {
  const RecentRecordSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 12,
                  cornerSmoothing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
