import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../types/enums.dart';
import '../../../../types/match.dart';

/// 참가하기 바텀시트.
Future<JoinMatchResult?> showJoinMatchSheet(BuildContext context) {
  return showModalBottomSheet<JoinMatchResult>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _JoinMatchSheet(),
  );
}

// allPositionLabels, Position → config/types 에서 import

class _JoinMatchSheet extends StatefulWidget {
  const _JoinMatchSheet();

  @override
  State<_JoinMatchSheet> createState() => _JoinMatchSheetState();
}

class _JoinMatchSheetState extends State<_JoinMatchSheet> {
  final Set<Position> _positions = {Position.cm};
  final Set<int> _quarters = {0, 1, 2, 3};

  void _togglePosition(Position p) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_positions.contains(p)) {
        _positions.remove(p);
      } else {
        _positions.add(p);
      }
    });
  }

  void _toggleQuarter(int q) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_quarters.contains(q)) {
        _quarters.remove(q);
      } else {
        _quarters.add(q);
      }
    });
  }

  void _submit() {
    if (_positions.isEmpty || _quarters.isEmpty) return;
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop(
      JoinMatchResult(
        preferredPositions: Set<Position>.from(_positions),
        availableQuarters: Set<int>.from(_quarters),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _positions.isNotEmpty && _quarters.isNotEmpty;

    return Container(
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xl),
            topRight: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 핸들
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.iconInactive,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '참가하기',
              style: AppTextStyles.heading.copyWith(
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── 선호 포지션 ──
            const _SectionLabel('선호 포지션'),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final p in Position.values)
                  _OutlinePill(
                    label: p.label,
                    isSelected: _positions.contains(p),
                    onTap: () => _togglePosition(p),
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── 참가 가능 쿼터 ──
            const _SectionLabel('참가 가능 쿼터'),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (var q = 0; q < 4; q++)
                  _OutlinePill(
                    label: 'Q${q + 1}',
                    isSelected: _quarters.contains(q),
                    onTap: () => _toggleQuarter(q),
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.xxl),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canSubmit ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.surface,
                  disabledForegroundColor: AppColors.textTertiary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.smoothButton,
                  ),
                ),
                child: const Text('참가 완료', style: AppTextStyles.buttonPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// Section label
// ══════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.caption.copyWith(
        color: AppColors.textTertiary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

// ══════════════════════════════════════════════
// Outline pill — 포지션/쿼터 공용
// ══════════════════════════════════════════════

class _OutlinePill extends StatelessWidget {
  const _OutlinePill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: ShapeDecoration(
          color: AppColors.surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.smoothFull,
            side: BorderSide(
              color: isSelected ? AppColors.textPrimary : Colors.transparent,
              width: 1.5,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.captionBold.copyWith(
            color: isSelected ? AppColors.textPrimary : AppColors.textTertiary,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
