import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../models/lineup_models.dart';

/// 쿼터 선택기 — 슬라이딩 세그먼트 컨트롤.
///
/// surface 배경 컨테이너 안에 흰색 인디케이터가 슬라이드.
/// Q1~Q4 균등 분배, sublabel(인원수) 포함.
class QuarterSelector extends StatelessWidget {
  const QuarterSelector({
    required this.quarters,
    required this.currentQuarter,
    required this.formations,
    required this.onQuarterTap,
    super.key,
  });

  final List<QuarterLineup> quarters;
  final int currentQuarter;
  final List<Formation> formations;
  final ValueChanged<int> onQuarterTap;

  static const _containerPadding = 3.0;

  @override
  Widget build(BuildContext context) {
    final count = quarters.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth =
              (constraints.maxWidth - _containerPadding * 2) / count;

          return Container(
            height: 44,
            padding: const EdgeInsets.all(_containerPadding),
            decoration: ShapeDecoration(
              color: AppColors.surface,
              shape: SmoothRectangleBorder(
                borderRadius: AppRadius.smoothMd,
              ),
            ),
            child: Stack(
              children: [
                // ── 슬라이딩 인디케이터 ──
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  left: currentQuarter * segmentWidth,
                  top: 0,
                  bottom: 0,
                  width: segmentWidth,
                  child: Container(
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: SmoothRectangleBorder(
                        borderRadius: AppRadius.smooth(AppRadius.sm + 1),
                      ),
                      shadows: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                        BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
                // ── 탭 라벨들 ──
                Row(
                  children: [
                    for (int q = 0; q < count; q++)
                      Expanded(
                        child: GestureDetector(
                          onTap: () => onQuarterTap(q),
                          behavior: HitTestBehavior.opaque,
                          child: _SegmentLabel(
                            label: 'Q${q + 1}',
                            sublabel:
                                '${quarters[q].slotToMemberId.length}/${formations[quarters[q].formationIndex].slots.length}',
                            isSelected: q == currentQuarter,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════
// Segment label (텍스트 + sublabel)
// ══════════════════════════════════════════════

class _SegmentLabel extends StatelessWidget {
  const _SegmentLabel({
    required this.label,
    required this.isSelected,
    this.sublabel,
  });

  final String label;
  final String? sublabel;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            style: AppTextStyles.label.copyWith(
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textTertiary,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
            child: Text(label),
          ),
          if (sublabel != null)
            const SizedBox(width: 4),
          if (sublabel != null)
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: AppTextStyles.caption.copyWith(
                color: isSelected
                    ? AppColors.textTertiary
                    : AppColors.iconInactive,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
              child: Text(sublabel!),
            ),
        ],
      ),
    );
  }
}
