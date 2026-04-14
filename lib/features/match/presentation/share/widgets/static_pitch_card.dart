import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../lineup/models/lineup_models.dart';
import '../../lineup/widgets/pitch_lines_painter.dart';

// 공유 카드용 초록 피치 색 (라인업 빌더는 흰 피치 사용).
const _sharePitchGreen = Color(0xFF2D6E3E);
const _sharePitchGreenDark = Color(0xFF255A33);

/// 읽기 전용 정적 피치 카드. 공유 이미지용.
///
/// PitchView와 다른 점:
/// - 드래그/탭 인터랙션 없음
/// - DragTarget/LongPressDraggable 없음
/// - 빈 슬롯은 포지션 라벨(GK/DF/MF/FW) 표시
/// - 픽셀 비율 고정을 위해 AspectRatio 유지
class StaticPitchCard extends StatelessWidget {
  const StaticPitchCard({
    required this.formation,
    required this.slotMembers,
    super.key,
  });

  final Formation formation;
  final Map<int, LineupMember> slotMembers;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.85,
      child: ClipRRect(
        borderRadius: AppRadius.smoothMd,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_sharePitchGreen, _sharePitchGreenDark],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final slotSize = constraints.maxWidth * 0.10;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  const Positioned.fill(
                    child: CustomPaint(
                      painter: PitchLinesPainter(
                        color: Color(0x66FFFFFF),
                        strokeWidth: 1.5,
                      ),
                    ),
                  ),
                  for (int i = 0; i < formation.slots.length; i++)
                    Positioned(
                      left: formation.slots[i].x * constraints.maxWidth -
                          slotSize / 2,
                      top: formation.slots[i].y * constraints.maxHeight -
                          slotSize / 2 -
                          6,
                      child: _StaticSlot(
                        position: formation.slots[i].position,
                        member: slotMembers[i],
                        size: slotSize,
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

class _StaticSlot extends StatelessWidget {
  const _StaticSlot({
    required this.position,
    required this.member,
    required this.size,
  });

  final String position;
  final LineupMember? member;
  final double size;

  @override
  Widget build(BuildContext context) {
    final hasMember = member != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasMember
                ? Colors.white
                : Colors.white.withValues(alpha: 0.14),
            border: Border.all(
              color: hasMember
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.55),
              width: hasMember ? 2 : 1.5,
            ),
          ),
          child: hasMember
              ? ClipOval(
                  child: member!.avatarPath != null
                      ? Image.asset(
                          member!.avatarPath!,
                          fit: BoxFit.cover,
                        )
                      : _InitialAvatar(member: member!),
                )
              : Center(
                  child: Text(
                    position,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: size * 0.26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 4),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: size + 44),
          child: Text(
            hasMember ? member!.name : '—',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: size * 0.32,
              fontWeight: FontWeight.w900,
              color: hasMember
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({required this.member});
  final LineupMember member;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      alignment: Alignment.center,
      child: Text(
        member.initials,
        style: const TextStyle(
          fontFamily: 'Pretendard',
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
