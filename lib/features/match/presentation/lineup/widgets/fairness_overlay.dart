import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../models/lineup_models.dart';

/// 피치 위 작은 공정성 칩.
///
/// 미니멀 톤: 흰 배경 + 옅은 outline + textPrimary/Tertiary 텍스트.
/// 가장 시급한 정보 한 줄만 표시.
class FairnessOverlay extends StatelessWidget {
  const FairnessOverlay({required this.state, super.key});

  final LineupState state;

  @override
  Widget build(BuildContext context) {
    final memberCount = state.roster.length;
    final unassigned = state.unassignedCount;
    final under = state.underAssignedCount;
    final full = state.fullPlayCount;

    final hasIssue = unassigned > 0 || under > 0 || full > 0;

    final label = _resolveLabel(
      memberCount: memberCount,
      unassigned: unassigned,
      under: under,
      full: full,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.iconInactive,
          width: 0.8,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: hasIssue
              ? AppColors.textPrimary
              : AppColors.textTertiary,
          height: 1.0,
        ),
      ),
    );
  }

  String _resolveLabel({
    required int memberCount,
    required int unassigned,
    required int under,
    required int full,
  }) {
    if (unassigned > 0) {
      return '명단 $memberCount · 미배정 $unassigned';
    }
    if (under > 0) {
      return '명단 $memberCount · 1쿼만 $under';
    }
    if (full > 0) {
      return '명단 $memberCount · 풀출전 $full';
    }
    return '명단 $memberCount · 적정';
  }
}
