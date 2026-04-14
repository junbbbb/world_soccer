import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/section_title.dart';
import '../lineup/lineup_design.dart';
import '../lineup/logic/lineup_controller.dart';
import '../lineup/models/lineup_models.dart';
import '../lineup/widgets/mini_pitch_view.dart';

class LineupSection extends ConsumerWidget {
  const LineupSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lineupControllerProvider);
    final formations =
        ref.read(lineupControllerProvider.notifier).formations;
    final hasLineup =
        state.quarters.any((q) => q.slotToMemberId.isNotEmpty);

    return Padding(
      padding: AppSpacing.paddingSection,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            '라인업',
            trailing: hasLineup
                ? GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      context.push('/match/lineup-builder');
                    },
                    child: Text(
                      '수정',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : null,
          ),
          if (hasLineup)
            _LineupCard(state: state, formations: formations)
          else
            const _EmptyLineup(),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 라인업 카드 (그리드 + 전술 메모)
// ══════════════════════════════════════════════

class _LineupCard extends StatelessWidget {
  const _LineupCard({required this.state, required this.formations});

  final LineupState state;
  final List<Formation> formations;

  // TODO: LineupState 에 tacticsNote 추가되면 연결.
  String? get _tacticsNote => null;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smoothLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LineupGrid(state: state, formations: formations),
            const SizedBox(height: AppSpacing.lg),
            _TacticsNote(note: _tacticsNote),
          ],
        ),
      ),
    );
  }
}

class _TacticsNote extends StatelessWidget {
  const _TacticsNote({this.note});

  final String? note;

  @override
  Widget build(BuildContext context) {
    final hasNote = note != null && note!.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '감독의 전술',
            style: AppTextStyles.captionBold.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            hasNote ? note! : '전술 메모가 아직 없어요',
            style: AppTextStyles.bodyRegular.copyWith(
              color: hasNote
                  ? AppColors.textPrimary
                  : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 2×2 미니 피치 그리드
// ══════════════════════════════════════════════

class _LineupGrid extends StatelessWidget {
  const _LineupGrid({required this.state, required this.formations});

  final LineupState state;
  final List<Formation> formations;

  static const _divider = 1.0;

  @override
  Widget build(BuildContext context) {
    // 외곽만 둥글게, 내부 맞닿는 면은 직각
    return ClipRRect(
      borderRadius: AppRadius.smoothLg,
      child: ColoredBox(
        color: LineupColors.pitchBackground.withValues(alpha: 0.4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(child: _buildMini(context, 0)),
                  const SizedBox(width: _divider),
                  Expanded(child: _buildMini(context, 1)),
                ],
              ),
            ),
            const SizedBox(height: _divider),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(child: _buildMini(context, 2)),
                  const SizedBox(width: _divider),
                  Expanded(child: _buildMini(context, 3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMini(BuildContext context, int quarterIndex) {
    final quarter = state.quarters[quarterIndex];
    final formation = formations[quarter.formationIndex];
    final slotMembers = <int, LineupMember>{};
    quarter.slotToMemberId.forEach((slotIdx, memberId) {
      final m = state.memberById(memberId);
      if (m != null) slotMembers[slotIdx] = m;
    });

    return MiniPitchView(
      quarterIndex: quarterIndex,
      formation: formation,
      slotMembers: slotMembers,
      onTap: () {
        HapticFeedback.selectionClick();
        context.push('/match/lineup-view', extra: quarterIndex);
      },
    );
  }
}

// ══════════════════════════════════════════════
// 라인업 미생성 상태
// ══════════════════════════════════════════════

class _EmptyLineup extends StatelessWidget {
  const _EmptyLineup();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '라인업 & 전술 공개 전이에요',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              context.push('/match/lineup-builder');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.smoothMd,
              ),
            ),
            child: const Text(
              '라인업 만들기',
              style: AppTextStyles.buttonSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
