import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'logic/lineup_controller.dart';
import 'models/lineup_models.dart';
import 'widgets/add_mercenary_sheet.dart';
import 'widgets/bench_panel.dart';
import 'widgets/fairness_overlay.dart';
import 'widgets/formation_dropdown.dart';
import 'widgets/pitch_view.dart';
import 'widgets/quarter_selector.dart';
import 'widgets/slot_picker_sheet.dart';

/// 4쿼터 라인업 빌더 — "절제됨 속 여백" 디자인.
///
/// - 헤더: back · 가운데 제목 · ⚡ · ⋯
/// - 본문: 포메이션/쿼터 segmented (텍스트 + underline) → 피치 (Expanded) → 벤치
/// - 모든 변경은 keepAlive 상태에 즉시 반영. 저장 버튼 없음.
class LineupBuilderScreen extends ConsumerStatefulWidget {
  const LineupBuilderScreen({super.key});

  @override
  ConsumerState<LineupBuilderScreen> createState() =>
      _LineupBuilderScreenState();
}

class _LineupBuilderScreenState extends ConsumerState<LineupBuilderScreen> {
  void _showSnack(String msg) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smoothMd),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openAddMercenary() {
    showAddMercenarySheet(
      context,
      onAdd: (name, pos, auto) {
        ref.read(lineupControllerProvider.notifier).addMercenary(
              name: name,
              position: pos,
              autoAssignToCurrent: auto,
            );
        _showSnack('용병 추가됨');
      },
    );
  }

  void _openMoreMenu() {
    final state = ref.read(lineupControllerProvider);
    final controller = ref.read(lineupControllerProvider.notifier);
    final currentQuarter = state.currentQuarter;
    final totalQuarters = state.quarters.length;
    final hasNext = currentQuarter < totalQuarters - 1;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _MoreMenuSheet(
          currentQuarterIndex: currentQuarter,
          hasNext: hasNext,
          onAddMercenary: () {
            Navigator.of(sheetContext).pop();
            _openAddMercenary();
          },
          onCopyToNext: hasNext
              ? () {
                  Navigator.of(sheetContext).pop();
                  controller.copyQuarter(
                    from: currentQuarter,
                    to: currentQuarter + 1,
                  );
                  _showSnack('Q${currentQuarter + 1}을 다음 쿼터에 복사');
                }
              : null,
          onCopyToAll: () {
            Navigator.of(sheetContext).pop();
            for (var q = 0; q < totalQuarters; q++) {
              if (q == currentQuarter) continue;
              controller.copyQuarter(from: currentQuarter, to: q);
            }
            _showSnack('Q${currentQuarter + 1}을 모든 쿼터에 복사');
          },
          onApplyFormationToAll: () {
            Navigator.of(sheetContext).pop();
            controller.applyCurrentFormationToAllQuarters();
            final formationName = controller
                .formations[state.quarters[currentQuarter].formationIndex]
                .name;
            _showSnack('모든 쿼터에 $formationName 적용');
          },
          onClearCurrent: () {
            Navigator.of(sheetContext).pop();
            controller.clearQuarter(currentQuarter);
            _showSnack('Q${currentQuarter + 1} 비움');
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lineupControllerProvider);
    final controller = ref.read(lineupControllerProvider.notifier);
    final formations = controller.formations;

    final currentQuarter = state.quarters[state.currentQuarter];
    final currentFormation = formations[currentQuarter.formationIndex];

    final slotMembers = <int, LineupMember>{};
    currentQuarter.slotToMemberId.forEach((slotIdx, memberId) {
      final m = state.memberById(memberId);
      if (m != null) {
        slotMembers[slotIdx] = m;
      }
    });

    final playCount = state.playCountByMemberId;
    final currentQuarterMemberIds = currentQuarter.memberIds;

    final benchMembers = state.roster
        .where((m) => !currentQuarterMemberIds.contains(m.id))
        .toList()
      ..sort((a, b) {
        final cA = playCount[a.id] ?? 0;
        final cB = playCount[b.id] ?? 0;
        if (cA != cB) return cA.compareTo(cB);
        const posOrder = {'GK': 0, 'DF': 1, 'MF': 2, 'FW': 3};
        final pA = posOrder[a.preferredPosition] ?? 9;
        final pB = posOrder[b.preferredPosition] ?? 9;
        if (pA != pB) return pA.compareTo(pB);
        final na = a.number ?? 999;
        final nb = b.number ?? 999;
        return na.compareTo(nb);
      });

    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _Header(
              topPadding: topPadding,
              onBack: () => Navigator.of(context).pop(),
              onAutoFill: () {
                HapticFeedback.selectionClick();
                controller.autoFillEmpty();
                _showSnack('남은 자리를 채웠어요');
              },
              onMore: _openMoreMenu,
            ),
            QuarterSelector(
              quarters: state.quarters,
              currentQuarter: state.currentQuarter,
              formations: formations,
              onQuarterTap: (q) {
                HapticFeedback.selectionClick();
                controller.setCurrentQuarter(q);
              },
            ),
            const SizedBox(height: AppSpacing.base),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                child: PitchView(
                  formation: currentFormation,
                  slotMembers: slotMembers,
                  playCount: playCount,
                  onDropToSlot: (memberId, slotIdx) {
                    controller.placeAtSlot(memberId, slotIdx);
                  },
                  onEmptySlotTap: (slotIdx, slotPos) {
                    showSlotPickerSheet(
                      context,
                      slotIndex: slotIdx,
                      slotPosition: slotPos,
                    );
                  },
                  overlay: FairnessOverlay(state: state),
                  rightOverlay: FormationDropdown(
                    formations: formations,
                    selectedIndex: currentQuarter.formationIndex,
                    onChanged: (i) {
                      controller.setFormationForCurrentQuarter(i);
                    },
                  ),
                ),
              ),
            ),
            BenchPanel(
              benchMembers: benchMembers,
              playCount: playCount,
              currentQuarter: state.currentQuarter,
              currentQuarterMemberIds: currentQuarterMemberIds,
              onMemberDroppedOnBench: (memberId) {
                controller.removeMemberFromCurrentQuarter(memberId);
              },
            ),
            SizedBox(height: bottomPadding + AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// Header — back · 가운데 제목 · ⚡ · ⋯
// ══════════════════════════════════════════════

class _Header extends StatelessWidget {
  const _Header({
    required this.topPadding,
    required this.onBack,
    required this.onAutoFill,
    required this.onMore,
  });

  final double topPadding;
  final VoidCallback onBack;
  final VoidCallback onAutoFill;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: topPadding),
      color: Colors.white,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            _IconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              size: 20,
              onTap: onBack,
            ),
            Expanded(
              child: Center(
                child: Text(
                  '라인업 만들기',
                  style: AppTextStyles.heading.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            _IconButton(
              icon: Icons.auto_awesome_rounded,
              onTap: onAutoFill,
            ),
            _IconButton(
              icon: Icons.more_horiz_rounded,
              onTap: onMore,
            ),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.onTap,
    this.size = 22,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.sm,
        ),
        child: Icon(icon, size: size, color: AppColors.textPrimary),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// More menu sheet
// ══════════════════════════════════════════════

class _MoreMenuSheet extends StatelessWidget {
  const _MoreMenuSheet({
    required this.currentQuarterIndex,
    required this.hasNext,
    required this.onAddMercenary,
    required this.onCopyToNext,
    required this.onCopyToAll,
    required this.onApplyFormationToAll,
    required this.onClearCurrent,
  });

  final int currentQuarterIndex;
  final bool hasNext;
  final VoidCallback onAddMercenary;
  final VoidCallback? onCopyToNext;
  final VoidCallback onCopyToAll;
  final VoidCallback onApplyFormationToAll;
  final VoidCallback onClearCurrent;

  @override
  Widget build(BuildContext context) {
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
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.iconInactive,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            _MenuItem(
              icon: Icons.person_add_alt_1_rounded,
              label: '용병 추가',
              onTap: onAddMercenary,
            ),
            _MenuItem(
              icon: Icons.east_rounded,
              label: hasNext
                  ? 'Q${currentQuarterIndex + 1} → Q${currentQuarterIndex + 2} 복사'
                  : '다음 쿼터 없음',
              onTap: onCopyToNext,
            ),
            _MenuItem(
              icon: Icons.dynamic_feed_rounded,
              label: '모든 쿼터에 복사',
              onTap: onCopyToAll,
            ),
            _MenuItem(
              icon: Icons.cached_rounded,
              label: '모든 쿼터에 같은 포메이션 적용',
              onTap: onApplyFormationToAll,
            ),
            _MenuItem(
              icon: Icons.delete_outline_rounded,
              label: '이 쿼터 비우기',
              onTap: onClearCurrent,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    final fg = disabled ? AppColors.textTertiary : AppColors.textPrimary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: fg),
            const SizedBox(width: AppSpacing.base),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
