import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../models/lineup_models.dart';

/// 현재 쿼터의 벤치 — 카드/border 없는 평평한 가로 스크롤.
///
/// - 섹션 라벨 + 가로 스크롤 칩
/// - DragTarget: 필드에서 드래그된 멤버를 받아 현재 쿼터에서 제거
/// - hover 시 라벨 우측에 "여기로 빼기" 텍스트 노출
class BenchPanel extends StatelessWidget {
  const BenchPanel({
    required this.benchMembers,
    required this.playCount,
    required this.currentQuarter,
    required this.currentQuarterMemberIds,
    required this.onMemberDroppedOnBench,
    super.key,
  });

  final List<LineupMember> benchMembers;
  final Map<String, int> playCount;
  final int currentQuarter;
  final Set<String> currentQuarterMemberIds;
  final ValueChanged<String> onMemberDroppedOnBench;

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) {
        return currentQuarterMemberIds.contains(details.data);
      },
      onAcceptWithDetails: (details) {
        HapticFeedback.lightImpact();
        onMemberDroppedOnBench(details.data);
      },
      builder: (context, candidate, rejected) {
        final hovering = candidate.isNotEmpty;
        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '벤치',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${benchMembers.length}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.iconInactive,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    if (hovering)
                      Text(
                        '여기에 놓아 빼기',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 78,
                child: benchMembers.isEmpty
                    ? const _EmptyBench()
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        itemCount: benchMembers.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: AppSpacing.base),
                        itemBuilder: (_, i) => BenchChip(
                          member: benchMembers[i],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════
// BenchChip — 아바타 + 이름만
// ══════════════════════════════════════════════

class BenchChip extends StatelessWidget {
  const BenchChip({
    required this.member,
    super.key,
  });

  final LineupMember member;

  @override
  Widget build(BuildContext context) {
    final visual = _buildVisual();
    return Draggable<String>(
      data: member.id,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: _BenchDragFeedback(member: member),
      childWhenDragging: Opacity(opacity: 0.3, child: visual),
      onDragStarted: () => HapticFeedback.lightImpact(),
      child: visual,
    );
  }

  Widget _buildVisual() {
    return SizedBox(
      width: 52,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceLight,
            ),
            padding: const EdgeInsets.all(2),
            child: ClipOval(
              child: member.avatarPath != null
                  ? Image.asset(member.avatarPath!, fit: BoxFit.cover)
                  : _InitialAvatar(member: member),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            member.name,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 보조 위젯
// ══════════════════════════════════════════════

class _EmptyBench extends StatelessWidget {
  const _EmptyBench();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '벤치가 비어있어요',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({required this.member});
  final LineupMember member;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      alignment: Alignment.center,
      child: Text(
        member.initials,
        style: const TextStyle(
          fontFamily: 'Pretendard',
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _BenchDragFeedback extends StatelessWidget {
  const _BenchDragFeedback({required this.member});
  final LineupMember member;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: AppColors.primary, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(2),
        child: ClipOval(
          child: member.avatarPath != null
              ? Image.asset(member.avatarPath!, fit: BoxFit.cover)
              : _InitialAvatar(member: member),
        ),
      ),
    );
  }
}
