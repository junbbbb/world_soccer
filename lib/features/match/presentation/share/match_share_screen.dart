import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../lineup/logic/lineup_controller.dart';
import '../lineup/models/lineup_models.dart';
import 'widgets/squad_share_card.dart';

/// 라인업을 4장의 공유 이미지로 미리보는 화면.
///
/// 진입: 경기 상세 우측 상단 공유 아이콘 → /match/share
/// 데이터: lineupControllerProvider (keepAlive) — 빌더에서 편집한 라인업 그대로
class MatchShareScreen extends ConsumerWidget {
  const MatchShareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lineupControllerProvider);
    final formations =
        ref.read(lineupControllerProvider.notifier).formations;

    final hasAnyLineup =
        state.quarters.any((q) => q.slotToMemberId.isNotEmpty);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: Text(
          '공유하기',
          style: AppTextStyles.heading.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: hasAnyLineup
          ? ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.base,
                AppSpacing.lg,
                AppSpacing.base + 88, // bottom bar 공간
              ),
              children: [
                for (int q = 0; q < state.quarters.length; q++) ...[
                  _buildCard(state, formations, q),
                  if (q < state.quarters.length - 1)
                    const SizedBox(height: AppSpacing.base),
                ],
              ],
            )
          : const _EmptyState(),
      bottomNavigationBar: _BottomBar(enabled: hasAnyLineup),
    );
  }

  Widget _buildCard(
    LineupState state,
    List<Formation> formations,
    int q,
  ) {
    final quarter = state.quarters[q];
    final formation = formations[quarter.formationIndex];

    final slotMembers = <int, LineupMember>{};
    quarter.slotToMemberId.forEach((idx, id) {
      final m = state.memberById(id);
      if (m != null) {
        slotMembers[idx] = m;
      }
    });

    final memberIds = quarter.memberIds;
    final bench = state.roster
        .where((m) => !memberIds.contains(m.id))
        .toList();

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothLg),
        shadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipSmoothRect(
        radius: AppRadius.smoothLg,
        child: SquadShareCard(
          quarterIndex: q,
          formation: formation,
          slotMembers: slotMembers,
          benchMembers: bench,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 빈 상태
// ══════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.sports_soccer_rounded,
              size: 48,
              color: AppColors.iconInactive,
            ),
            const SizedBox(height: AppSpacing.base),
            Text(
              '라인업이 아직 없어요',
              style: AppTextStyles.heading.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '먼저 라인업 편집에서 스쿼드를 만들어주세요',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// Bottom bar
// ══════════════════════════════════════════════

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.sm,
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: enabled
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          '다음 단계에서 카톡 공유 연결 예정',
                        ),
                        shape: SmoothRectangleBorder(
                          borderRadius: AppRadius.smoothMd,
                        ),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.surface,
              disabledForegroundColor: AppColors.textTertiary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: SmoothRectangleBorder(
                borderRadius: AppRadius.smoothButton,
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.ios_share_rounded, size: 20),
                SizedBox(width: AppSpacing.sm),
                Text(
                  '4장 공유하기',
                  style: AppTextStyles.buttonPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
