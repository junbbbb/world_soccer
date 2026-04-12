import '../repo/lineup_repo.dart';
import '../repo/player_repo.dart';
import '../types/enums.dart';
import '../types/lineup.dart';
import '../types/player.dart';

/// 라인업 비즈니스 로직.
class LineupService {
  final LineupRepo lineupRepo;
  final PlayerRepo playerRepo;

  LineupService({required this.lineupRepo, required this.playerRepo});

  /// 전체 재분배 (기존 배치 모두 폐기).
  List<QuarterLineup> distributeAll({
    required List<LineupMember> roster,
    required List<Formation> formations,
    required List<QuarterLineup> currentQuarters,
  }) {
    final playCount = <String, int>{for (final m in roster) m.id: 0};
    final byPosition = _groupByPosition(roster);
    final newQuarters = <QuarterLineup>[];

    for (final q in currentQuarters) {
      final formation = formations[q.formationIndex];
      final slotMap = <int, String>{};
      final usedInQuarter = <String>{};

      for (var slotIdx = 0; slotIdx < formation.slots.length; slotIdx++) {
        final neededPos = formation.slots[slotIdx].position;
        final selected = _pick4Layers(
          roster: roster,
          byPosition: byPosition,
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

  /// 빈 슬롯만 채운다 (기존 배치 보존).
  List<QuarterLineup> fillEmpty({
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

    final byPosition = _groupByPosition(roster);
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
          byPosition: byPosition,
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

  /// 용병 추가.
  List<LineupMember> addMercenary({
    required List<LineupMember> roster,
    required String name,
    required PositionGroup preferredPosition,
  }) {
    final effectiveName =
        name.isEmpty ? '용병 ${roster.where((m) => m.isMercenary).length + 1}' : name;
    final id = 'merc_${DateTime.now().millisecondsSinceEpoch}';
    final mercenary = LineupMember(
      id: id,
      name: effectiveName,
      preferredPosition: preferredPosition,
      isMercenary: true,
    );
    return [...roster, mercenary];
  }

  /// 라인업 저장 → Repo 위임.
  Future<void> saveLineup({
    required String matchId,
    required Map<int, ({String formationName, Map<int, String> slotToPlayerId})>
        quarters,
  }) {
    return lineupRepo.save(matchId: matchId, quarters: quarters);
  }

  // ── private ──

  /// 포지션별 그룹핑 (1회).
  Map<PositionGroup, List<LineupMember>> _groupByPosition(
      List<LineupMember> roster) {
    final map = <PositionGroup, List<LineupMember>>{};
    for (final m in roster) {
      map.putIfAbsent(m.preferredPosition, () => []).add(m);
    }
    return map;
  }

  /// 4-Layer 탐색.
  LineupMember? _pick4Layers({
    required List<LineupMember> roster,
    required Map<PositionGroup, List<LineupMember>> byPosition,
    required PositionGroup neededPos,
    required Set<String> usedInQuarter,
    required Map<String, int> playCount,
  }) {
    return _pickBest(byPosition[neededPos], usedInQuarter, playCount, 3) ??
        _pickBest(roster, usedInQuarter, playCount, 3) ??
        _pickBest(byPosition[neededPos], usedInQuarter, playCount, 4) ??
        _pickBest(roster, usedInQuarter, playCount, 4);
  }

  /// Single-pass min-scan (할당 없음).
  LineupMember? _pickBest(
    List<LineupMember>? candidates,
    Set<String> usedInQuarter,
    Map<String, int> playCount,
    int maxPlayCount,
  ) {
    if (candidates == null || candidates.isEmpty) return null;
    LineupMember? best;
    var bestCount = maxPlayCount;
    var bestNumber = 1000;

    for (final m in candidates) {
      if (usedInQuarter.contains(m.id)) continue;
      final count = playCount[m.id] ?? 0;
      if (count >= maxPlayCount) continue;
      final num = m.number ?? 999;
      if (best == null ||
          count < bestCount ||
          (count == bestCount && num < bestNumber)) {
        best = m;
        bestCount = count;
        bestNumber = num;
      }
    }
    return best;
  }
}
