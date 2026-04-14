import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../lineup_design.dart';
import '../models/lineup_models.dart';
import 'pitch_lines_painter.dart';

/// 2×2 그리드용 미니 피치 뷰.
///
/// 실제 라인업(`PitchView`)을 축소해서 보여주는 프리뷰.
/// 실제 피치는 세로로 긴 비율이지만 프리뷰 셀은 1:1 정사각형이라
/// 가운데 기준으로 위아래가 살짝 잘려나감.
class MiniPitchView extends StatelessWidget {
  const MiniPitchView({
    required this.quarterIndex,
    required this.formation,
    required this.slotMembers,
    required this.onTap,
    super.key,
  });

  final int quarterIndex;
  final Formation formation;
  final Map<int, LineupMember> slotMembers;
  final VoidCallback onTap;

  /// 실제 피치의 세로/가로 비율 근사치. 1보다 크면 세로가 더 김.
  static const _pitchAspect = 1.5;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: LineupColors.pitchBackground,
          ),
          child: Stack(
            children: [
              // 피치 + 슬롯 (1:1 밖으로 넘쳐 잘림)
              Positioned.fill(
                child: ClipRect(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final h = w * _pitchAspect;
                      return OverflowBox(
                        minWidth: w,
                        maxWidth: w,
                        minHeight: h,
                        maxHeight: h,
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: w,
                          height: h,
                          child: _PitchContent(
                            formation: formation,
                            slotMembers: slotMembers,
                            width: w,
                            height: h,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // 라벨은 1:1 영역 위에 오버레이 (잘리지 않음)
              Positioned(
                top: 6,
                left: 8,
                child: Text(
                  'Q${quarterIndex + 1}',
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                top: 7,
                right: 8,
                child: Text(
                  formation.name,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 피치 내부 (라인 + 슬롯)
// ══════════════════════════════════════════════

class _PitchContent extends StatelessWidget {
  const _PitchContent({
    required this.formation,
    required this.slotMembers,
    required this.width,
    required this.height,
  });

  final Formation formation;
  final Map<int, LineupMember> slotMembers;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    // 셀 크기에 비례한 슬롯 사이즈.
    final slotSize = (width * 0.16).clamp(12.0, 22.0);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Positioned.fill(
          child: CustomPaint(
            painter: PitchLinesPainter(strokeWidth: 0.5),
          ),
        ),
        for (int i = 0; i < formation.slots.length; i++)
          Positioned(
            left: formation.slots[i].x * width - slotSize / 2,
            top: formation.slots[i].y * height - slotSize / 2,
            child: _MiniSlot(
              size: slotSize,
              member: slotMembers[i],
            ),
          ),
      ],
    );
  }
}

// ══════════════════════════════════════════════
// 미니 플레이어 슬롯 (아바타 또는 이니셜)
// ══════════════════════════════════════════════

class _MiniSlot extends StatelessWidget {
  const _MiniSlot({required this.size, required this.member});

  final double size;
  final LineupMember? member;

  @override
  Widget build(BuildContext context) {
    final hasMember = member != null;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: hasMember
            ? Colors.white
            : Colors.white.withValues(alpha: 0.2),
        border: Border.all(
          color: LineupColors.pitchBackground,
          width: 0.5,
        ),
      ),
      child: hasMember
          ? Padding(
              padding: const EdgeInsets.all(1),
              child: ClipOval(
                child: member!.avatarPath != null
                    ? Image.asset(member!.avatarPath!, fit: BoxFit.cover)
                    : _initialAvatar(member!, size),
              ),
            )
          : null,
    );
  }
}

Widget _initialAvatar(LineupMember member, double size) {
  return Container(
    color: AppColors.surface,
    alignment: Alignment.center,
    child: Text(
      member.initials,
      style: TextStyle(
        fontFamily: 'Pretendard',
        color: AppColors.textPrimary,
        fontSize: size * 0.5,
        fontWeight: FontWeight.w800,
        height: 1.0,
      ),
    ),
  );
}
