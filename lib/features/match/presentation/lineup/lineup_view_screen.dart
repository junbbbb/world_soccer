import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'lineup_design.dart';
import 'logic/lineup_controller.dart';
import 'models/lineup_models.dart';
import 'widgets/pitch_lines_painter.dart';
import 'widgets/quarter_selector.dart';

/// 읽기 전용 라인업 뷰 — 사용자가 라인업을 조회만 가능.
///
/// 드래그앤드롭, 편집, 벤치 패널 없음.
/// 쿼터 선택으로 Q1~Q4 전환만 가능.
class LineupViewScreen extends ConsumerStatefulWidget {
  const LineupViewScreen({super.key, this.initialQuarter = 0});

  final int initialQuarter;

  @override
  ConsumerState<LineupViewScreen> createState() => _LineupViewScreenState();
}

class _LineupViewScreenState extends ConsumerState<LineupViewScreen> {
  late int _currentQuarter;

  @override
  void initState() {
    super.initState();
    _currentQuarter = widget.initialQuarter;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lineupControllerProvider);
    final formations = ref.read(lineupControllerProvider.notifier).formations;

    final quarterLineup = state.quarters[_currentQuarter];
    final formation = formations[quarterLineup.formationIndex];

    final slotMembers = <int, LineupMember>{};
    quarterLineup.slotToMemberId.forEach((slotIdx, memberId) {
      final m = state.memberById(memberId);
      if (m != null) slotMembers[slotIdx] = m;
    });

    final playCount = state.playCountByMemberId;
    final currentQuarterMemberIds = quarterLineup.memberIds;

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
        return pA.compareTo(pB);
      });

    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // ── 헤더 ──
            Container(
              padding: EdgeInsets.only(top: topPadding),
              color: Colors.white,
              child: SizedBox(
                height: 56,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.base,
                          vertical: AppSpacing.sm,
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          '라인업',
                          style: AppTextStyles.heading.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    // 헤더 좌우 균형용
                    const SizedBox(width: 52),
                  ],
                ),
              ),
            ),

            // ── 쿼터 선택 ──
            QuarterSelector(
              quarters: state.quarters,
              currentQuarter: _currentQuarter,
              formations: formations,
              onQuarterTap: (q) {
                HapticFeedback.selectionClick();
                setState(() => _currentQuarter = q);
              },
            ),
            const SizedBox(height: AppSpacing.base),

            // ── 읽기 전용 피치 ──
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _ReadOnlyPitchView(
                  formation: formation,
                  slotMembers: slotMembers,
                  playCount: playCount,
                ),
              ),
            ),

            // ── 후보(벤치) ──
            _ReadOnlyBenchPanel(benchMembers: benchMembers),
            SizedBox(height: bottomPadding + AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 읽기 전용 피치 뷰 — 드래그/드롭 없음
// ══════════════════════════════════════════════

class _ReadOnlyPitchView extends StatelessWidget {
  const _ReadOnlyPitchView({
    required this.formation,
    required this.slotMembers,
    required this.playCount,
  });

  final Formation formation;
  final Map<int, LineupMember> slotMembers;
  final Map<String, int> playCount;

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
                      child: _ReadOnlySlot(
                        position: formation.slots[i].position,
                        member: slotMembers[i],
                        playCount: slotMembers[i] != null
                            ? (playCount[slotMembers[i]!.id] ?? 0)
                            : 0,
                        size: slotSize,
                      ),
                    ),
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
// 읽기 전용 슬롯 — 상호작용 없음
// ══════════════════════════════════════════════

class _ReadOnlySlot extends StatelessWidget {
  const _ReadOnlySlot({
    required this.position,
    required this.member,
    required this.playCount,
    required this.size,
  });

  final String position;
  final LineupMember? member;
  final int playCount;
  final double size;

  @override
  Widget build(BuildContext context) {
    final hasMember = member != null;
    final status = fairnessOf(playCount);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasMember
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.08),
                border: Border.all(
                  color: LineupColors.pitchBackground,
                  width: 0.3,
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
                  : Center(
                      child: Text(
                        position,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
            ),
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

// ══════════════════════════════════════════════
// 읽기 전용 벤치 패널
// ══════════════════════════════════════════════

class _ReadOnlyBenchPanel extends StatelessWidget {
  const _ReadOnlyBenchPanel({required this.benchMembers});

  final List<LineupMember> benchMembers;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '후보',
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
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 78,
            child: benchMembers.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '후보가 없어요',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    itemCount: benchMembers.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSpacing.base),
                    itemBuilder: (_, i) =>
                        _ReadOnlyBenchChip(member: benchMembers[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyBenchChip extends StatelessWidget {
  const _ReadOnlyBenchChip({required this.member});

  final LineupMember member;

  @override
  Widget build(BuildContext context) {
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
                  : _initialAvatar(member),
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
