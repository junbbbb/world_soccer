import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../models/lineup_models.dart';

/// 쿼터 선택기 — 텍스트 + underline segmented.
///
/// 절제된 스타일: 라벨 없음, 카드/배경 없음. Q1~Q4 균등 분배.
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.base,
        AppSpacing.lg,
        0,
      ),
      child: Row(
        children: [
          for (int q = 0; q < quarters.length; q++)
            Expanded(
              child: _SegmentedTextButton(
                label: 'Q${q + 1}',
                sublabel:
                    '${quarters[q].slotToMemberId.length}/${formations[quarters[q].formationIndex].slots.length}',
                isSelected: q == currentQuarter,
                onTap: () => onQuarterTap(q),
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// Segmented text button (텍스트 + underline)
// ══════════════════════════════════════════════

class _SegmentedTextButton extends StatelessWidget {
  const _SegmentedTextButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.sublabel,
  });

  final String label;
  final String? sublabel;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 44,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  label,
                  style: AppTextStyles.label.copyWith(
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                    fontWeight:
                        isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                if (sublabel != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    sublabel!,
                    style: AppTextStyles.caption.copyWith(
                      color: isSelected
                          ? AppColors.textTertiary
                          : AppColors.iconInactive,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: isSelected ? 22 : 0,
              height: 2,
              decoration: const BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.all(Radius.circular(1)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
