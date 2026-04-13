import 'package:flutter/material.dart';

import '../lineup_design.dart';
import '../models/lineup_models.dart';
import 'pitch_lines_painter.dart';

/// 2×2 그리드용 미니 피치 뷰.
///
/// 클리핑/라운딩은 부모(_LineupGrid)가 담당.
/// 개별 셀은 정사각형, radius 없음.
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              const dotSize = 10.0;
              return Stack(
                children: [
                  const Positioned.fill(
                    child: CustomPaint(
                      painter: PitchLinesPainter(strokeWidth: 0.5),
                    ),
                  ),
                  for (int i = 0; i < formation.slots.length; i++)
                    Positioned(
                      left: formation.slots[i].x * constraints.maxWidth -
                          dotSize / 2,
                      top: formation.slots[i].y * constraints.maxHeight -
                          dotSize / 2,
                      child: Container(
                        width: dotSize,
                        height: dotSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: slotMembers.containsKey(i)
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
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
              );
            },
          ),
        ),
      ),
    );
  }
}
