/// 라인업 모델.

import 'enums.dart';
import 'player.dart';

/// 피치 위 슬롯 좌표.
class SlotPosition {
  final double x; // 0~1 가로 비율
  final double y; // 0~1 세로 비율 (1이 우리편 골대)
  final PositionGroup position;

  const SlotPosition(this.x, this.y, this.position);
}

/// 포메이션 정의.
class Formation {
  final String name;
  final List<SlotPosition> slots;

  const Formation({required this.name, required this.slots});
}

/// 쿼터별 라인업.
class QuarterLineup {
  final int formationIndex; // formations 리스트 인덱스
  final Map<int, String> slotToMemberId; // slot index → member id

  QuarterLineup({
    required this.formationIndex,
    required this.slotToMemberId,
  });

  factory QuarterLineup.empty(int formationIndex) {
    return QuarterLineup(
      formationIndex: formationIndex,
      slotToMemberId: const {},
    );
  }

  QuarterLineup copyWith({
    int? formationIndex,
    Map<int, String>? slotToMemberId,
  }) {
    return QuarterLineup(
      formationIndex: formationIndex ?? this.formationIndex,
      slotToMemberId: slotToMemberId ?? this.slotToMemberId,
    );
  }

  late final Set<String> memberIds = slotToMemberId.values.toSet();

  bool containsMember(String memberId) => memberIds.contains(memberId);
}

/// 라인업 전체 상태 (4쿼터).
class LineupState {
  final List<LineupMember> roster;
  final List<QuarterLineup> quarters; // 4개 고정
  final int currentQuarter;

  LineupState({
    required this.roster,
    required this.quarters,
    required this.currentQuarter,
  });

  LineupState copyWith({
    List<LineupMember>? roster,
    List<QuarterLineup>? quarters,
    int? currentQuarter,
  }) {
    return LineupState(
      roster: roster ?? this.roster,
      quarters: quarters ?? this.quarters,
      currentQuarter: currentQuarter ?? this.currentQuarter,
    );
  }

  // ── 파생 셀렉터 (1회 계산) ──

  late final Map<String, int> playCountByMemberId = _computePlayCounts();

  Map<String, int> _computePlayCounts() {
    final map = <String, int>{for (final m in roster) m.id: 0};
    for (final q in quarters) {
      for (final id in q.memberIds) {
        map[id] = (map[id] ?? 0) + 1;
      }
    }
    return map;
  }

  late final int unassignedCount =
      roster.where((m) => (playCountByMemberId[m.id] ?? 0) == 0).length;

  late final int underAssignedCount =
      roster.where((m) => (playCountByMemberId[m.id] ?? 0) == 1).length;

  late final int fullPlayCount =
      roster.where((m) => (playCountByMemberId[m.id] ?? 0) == 4).length;

  int emptySlotCountFor(List<Formation> formations) {
    var total = 0;
    for (final q in quarters) {
      final slotCount = formations[q.formationIndex].slots.length;
      total += slotCount - q.slotToMemberId.length;
    }
    return total;
  }

  late final Map<String, LineupMember> _memberIndex = {
    for (final m in roster) m.id: m,
  };

  LineupMember? memberById(String id) => _memberIndex[id];
}
