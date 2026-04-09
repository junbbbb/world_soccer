import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

// ══════════════════════════════════════════════
// 모델
// ══════════════════════════════════════════════

class _LineupMember {
  final String id;
  final String name;
  final String position;
  final int number;
  final String avatarPath;

  const _LineupMember({
    required this.id,
    required this.name,
    required this.position,
    required this.number,
    required this.avatarPath,
  });
}

class _SlotPosition {
  final double x;
  final double y;
  final String position;
  const _SlotPosition(this.x, this.y, this.position);
}

class _Formation {
  final String name;
  final List<_SlotPosition> slots;
  const _Formation({required this.name, required this.slots});
}

// ══════════════════════════════════════════════
// 더미 데이터
// ══════════════════════════════════════════════

const _avA = 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif';
const _avB = 'assets/images/avatars/MOSQUERA_Headshot_web_b3sucu1j.avif';
const _avC = 'assets/images/avatars/SALIBA_Headshot_web_khl9z1vw.avif';
const _avD = 'assets/images/avatars/RAYA_Headshot_web_njztl3wr.avif';

const _allMembers = <_LineupMember>[
  _LineupMember(id: '1', name: '박서준', position: 'GK', number: 1, avatarPath: _avD),
  _LineupMember(id: '21', name: '한준혁', position: 'GK', number: 21, avatarPath: _avD),
  _LineupMember(id: '2', name: '윤태경', position: 'DF', number: 2, avatarPath: _avC),
  _LineupMember(id: '4', name: '정도현', position: 'DF', number: 4, avatarPath: _avC),
  _LineupMember(id: '5', name: '김재윤', position: 'DF', number: 5, avatarPath: _avC),
  _LineupMember(id: '15', name: '이현우', position: 'DF', number: 15, avatarPath: _avC),
  _LineupMember(id: '23', name: '송민호', position: 'DF', number: 23, avatarPath: _avC),
  _LineupMember(id: '7', name: '이병준', position: 'MF', number: 7, avatarPath: _avA),
  _LineupMember(id: '8', name: '최민수', position: 'MF', number: 8, avatarPath: _avA),
  _LineupMember(id: '10', name: '윤서준', position: 'MF', number: 10, avatarPath: _avA),
  _LineupMember(id: '14', name: '강지훈', position: 'MF', number: 14, avatarPath: _avA),
  _LineupMember(id: '16', name: '조원빈', position: 'MF', number: 16, avatarPath: _avA),
  _LineupMember(id: '9', name: '김태호', position: 'FW', number: 9, avatarPath: _avB),
  _LineupMember(id: '11', name: '박정우', position: 'FW', number: 11, avatarPath: _avB),
  _LineupMember(id: '17', name: '신유찬', position: 'FW', number: 17, avatarPath: _avB),
  _LineupMember(id: '19', name: '오준영', position: 'FW', number: 19, avatarPath: _avB),
];

const _formations = <_Formation>[
  _Formation(
    name: '4-4-2',
    slots: [
      _SlotPosition(0.50, 0.92, 'GK'),
      _SlotPosition(0.15, 0.72, 'DF'),
      _SlotPosition(0.38, 0.72, 'DF'),
      _SlotPosition(0.62, 0.72, 'DF'),
      _SlotPosition(0.85, 0.72, 'DF'),
      _SlotPosition(0.15, 0.50, 'MF'),
      _SlotPosition(0.38, 0.50, 'MF'),
      _SlotPosition(0.62, 0.50, 'MF'),
      _SlotPosition(0.85, 0.50, 'MF'),
      _SlotPosition(0.35, 0.25, 'FW'),
      _SlotPosition(0.65, 0.25, 'FW'),
    ],
  ),
  _Formation(
    name: '4-3-3',
    slots: [
      _SlotPosition(0.50, 0.92, 'GK'),
      _SlotPosition(0.15, 0.72, 'DF'),
      _SlotPosition(0.38, 0.72, 'DF'),
      _SlotPosition(0.62, 0.72, 'DF'),
      _SlotPosition(0.85, 0.72, 'DF'),
      _SlotPosition(0.25, 0.50, 'MF'),
      _SlotPosition(0.50, 0.50, 'MF'),
      _SlotPosition(0.75, 0.50, 'MF'),
      _SlotPosition(0.18, 0.25, 'FW'),
      _SlotPosition(0.50, 0.20, 'FW'),
      _SlotPosition(0.82, 0.25, 'FW'),
    ],
  ),
  _Formation(
    name: '3-5-2',
    slots: [
      _SlotPosition(0.50, 0.92, 'GK'),
      _SlotPosition(0.25, 0.72, 'DF'),
      _SlotPosition(0.50, 0.72, 'DF'),
      _SlotPosition(0.75, 0.72, 'DF'),
      _SlotPosition(0.10, 0.50, 'MF'),
      _SlotPosition(0.30, 0.55, 'MF'),
      _SlotPosition(0.50, 0.50, 'MF'),
      _SlotPosition(0.70, 0.55, 'MF'),
      _SlotPosition(0.90, 0.50, 'MF'),
      _SlotPosition(0.35, 0.25, 'FW'),
      _SlotPosition(0.65, 0.25, 'FW'),
    ],
  ),
];

const _pitchGreen = Color(0xFF2D6E3E);
const _pitchGreenDark = Color(0xFF255A33);
const _lineColor = Color(0x66FFFFFF);
const _warnColor = Color(0xFFE67E22);

// ══════════════════════════════════════════════
// LineupBuilderScreen
// ══════════════════════════════════════════════

class LineupBuilderScreen extends StatefulWidget {
  const LineupBuilderScreen({super.key});

  @override
  State<LineupBuilderScreen> createState() => _LineupBuilderScreenState();
}

class _LineupBuilderScreenState extends State<LineupBuilderScreen> {
  int _formationIndex = 0;
  int _currentQuarter = 0;
  late List<Map<int, _LineupMember>> _quarters;
  late List<_LineupMember> _attendees;

  _Formation get _formation => _formations[_formationIndex];
  Map<int, _LineupMember> get _currentSlots => _quarters[_currentQuarter];

  Map<String, int> get _playCountById {
    final map = <String, int>{for (var m in _attendees) m.id: 0};
    for (final q in _quarters) {
      for (final m in q.values) {
        map[m.id] = (map[m.id] ?? 0) + 1;
      }
    }
    return map;
  }

  List<_LineupMember> get _currentBench {
    final usedIds = _currentSlots.values.map((m) => m.id).toSet();
    return _attendees.where((m) => !usedIds.contains(m.id)).toList();
  }

  int get _warningCount {
    final counts = _playCountById;
    return counts.values.where((c) => c < 2 || c > 3).length;
  }

  @override
  void initState() {
    super.initState();
    _attendees = _allMembers.take(16).toList();
    _quarters = List.generate(4, (_) => <int, _LineupMember>{});
    _autoDistributeAll();
  }

  // ══════════════════════════════════════════════
  // 분배 알고리즘
  // ══════════════════════════════════════════════

  void _autoDistributeAll() {
    final formation = _formation;
    final playCount = <String, int>{for (var m in _attendees) m.id: 0};
    final newQuarters = List.generate(4, (_) => <int, _LineupMember>{});

    for (var q = 0; q < 4; q++) {
      final usedInQuarter = <String>{};
      for (var slotIdx = 0; slotIdx < formation.slots.length; slotIdx++) {
        final neededPos = formation.slots[slotIdx].position;
        final selected = _pick4Layers(neededPos, usedInQuarter, playCount);
        if (selected != null) {
          newQuarters[q][slotIdx] = selected;
          playCount[selected.id] = (playCount[selected.id] ?? 0) + 1;
          usedInQuarter.add(selected.id);
        }
      }
    }

    setState(() {
      for (var q = 0; q < 4; q++) {
        _quarters[q] = newQuarters[q];
      }
    });
  }

  void _fillEmptySlotsOnly() {
    final formation = _formation;
    final playCount = Map<String, int>.from(_playCountById);
    final newQuarters =
        _quarters.map((q) => Map<int, _LineupMember>.from(q)).toList();

    for (var q = 0; q < 4; q++) {
      final usedInQuarter = newQuarters[q].values.map((m) => m.id).toSet();
      for (var slotIdx = 0; slotIdx < formation.slots.length; slotIdx++) {
        if (newQuarters[q].containsKey(slotIdx)) continue;
        final neededPos = formation.slots[slotIdx].position;
        final selected = _pick4Layers(neededPos, usedInQuarter, playCount);
        if (selected != null) {
          newQuarters[q][slotIdx] = selected;
          playCount[selected.id] = (playCount[selected.id] ?? 0) + 1;
          usedInQuarter.add(selected.id);
        }
      }
    }

    setState(() {
      _quarters = newQuarters;
    });
  }

  _LineupMember? _pick4Layers(
    String neededPos,
    Set<String> usedInQuarter,
    Map<String, int> playCount,
  ) {
    _LineupMember? s = _pickBest(
      position: neededPos,
      usedInQuarter: usedInQuarter,
      playCount: playCount,
      maxPlayCount: 3,
    );
    s ??= _pickBest(
      position: null,
      usedInQuarter: usedInQuarter,
      playCount: playCount,
      maxPlayCount: 3,
    );
    s ??= _pickBest(
      position: neededPos,
      usedInQuarter: usedInQuarter,
      playCount: playCount,
      maxPlayCount: 4,
    );
    s ??= _pickBest(
      position: null,
      usedInQuarter: usedInQuarter,
      playCount: playCount,
      maxPlayCount: 4,
    );
    return s;
  }

  _LineupMember? _pickBest({
    required String? position,
    required Set<String> usedInQuarter,
    required Map<String, int> playCount,
    required int maxPlayCount,
  }) {
    final candidates = _attendees.where((m) {
      if (position != null && m.position != position) return false;
      if (usedInQuarter.contains(m.id)) return false;
      if ((playCount[m.id] ?? 0) >= maxPlayCount) return false;
      return true;
    }).toList();
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) {
      final diff = (playCount[a.id] ?? 0).compareTo(playCount[b.id] ?? 0);
      if (diff != 0) return diff;
      return a.number.compareTo(b.number);
    });
    return candidates.first;
  }

  // ══════════════════════════════════════════════
  // Dot Matrix 인터랙션 (핵심)
  // ══════════════════════════════════════════════

  bool _addMemberToQuarter(_LineupMember member, int quarter) {
    if (_quarters[quarter].values.any((m) => m.id == member.id)) return true;
    final slots = _formation.slots;
    for (var i = 0; i < slots.length; i++) {
      if (_quarters[quarter].containsKey(i)) continue;
      if (slots[i].position == member.position) {
        _quarters[quarter][i] = member;
        return true;
      }
    }
    for (var i = 0; i < slots.length; i++) {
      if (_quarters[quarter].containsKey(i)) continue;
      _quarters[quarter][i] = member;
      return true;
    }
    return false;
  }

  void _removeMemberFromQuarter(_LineupMember member, int quarter) {
    _quarters[quarter].removeWhere((_, m) => m.id == member.id);
  }

  void _onDotTap(_LineupMember member, int quarter) {
    HapticFeedback.selectionClick();
    final currentlyIn =
        _quarters[quarter].values.any((m) => m.id == member.id);
    setState(() {
      if (currentlyIn) {
        _removeMemberFromQuarter(member, quarter);
      } else {
        final added = _addMemberToQuarter(member, quarter);
        if (!added) {
          _showSnack('Q${quarter + 1} 슬롯이 모두 찼어요');
        }
      }
    });
  }

  void _onBenchTap(_LineupMember member) {
    HapticFeedback.selectionClick();
    setState(() {
      final added = _addMemberToQuarter(member, _currentQuarter);
      if (!added) {
        _showSnack('Q${_currentQuarter + 1} 슬롯이 모두 찼어요');
      }
    });
  }

  // ══════════════════════════════════════════════
  // 기타 핸들러
  // ══════════════════════════════════════════════

  void _onFormationChanged(int newIndex) {
    HapticFeedback.selectionClick();
    setState(() => _formationIndex = newIndex);
    _autoDistributeAll();
  }

  void _onQuarterChanged(int q) {
    HapticFeedback.selectionClick();
    setState(() => _currentQuarter = q);
  }

  void _openMemberPicker(int slotIndex) {
    HapticFeedback.selectionClick();
    final slot = _formation.slots[slotIndex];
    final usedInCurrentQuarter = _currentSlots.values.map((m) => m.id).toSet();

    showModalBottomSheet<_LineupMember>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _MemberPickerSheet(
        targetPosition: slot.position,
        attendees: _attendees,
        usedMemberIds: usedInCurrentQuarter,
        currentMember: _currentSlots[slotIndex],
        playCountById: _playCountById,
      ),
    ).then((selected) {
      if (selected == null) return;
      setState(() {
        _quarters[_currentQuarter].removeWhere((_, m) => m.id == selected.id);
        _quarters[_currentQuarter][slotIndex] = selected;
      });
    });
  }

  void _removeFromSlot(int slotIndex) {
    HapticFeedback.lightImpact();
    setState(() => _quarters[_currentQuarter].remove(slotIndex));
  }

  void _save() {
    HapticFeedback.mediumImpact();
    final totalFilled = _quarters.fold<int>(0, (sum, q) => sum + q.length);
    _showSnack('라인업 저장됨 (${_formation.name}, $totalFilled / 44 슬롯)');
    Navigator.of(context).pop();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothMd),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // Build
  // ══════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final playCount = _playCountById;
    final warnCount = _warningCount;

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
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '라인업 만들기',
                                style: AppTextStyles.heading.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (warnCount > 0) ...[
                                const SizedBox(width: AppSpacing.xs),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _warnColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$warnCount',
                                    style: const TextStyle(
                                      fontFamily: 'Pretendard',
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            '${_attendees.length}명 참석 · 4쿼터',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ✨ 탭 = 빈칸 채우기 / 길게 = 전체 재분배
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _fillEmptySlotsOnly();
                        _showSnack('빈 슬롯을 채웠어요');
                      },
                      onLongPress: () {
                        HapticFeedback.mediumImpact();
                        _autoDistributeAll();
                        _showSnack('모두 새로 분배했어요');
                      },
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          size: 22,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _save,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.base,
                        ),
                        child: Text(
                          '저장',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── 본문 (스크롤) ──
            Expanded(
              child: SingleChildScrollView(
                padding:
                    EdgeInsets.only(bottom: bottomPadding + AppSpacing.xl),
                child: Column(
                  children: [
                    // 포메이션 칩
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.sm,
                        AppSpacing.lg,
                        AppSpacing.base,
                      ),
                      child: Row(
                        children: [
                          for (int i = 0; i < _formations.length; i++) ...[
                            if (i > 0) const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _FormationChip(
                                label: _formations[i].name,
                                isSelected: _formationIndex == i,
                                onTap: () => _onFormationChanged(i),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // 출전 현황 (메인 편집)
                    _PlayTimePanel(
                      attendees: _attendees,
                      quarters: _quarters,
                      playCount: playCount,
                      currentQuarter: _currentQuarter,
                      onDotTap: _onDotTap,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // 쿼터별 포메이션 미리보기
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Row(
                        children: [
                          Text(
                            '쿼터별 포메이션',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '슬롯 탭 = 교체, 길게 = 제거',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Row(
                        children: [
                          for (int q = 0; q < 4; q++) ...[
                            if (q > 0) const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _QuarterTab(
                                label: 'Q${q + 1}',
                                count: _quarters[q].length,
                                isSelected: _currentQuarter == q,
                                onTap: () => _onQuarterChanged(q),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // 축구장
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      child: _Pitch(
                        formation: _formation,
                        slotMembers: _currentSlots,
                        onSlotTap: _openMemberPicker,
                        onSlotLongPress: _removeFromSlot,
                      ),
                    ),

                    // 벤치
                    const SizedBox(height: AppSpacing.base),
                    _BenchPanel(
                      bench: _currentBench,
                      currentQuarter: _currentQuarter,
                      onChipTap: _onBenchTap,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 출전 현황 패널 (메인 편집 영역)
// ══════════════════════════════════════════════

class _PlayTimePanel extends StatelessWidget {
  const _PlayTimePanel({
    required this.attendees,
    required this.quarters,
    required this.playCount,
    required this.currentQuarter,
    required this.onDotTap,
  });

  final List<_LineupMember> attendees;
  final List<Map<int, _LineupMember>> quarters;
  final Map<String, int> playCount;
  final int currentQuarter;
  final void Function(_LineupMember member, int quarter) onDotTap;

  List<bool> _matrix(String memberId) {
    return List.generate(4, (q) {
      return quarters[q].values.any((m) => m.id == memberId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...attendees]..sort((a, b) {
      // 경고 있는 멤버가 위로
      final cA = playCount[a.id] ?? 0;
      final cB = playCount[b.id] ?? 0;
      final warnA = (cA < 2 || cA > 3) ? 0 : 1;
      final warnB = (cB < 2 || cB > 3) ? 0 : 1;
      if (warnA != warnB) return warnA.compareTo(warnB);
      // 그 다음 포지션 순
      const posOrder = {'GK': 0, 'DF': 1, 'MF': 2, 'FW': 3};
      final pA = posOrder[a.position] ?? 9;
      final pB = posOrder[b.position] ?? 9;
      if (pA != pB) return pA.compareTo(pB);
      return a.number.compareTo(b.number);
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '출전 현황',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '탭해서 쿼터 조정',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            decoration: ShapeDecoration(
              color: AppColors.surfaceLight,
              shape: SmoothRectangleBorder(
                borderRadius: AppRadius.smoothMd,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Column(
              children: [
                // Q1~Q4 컬럼 헤더
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, 2, AppSpacing.md, 4,
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 28 + AppSpacing.sm + 70),
                      const Spacer(),
                      for (int q = 0; q < 4; q++)
                        SizedBox(
                          width: 32,
                          child: Text(
                            'Q${q + 1}',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption.copyWith(
                              color: currentQuarter == q
                                  ? AppColors.primary
                                  : AppColors.textTertiary,
                              fontWeight: currentQuarter == q
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      const SizedBox(width: 32),
                    ],
                  ),
                ),
                for (final m in sorted)
                  _PlayTimeRow(
                    member: m,
                    quarterMatrix: _matrix(m.id),
                    count: playCount[m.id] ?? 0,
                    currentQuarter: currentQuarter,
                    onDotTap: (q) => onDotTap(m, q),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Row(
            children: [
              _LegendDot(color: AppColors.primary, label: '적정 (2~3쿼터)'),
              SizedBox(width: AppSpacing.md),
              _LegendDot(color: _warnColor, label: '경고'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textTertiary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _PlayTimeRow extends StatelessWidget {
  const _PlayTimeRow({
    required this.member,
    required this.quarterMatrix,
    required this.count,
    required this.currentQuarter,
    required this.onDotTap,
  });

  final _LineupMember member;
  final List<bool> quarterMatrix;
  final int count;
  final int currentQuarter;
  final ValueChanged<int> onDotTap;

  @override
  Widget build(BuildContext context) {
    final isWarn = count < 2 || count > 3;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 3,
      ),
      child: Row(
        children: [
          ClipOval(
            child: Image.asset(
              member.avatarPath,
              width: 28,
              height: 28,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 70,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    member.name,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  member.position,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          for (int q = 0; q < 4; q++)
            _QuarterDotButton(
              active: quarterMatrix[q],
              warn: isWarn,
              highlight: currentQuarter == q,
              onTap: () => onDotTap(q),
            ),
          SizedBox(
            width: 32,
            child: Text(
              '$count',
              textAlign: TextAlign.center,
              style: AppTextStyles.label.copyWith(
                color: isWarn ? _warnColor : AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuarterDotButton extends StatelessWidget {
  const _QuarterDotButton({
    required this.active,
    required this.warn,
    required this.highlight,
    required this.onTap,
  });

  final bool active;
  final bool warn;
  final bool highlight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color dotColor =
        active ? (warn ? _warnColor : AppColors.primary) : AppColors.iconInactive;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: active ? 18 : 14,
            height: active ? 18 : 14,
            decoration: BoxDecoration(
              color: active ? dotColor : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: dotColor,
                width: active ? 0 : 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 포메이션 칩
// ══════════════════════════════════════════════

class _FormationChip extends StatelessWidget {
  const _FormationChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 36,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: isSelected ? AppColors.textPrimary : AppColors.surfaceLight,
          shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothSm),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 쿼터 탭 (미리보기용)
// ══════════════════════════════════════════════

class _QuarterTab extends StatelessWidget {
  const _QuarterTab({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final incomplete = count < 11;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 48,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.white,
          shape: SmoothRectangleBorder(
            borderRadius: AppRadius.smoothSm,
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.iconInactive,
              width: isSelected ? 1.5 : 1,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 13,
              ),
            ),
            Text(
              '$count/11',
              style: AppTextStyles.caption.copyWith(
                color: incomplete
                    ? _warnColor
                    : (isSelected ? AppColors.primary : AppColors.textTertiary),
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 축구장
// ══════════════════════════════════════════════

class _Pitch extends StatelessWidget {
  const _Pitch({
    required this.formation,
    required this.slotMembers,
    required this.onSlotTap,
    required this.onSlotLongPress,
  });

  final _Formation formation;
  final Map<int, _LineupMember> slotMembers;
  final ValueChanged<int> onSlotTap;
  final ValueChanged<int> onSlotLongPress;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.85,
      child: ClipSmoothRect(
        radius: AppRadius.smoothMd,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_pitchGreen, _pitchGreenDark],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _PitchLinesPainter()),
                  ),
                  for (int i = 0; i < formation.slots.length; i++)
                    _positionedSlot(
                      slot: formation.slots[i],
                      index: i,
                      member: slotMembers[i],
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _positionedSlot({
    required _SlotPosition slot,
    required int index,
    required _LineupMember? member,
    required double width,
    required double height,
  }) {
    const slotSize = 44.0;
    return Positioned(
      left: slot.x * width - slotSize / 2,
      top: slot.y * height - slotSize / 2,
      child: _PlayerSlot(
        slotSize: slotSize,
        member: member,
        position: slot.position,
        onTap: () => onSlotTap(index),
        onLongPress: member != null ? () => onSlotLongPress(index) : null,
      ),
    );
  }
}

class _PitchLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const inset = 6.0;
    final rect = Rect.fromLTRB(
      inset, inset, size.width - inset, size.height - inset,
    );
    canvas.drawRect(rect, paint);

    canvas.drawLine(
      Offset(inset, size.height / 2),
      Offset(size.width - inset, size.height / 2),
      paint,
    );

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.13,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      2,
      Paint()..color = _lineColor,
    );

    final boxW = size.width * 0.55;
    final boxH = size.height * 0.16;
    canvas.drawRect(
      Rect.fromLTWH((size.width - boxW) / 2, inset, boxW, boxH),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - boxW) / 2,
        size.height - inset - boxH,
        boxW,
        boxH,
      ),
      paint,
    );

    final smallW = size.width * 0.28;
    final smallH = size.height * 0.06;
    canvas.drawRect(
      Rect.fromLTWH((size.width - smallW) / 2, inset, smallW, smallH),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - smallW) / 2,
        size.height - inset - smallH,
        smallW,
        smallH,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_PitchLinesPainter oldDelegate) => false;
}

// ══════════════════════════════════════════════
// 선수 슬롯
// ══════════════════════════════════════════════

class _PlayerSlot extends StatelessWidget {
  const _PlayerSlot({
    required this.slotSize,
    required this.member,
    required this.position,
    required this.onTap,
    this.onLongPress,
  });

  final double slotSize;
  final _LineupMember? member;
  final String position;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final hasMember = member != null;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: slotSize,
            height: slotSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: hasMember
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.18),
              border: Border.all(
                color: hasMember
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.55),
                width: hasMember ? 2 : 1.5,
              ),
            ),
            child: hasMember
                ? ClipOval(
                    child: Image.asset(
                      member!.avatarPath,
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(
                    child: Text(
                      position,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(3),
            ),
            constraints: const BoxConstraints(maxWidth: 64),
            child: Text(
              hasMember ? member!.name : '비어있음',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: hasMember
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 벤치 패널 (탭해서 투입)
// ══════════════════════════════════════════════

class _BenchPanel extends StatelessWidget {
  const _BenchPanel({
    required this.bench,
    required this.currentQuarter,
    required this.onChipTap,
  });

  final List<_LineupMember> bench;
  final int currentQuarter;
  final ValueChanged<_LineupMember> onChipTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Text(
                'Q${currentQuarter + 1} 벤치',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${bench.length}명',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const Spacer(),
              Text(
                '탭해서 투입',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 60,
          child: bench.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '벤치가 비어있어요',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  itemCount: bench.length,
                  separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (_, i) => _BenchChip(
                    member: bench[i],
                    onTap: () => onChipTap(bench[i]),
                  ),
                ),
        ),
      ],
    );
  }
}

class _BenchChip extends StatelessWidget {
  const _BenchChip({required this.member, required this.onTap});
  final _LineupMember member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 52,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipOval(
                  child: Image.asset(
                    member.avatarPath,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              member.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 멤버 선택 시트 (슬롯 탭 시)
// ══════════════════════════════════════════════

class _MemberPickerSheet extends StatelessWidget {
  const _MemberPickerSheet({
    required this.targetPosition,
    required this.attendees,
    required this.usedMemberIds,
    required this.currentMember,
    required this.playCountById,
  });

  final String targetPosition;
  final List<_LineupMember> attendees;
  final Set<String> usedMemberIds;
  final _LineupMember? currentMember;
  final Map<String, int> playCountById;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final sheetHeight = MediaQuery.of(context).size.height * 0.7;

    final sorted = [...attendees]..sort((a, b) {
      final aIsTarget = a.position == targetPosition;
      final bIsTarget = b.position == targetPosition;
      if (aIsTarget && !bIsTarget) return -1;
      if (!aIsTarget && bIsTarget) return 1;
      final countDiff =
          (playCountById[a.id] ?? 0).compareTo(playCountById[b.id] ?? 0);
      if (countDiff != 0) return countDiff;
      return a.number.compareTo(b.number);
    });

    return Container(
      height: sheetHeight,
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.only(
            topLeft: SmoothRadius(cornerRadius: 24, cornerSmoothing: 1.0),
            topRight: SmoothRadius(cornerRadius: 24, cornerSmoothing: 1.0),
          ),
        ),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.iconInactive,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.base, AppSpacing.xl, AppSpacing.base,
            ),
            child: Row(
              children: [
                Text(
                  '선수 선택',
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3,
                  ),
                  decoration: ShapeDecoration(
                    color: AppColors.surfaceLight,
                    shape: SmoothRectangleBorder(
                      borderRadius: AppRadius.smoothXs,
                    ),
                  ),
                  child: Text(
                    targetPosition,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: sorted.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.xs),
              itemBuilder: (_, i) {
                final member = sorted[i];
                final isUsedInThisQuarter = usedMemberIds.contains(member.id);
                final isCurrent = currentMember?.id == member.id;
                final isSamePosition = member.position == targetPosition;
                final count = playCountById[member.id] ?? 0;
                return _MemberRow(
                  member: member,
                  isUsedInThisQuarter: isUsedInThisQuarter,
                  isCurrent: isCurrent,
                  isSamePosition: isSamePosition,
                  playCount: count,
                  onTap: () => Navigator.of(context).pop(member),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.member,
    required this.isUsedInThisQuarter,
    required this.isCurrent,
    required this.isSamePosition,
    required this.playCount,
    required this.onTap,
  });

  final _LineupMember member;
  final bool isUsedInThisQuarter;
  final bool isCurrent;
  final bool isSamePosition;
  final int playCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dim = isUsedInThisQuarter && !isCurrent;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: ShapeDecoration(
          color: isCurrent ? AppColors.surfaceLight : Colors.transparent,
          shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothSm),
        ),
        child: Row(
          children: [
            Opacity(
              opacity: dim ? 0.4 : 1.0,
              child: ClipOval(
                child: Image.asset(
                  member.avatarPath,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Row(
                children: [
                  Text(
                    member.name,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: dim
                          ? AppColors.textTertiary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '#${member.number}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6, vertical: 2,
              ),
              decoration: ShapeDecoration(
                color: _playCountBg(playCount),
                shape: SmoothRectangleBorder(
                  borderRadius: AppRadius.smoothXs,
                ),
              ),
              child: Text(
                '$playCount쿼터',
                style: AppTextStyles.caption.copyWith(
                  color: _playCountFg(playCount),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 3,
              ),
              decoration: ShapeDecoration(
                color: isSamePosition
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.surfaceLight,
                shape: SmoothRectangleBorder(
                  borderRadius: AppRadius.smoothXs,
                ),
              ),
              child: Text(
                member.position,
                style: AppTextStyles.caption.copyWith(
                  color: isSamePosition
                      ? AppColors.primary
                      : AppColors.textTertiary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (isCurrent) ...[
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: AppColors.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _playCountBg(int count) {
    if (count < 2 || count > 3) {
      return _warnColor.withValues(alpha: 0.12);
    }
    return AppColors.surfaceLight;
  }

  Color _playCountFg(int count) {
    if (count < 2 || count > 3) return _warnColor;
    return AppColors.textSecondary;
  }
}
