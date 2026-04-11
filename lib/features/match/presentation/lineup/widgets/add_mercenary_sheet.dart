import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../lineup_design.dart';

/// 용병 추가 바텀시트.
///
/// 최소 입력으로 2초 이내 추가 완료가 목표:
/// - 이름 (비어도 됨 — "용병 N" 자동 부여)
/// - 포지션 (4버튼)
/// - 즉시 현재 쿼터 투입 (기본 ON)
Future<void> showAddMercenarySheet(
  BuildContext context, {
  required void Function(String name, String position, bool autoAssign) onAdd,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: _AddMercenarySheetBody(
          onSubmit: (name, pos, auto) {
            Navigator.of(sheetContext).pop();
            onAdd(name, pos, auto);
          },
        ),
      );
    },
  );
}

class _AddMercenarySheetBody extends StatefulWidget {
  const _AddMercenarySheetBody({required this.onSubmit});

  final void Function(String name, String position, bool autoAssign) onSubmit;

  @override
  State<_AddMercenarySheetBody> createState() => _AddMercenarySheetBodyState();
}

class _AddMercenarySheetBodyState extends State<_AddMercenarySheetBody> {
  final _nameCtrl = TextEditingController();
  String _position = 'FW';
  bool _autoAssign = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    widget.onSubmit(_nameCtrl.text, _position, _autoAssign);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.only(
            topLeft: SmoothRadius(
              cornerRadius: AppRadius.xl,
              cornerSmoothing: 1.0,
            ),
            topRight: SmoothRadius(
              cornerRadius: AppRadius.xl,
              cornerSmoothing: 1.0,
            ),
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xl,
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
            const SizedBox(height: AppSpacing.base),
            Text(
              '용병 추가',
              style: AppTextStyles.heading.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '이름은 비워도 됩니다 (자동 부여)',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.base),

            // 이름 입력
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: 4,
              ),
              decoration: ShapeDecoration(
                color: AppColors.surfaceLight,
                shape: SmoothRectangleBorder(
                  borderRadius: AppRadius.smoothSm,
                ),
              ),
              child: TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '이름 (예: 김용병)',
                  hintStyle: AppTextStyles.body.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
            ),

            const SizedBox(height: AppSpacing.base),
            Text(
              '포지션',
              style: AppTextStyles.captionMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                for (var i = 0; i < lineupPositions.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _PositionButton(
                      label: lineupPositions[i],
                      isSelected: _position == lineupPositions[i],
                      onTap: () => setState(() => _position = lineupPositions[i]),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: AppSpacing.base),
            // 자동 투입 토글
            GestureDetector(
              onTap: () => setState(() => _autoAssign = !_autoAssign),
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Icon(
                    _autoAssign
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                    size: 20,
                    color: _autoAssign
                        ? AppColors.primary
                        : AppColors.textTertiary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '추가하고 현재 쿼터에 즉시 투입',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: SmoothRectangleBorder(
                    borderRadius: AppRadius.smoothButton,
                  ),
                ),
                child: const Text('추가', style: AppTextStyles.buttonPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PositionButton extends StatelessWidget {
  const _PositionButton({
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
        height: 44,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.10)
              : AppColors.surfaceLight,
          shape: SmoothRectangleBorder(
            borderRadius: AppRadius.smoothSm,
            side: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
