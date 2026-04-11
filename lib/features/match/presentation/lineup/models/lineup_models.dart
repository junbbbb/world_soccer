// 라인업 빌더에서 사용하는 모델들.
//
// 모두 immutable. 상태 변경은 LineupController가 copyWith로 처리.

// ══════════════════════════════════════════════
// LineupMember
// ══════════════════════════════════════════════

class LineupMember {
  final String id;
  final String name;
  final String preferredPosition; // 'GK' | 'DF' | 'MF' | 'FW'
  final int? number; // 용병은 null 허용
  final String? avatarPath; // 용병/없으면 null → 이니셜 표시
  final bool isMercenary;

  const LineupMember({
    required this.id,
    required this.name,
    required this.preferredPosition,
    this.number,
    this.avatarPath,
    this.isMercenary = false,
  });

  LineupMember copyWith({
    String? id,
    String? name,
    String? preferredPosition,
    int? number,
    String? avatarPath,
    bool? isMercenary,
  }) {
    return LineupMember(
      id: id ?? this.id,
      name: name ?? this.name,
      preferredPosition: preferredPosition ?? this.preferredPosition,
      number: number ?? this.number,
      avatarPath: avatarPath ?? this.avatarPath,
      isMercenary: isMercenary ?? this.isMercenary,
    );
  }

  String get initials {
    if (name.isEmpty) return '?';
    return name.substring(0, 1);
  }
}

// ══════════════════════════════════════════════
// Formation / SlotPosition
// ══════════════════════════════════════════════

class SlotPosition {
  final double x; // 0~1 가로 비율
  final double y; // 0~1 세로 비율 (1이 우리편 골대)
  final String position; // 'GK' | 'DF' | 'MF' | 'FW'

  const SlotPosition(this.x, this.y, this.position);
}

class Formation {
  final String name;
  final List<SlotPosition> slots;

  const Formation({required this.name, required this.slots});
}

// ══════════════════════════════════════════════
// QuarterLineup
// ══════════════════════════════════════════════

class QuarterLineup {
  final int formationIndex; // formations 리스트 인덱스
  final Map<int, String> slotToMemberId; // slot index → member id

  const QuarterLineup({
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

  /// 이 쿼터에 등록된 멤버 id 집합.
  Set<String> get memberIds => slotToMemberId.values.toSet();

  bool containsMember(String memberId) =>
      slotToMemberId.values.contains(memberId);
}

// ══════════════════════════════════════════════
// LineupState
// ══════════════════════════════════════════════

class LineupState {
  final List<LineupMember> roster; // 출석 후보 전체 (결석자/용병 포함)
  final List<QuarterLineup> quarters; // 4개 고정
  final int currentQuarter;

  const LineupState({
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

  // ── 파생 셀렉터 ──

  /// memberId → 출전 쿼터 수.
  Map<String, int> get playCountByMemberId {
    final map = <String, int>{for (final m in roster) m.id: 0};
    for (final q in quarters) {
      for (final id in q.memberIds) {
        map[id] = (map[id] ?? 0) + 1;
      }
    }
    return map;
  }

  /// 미배정 (출전쿼터 0) 멤버 수.
  int get unassignedCount {
    final counts = playCountByMemberId;
    return roster.where((m) => (counts[m.id] ?? 0) == 0).length;
  }

  /// 1쿼만 (부족) 멤버 수.
  int get underAssignedCount {
    final counts = playCountByMemberId;
    return roster.where((m) => (counts[m.id] ?? 0) == 1).length;
  }

  /// 풀출전(4쿼) 멤버 수.
  int get fullPlayCount {
    final counts = playCountByMemberId;
    return roster.where((m) => (counts[m.id] ?? 0) == 4).length;
  }

  /// 어느 쿼터든 빈 슬롯 합계 (현재 포메이션 기준).
  int emptySlotCountFor(List<Formation> formations) {
    var total = 0;
    for (final q in quarters) {
      final slotCount = formations[q.formationIndex].slots.length;
      total += slotCount - q.slotToMemberId.length;
    }
    return total;
  }

  LineupMember? memberById(String id) {
    for (final m in roster) {
      if (m.id == id) return m;
    }
    return null;
  }
}
