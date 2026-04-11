import '../models/lineup_models.dart';

/// 4쿼터 라인업 자동 분배 알고리즘.
///
/// 기본 원칙:
/// 1. 한 선수 한 쿼터에 두 번 들어가지 않음
/// 2. 가능한 한 모든 멤버 최소 2쿼터 출전 (균등 분배 우선)
/// 3. 한 선수 최대 3쿼터까지 우선, 부족하면 4쿼터까지 허용
///
/// 4-layer 탐색:
///   L1: 포지션 일치 + 3쿼터 미만
///   L2: 포지션 무관 + 3쿼터 미만
///   L3: 포지션 일치 + 4쿼터 미만
///   L4: 포지션 무관 + 4쿼터 미만
///
/// 정렬 키:
///   1순위: 출전 쿼터 수 적은 순 (균등)
///   2순위: 등번호 작은 순 (안정적 ordering)
class AutoDistributor {
  AutoDistributor._();

  /// 빈 슬롯만 채운다 (기존 배치 보존).
  ///
  /// 사용 시점: "[자동] 탭" — 일부 수동 배치 후 나머지 자동.
  static List<QuarterLineup> fillEmpty({
    required List<LineupMember> roster,
    required List<Formation> formations,
    required List<QuarterLineup> currentQuarters,
  }) {
    final playCount = <String, int>{for (final m in roster) m.id: 0};
    for (final q in currentQuarters) {
      for (final id in q.memberIds) {
        playCount[id] = (playCount[id] ?? 0) + 1;
      }
    }

    final newQuarters = <QuarterLineup>[];
    for (final q in currentQuarters) {
      final formation = formations[q.formationIndex];
      final slotMap = Map<int, String>.from(q.slotToMemberId);
      final usedInQuarter = slotMap.values.toSet();

      for (var slotIdx = 0; slotIdx < formation.slots.length; slotIdx++) {
        if (slotMap.containsKey(slotIdx)) continue;
        final neededPos = formation.slots[slotIdx].position;
        final selected = _pick4Layers(
          roster: roster,
          neededPos: neededPos,
          usedInQuarter: usedInQuarter,
          playCount: playCount,
        );
        if (selected != null) {
          slotMap[slotIdx] = selected.id;
          usedInQuarter.add(selected.id);
          playCount[selected.id] = (playCount[selected.id] ?? 0) + 1;
        }
      }

      newQuarters.add(q.copyWith(slotToMemberId: slotMap));
    }

    return newQuarters;
  }

  /// 전체 재분배 (기존 배치 모두 폐기).
  static List<QuarterLineup> distributeAll({
    required List<LineupMember> roster,
    required List<Formation> formations,
    required List<QuarterLineup> currentQuarters,
  }) {
    final playCount = <String, int>{for (final m in roster) m.id: 0};
    final newQuarters = <QuarterLineup>[];

    for (final q in currentQuarters) {
      final formation = formations[q.formationIndex];
      final slotMap = <int, String>{};
      final usedInQuarter = <String>{};

      for (var slotIdx = 0; slotIdx < formation.slots.length; slotIdx++) {
        final neededPos = formation.slots[slotIdx].position;
        final selected = _pick4Layers(
          roster: roster,
          neededPos: neededPos,
          usedInQuarter: usedInQuarter,
          playCount: playCount,
        );
        if (selected != null) {
          slotMap[slotIdx] = selected.id;
          usedInQuarter.add(selected.id);
          playCount[selected.id] = (playCount[selected.id] ?? 0) + 1;
        }
      }

      newQuarters.add(QuarterLineup(
        formationIndex: q.formationIndex,
        slotToMemberId: slotMap,
      ));
    }

    return newQuarters;
  }

  // ── private ──

  static LineupMember? _pick4Layers({
    required List<LineupMember> roster,
    required String neededPos,
    required Set<String> usedInQuarter,
    required Map<String, int> playCount,
  }) {
    LineupMember? s = _pickBest(
      roster: roster,
      position: neededPos,
      usedInQuarter: usedInQuarter,
      playCount: playCount,
      maxPlayCount: 3,
    );
    s ??= _pickBest(
      roster: roster,
      position: null,
      usedInQuarter: usedInQuarter,
      playCount: playCount,
      maxPlayCount: 3,
    );
    s ??= _pickBest(
      roster: roster,
      position: neededPos,
      usedInQuarter: usedInQuarter,
      playCount: playCount,
      maxPlayCount: 4,
    );
    s ??= _pickBest(
      roster: roster,
      position: null,
      usedInQuarter: usedInQuarter,
      playCount: playCount,
      maxPlayCount: 4,
    );
    return s;
  }

  static LineupMember? _pickBest({
    required List<LineupMember> roster,
    required String? position,
    required Set<String> usedInQuarter,
    required Map<String, int> playCount,
    required int maxPlayCount,
  }) {
    final candidates = roster.where((m) {
      if (position != null && m.preferredPosition != position) return false;
      if (usedInQuarter.contains(m.id)) return false;
      if ((playCount[m.id] ?? 0) >= maxPlayCount) return false;
      return true;
    }).toList();
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) {
      final diff = (playCount[a.id] ?? 0).compareTo(playCount[b.id] ?? 0);
      if (diff != 0) return diff;
      final na = a.number ?? 999;
      final nb = b.number ?? 999;
      return na.compareTo(nb);
    });
    return candidates.first;
  }
}
