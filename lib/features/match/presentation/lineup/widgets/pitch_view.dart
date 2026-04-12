import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../lineup_design.dart';
import '../models/lineup_models.dart';
import 'pitch_lines_painter.dart';

/// 드래그앤드롭 가능한 미니멀 축구장 뷰.
///
/// 디자인 원칙:
/// - 흰/회색 톤 (surfaceLight 배경, 옅은 라인)
/// - 슬롯은 흰 원 + 가는 outline
/// - 이름 라벨은 슬롯 밖 (검은 박스 없음)
/// - 빈 슬롯은 + 아이콘
class PitchView extends StatelessWidget {
  const PitchView({
    required this.formation,
    required this.slotMembers,
    required this.playCount,
    required this.onDropToSlot,
    required this.onEmptySlotTap,
    this.overlay,
    this.rightOverlay,
    super.key,
  });

  final Formation formation;
  final Map<int, LineupMember> slotMembers;
  final Map<String, int> playCount;
  final void Function(String memberId, int slotIndex) onDropToSlot;
  final void Function(int slotIndex, String slotPosition) onEmptySlotTap;

  /// 피치 좌상단에 띄울 위젯 (예: FairnessOverlay).
  final Widget? overlay;

  /// 피치 우상단에 띄울 위젯 (예: FormationDropdown).
  final Widget? rightOverlay;

  @override
  Widget build(BuildContext context) {
    return ClipSmoothRect(
      radius: AppRadius.smoothLg,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: LineupColors.pitchBackground,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const slotSize = 42.0;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                const Positioned.fill(
                  child: CustomPaint(painter: PitchLinesPainter()),
                ),
                for (int i = 0; i < formation.slots.length; i++)
                  Positioned(
                    left: formation.slots[i].x * constraints.maxWidth -
                        slotSize / 2,
                    top: formation.slots[i].y * constraints.maxHeight -
                        slotSize / 2 -
                        8,
                    child: SizedBox(
                      width: slotSize,
                      child: PlayerSlot(
                        slotIndex: i,
                        position: formation.slots[i].position,
                        member: slotMembers[i],
                        playCount: slotMembers[i] != null
                            ? (playCount[slotMembers[i]!.id] ?? 0)
                            : 0,
                        size: slotSize,
                        onAccept: (memberId) => onDropToSlot(memberId, i),
                        onEmptyTap: () => onEmptySlotTap(
                          i,
                          formation.slots[i].position,
                        ),
                      ),
                    ),
                  ),
                if (overlay != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: overlay!,
                  ),
                if (rightOverlay != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: rightOverlay!,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// PlayerSlot
// ══════════════════════════════════════════════

class PlayerSlot extends StatelessWidget {
  const PlayerSlot({
    required this.slotIndex,
    required this.position,
    required this.member,
    required this.playCount,
    required this.size,
    required this.onAccept,
    required this.onEmptyTap,
    super.key,
  });

  final int slotIndex;
  final String position;
  final LineupMember? member;
  final int playCount;
  final double size;
  final ValueChanged<String> onAccept;
  final VoidCallback onEmptyTap;

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => details.data != member?.id,
      onAcceptWithDetails: (details) {
        HapticFeedback.selectionClick();
        onAccept(details.data);
      },
      builder: (context, candidate, rejected) {
        final hovering = candidate.isNotEmpty;
        final visual = _buildVisual(hovering: hovering, isPlaceholder: false);

        if (member == null) {
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onEmptyTap();
            },
            behavior: HitTestBehavior.opaque,
            child: visual,
          );
        }

        return Draggable<String>(
          data: member!.id,
          dragAnchorStrategy: pointerDragAnchorStrategy,
          feedback: _DragFeedback(member: member!, size: size),
          childWhenDragging: _buildVisual(
            hovering: false,
            isPlaceholder: true,
          ),
          onDragStarted: () => HapticFeedback.lightImpact(),
          child: visual,
        );
      },
    );
  }

  Widget _buildVisual({required bool hovering, required bool isPlaceholder}) {
    final hasMember = member != null && !isPlaceholder;
    final status = fairnessOf(playCount);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasMember
                    ? Colors.white
                    : (hovering
                        ? Colors.white.withValues(alpha: 0.18)
                        : Colors.white.withValues(alpha: 0.08)),
                border: Border.all(
                  color: hovering
                      ? Colors.white
                      : LineupColors.pitchBackground,
                  width: hovering ? 1.0 : 0.3,
                ),
              ),
              child: hasMember
                  ? Padding(
                      padding: const EdgeInsets.all(2),
                      child: ClipOval(
                        child: member!.avatarPath != null
                            ? Image.asset(
                                member!.avatarPath!,
                                fit: BoxFit.cover,
                              )
                            : _initialAvatar(member!),
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.add_rounded,
                        size: 18,
                        color: AppColors.iconInactive,
                      ),
                    ),
            ),
            // 출전수 뱃지 (멤버 있을 때만)
            if (hasMember)
              Positioned(
                right: -1,
                bottom: -1,
                child: Container(
                  width: 14,
                  height: 14,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: status.color,
                    border: Border.all(
                      color: LineupColors.pitchBackground,
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
        const SizedBox(height: 6),
        // 라벨 (검은 박스 없음)
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: size + 36),
          child: Text(
            hasMember ? member!.name : position,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              fontWeight: FontWeight.w800,
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

Widget _initialAvatar(LineupMember member) {
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

class _DragFeedback extends StatelessWidget {
  const _DragFeedback({required this.member, required this.size});

  final LineupMember member;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: size + 10,
        height: size + 10,
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
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: ClipOval(
            child: member.avatarPath != null
                ? Image.asset(member.avatarPath!, fit: BoxFit.cover)
                : _initialAvatar(member),
          ),
        ),
      ),
    );
  }
}
