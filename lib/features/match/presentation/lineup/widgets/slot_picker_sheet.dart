import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../lineup_design.dart';
import '../logic/lineup_controller.dart';
import '../models/lineup_models.dart';

/// 빈 슬롯 탭 시 멤버 피커 바텀시트.
///
/// - 결석자 제외 + 현재 쿼터에 이미 있는 멤버 제외
/// - 포지션 매칭 후보 우선 → 그 다음 다른 포지션
/// - 각 섹션 내부는 출전수 적은 순 → 등번호 순
/// - 멤버 탭 시 즉시 슬롯에 배치 + 시트 닫음
Future<void> showSlotPickerSheet(
  BuildContext context, {
  required int slotIndex,
  required String slotPosition,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _SlotPickerSheet(
      slotIndex: slotIndex,
      slotPosition: slotPosition,
    ),
  );
}

class _SlotPickerSheet extends ConsumerWidget {
  const _SlotPickerSheet({
    required this.slotIndex,
    required this.slotPosition,
  });

  final int slotIndex;
  final String slotPosition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lineupControllerProvider);
    final controller = ref.read(lineupControllerProvider.notifier);
    final currentQuarterIdx = state.currentQuarter;
    final currentQuarter = state.quarters[currentQuarterIdx];
    final excludeIds = currentQuarter.memberIds;
    final playCount = state.playCountByMemberId;

    final candidates = state.roster
        .where((m) => !excludeIds.contains(m.id))
        .toList();

    int sortFn(LineupMember a, LineupMember b) {
      final cA = playCount[a.id] ?? 0;
      final cB = playCount[b.id] ?? 0;
      if (cA != cB) return cA.compareTo(cB);
      final na = a.number ?? 999;
      final nb = b.number ?? 999;
      return na.compareTo(nb);
    }

    final matched = candidates
        .where((m) => m.preferredPosition == slotPosition)
        .toList()
      ..sort(sortFn);
    final others = candidates
        .where((m) => m.preferredPosition != slotPosition)
        .toList()
      ..sort(sortFn);

    final maxHeight = MediaQuery.of(context).size.height * 0.75;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 핸들
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(top: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.iconInactive,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.base),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Q${currentQuarterIdx + 1} ',
                      style: AppTextStyles.heading.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    Text(
                      slotPosition,
                      style: AppTextStyles.heading.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      ' 자리에 누구?',
                      style: AppTextStyles.heading.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (candidates.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xl,
                  ),
                  child: _EmptyHint(),
                )
              else
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    children: [
                      if (matched.isNotEmpty) ...[
                        _SectionLabel(label: '$slotPosition 추천'),
                        const SizedBox(height: AppSpacing.xs),
                        for (final m in matched)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.xs,
                            ),
                            child: _CandidateRow(
                              member: m,
                              playCount: playCount[m.id] ?? 0,
                              isPositionMatch: true,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                controller.placeAtSlot(m.id, slotIndex);
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        if (others.isNotEmpty)
                          const SizedBox(height: AppSpacing.sm),
                      ],
                      if (others.isNotEmpty) ...[
                        const _SectionLabel(label: '다른 포지션'),
                        const SizedBox(height: AppSpacing.xs),
                        for (final m in others)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.xs,
                            ),
                            child: _CandidateRow(
                              member: m,
                              playCount: playCount[m.id] ?? 0,
                              isPositionMatch: false,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                controller.placeAtSlot(m.id, slotIndex);
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(
        label,
        style: AppTextStyles.captionMedium.copyWith(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CandidateRow extends StatelessWidget {
  const _CandidateRow({
    required this.member,
    required this.playCount,
    required this.isPositionMatch,
    required this.onTap,
  });

  final LineupMember member;
  final int playCount;
  final bool isPositionMatch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = fairnessOf(playCount);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: ShapeDecoration(
          color: AppColors.surfaceLight,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.smoothSm),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: status.color, width: 2),
                  ),
                  child: ClipOval(
                    child: member.avatarPath != null
                        ? Image.asset(
                            member.avatarPath!,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: AppColors.primary,
                            alignment: Alignment.center,
                            child: Text(
                              member.initials,
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 16,
                    height: 16,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: status.color,
                      border: Border.all(
                        color: AppColors.surfaceLight,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      '$playCount',
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      member.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: ShapeDecoration(
                      color: isPositionMatch
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.smoothXs,
                      ),
                    ),
                    child: Text(
                      member.preferredPosition,
                      style: AppTextStyles.caption.copyWith(
                        color: isPositionMatch
                            ? AppColors.primary
                            : AppColors.textTertiary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (member.isMercenary) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: ShapeDecoration(
                        color: AppColors.textPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.smoothXs,
                        ),
                      ),
                      child: const Text(
                        '용병',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '배치 가능한 선수가 없어요',
        style: AppTextStyles.body.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}
