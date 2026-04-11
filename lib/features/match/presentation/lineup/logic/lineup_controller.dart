import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/lineup_dummy_data.dart';
import '../models/lineup_models.dart';
import 'auto_distributor.dart';

part 'lineup_controller.g.dart';

/// 라인업 빌더의 상태/액션을 모두 보유하는 컨트롤러.
///
/// View(Widget)는 이 컨트롤러의 메서드만 호출하면 되며,
/// 모든 상태 갱신은 immutable copyWith로 처리한다.
///
/// keepAlive=true: 빌더에서 편집한 라인업이 공유 화면/경기 상세에서도
/// 유지되도록 전역에 살아있게 함. 실제 데이터 연동 시 재검토.
@Riverpod(keepAlive: true)
class LineupController extends _$LineupController {
  @override
  LineupState build() {
    final initialQuarters = List.generate(
      4,
      (_) => QuarterLineup.empty(0),
    );
    return LineupState(
      roster: dummyRoster,
      quarters: initialQuarters,
      currentQuarter: 0,
    );
  }

  /// 사용 가능한 포메이션 (외부 접근용).
  List<Formation> get formations => dummyFormations;

  // ══════════════════════════════════════════════
  // 쿼터 / 포메이션 컨트롤
  // ══════════════════════════════════════════════

  void setCurrentQuarter(int quarter) {
    if (quarter < 0 || quarter >= state.quarters.length) return;
    if (state.currentQuarter == quarter) return;
    state = state.copyWith(currentQuarter: quarter);
  }

  /// 현재 쿼터의 포메이션만 변경. 기존 멤버는 best-effort 보존.
  void setFormationForCurrentQuarter(int formationIndex) {
    if (formationIndex < 0 || formationIndex >= dummyFormations.length) return;
    final q = state.quarters[state.currentQuarter];
    if (q.formationIndex == formationIndex) return;

    final oldMembers = q.slotToMemberId.values.toList();
    final newFormation = dummyFormations[formationIndex];
    final newMap = <int, String>{};
    final usedMembers = <String>{};

    // 1단계: 포지션 매칭 우선
    for (var slotIdx = 0; slotIdx < newFormation.slots.length; slotIdx++) {
      final neededPos = newFormation.slots[slotIdx].position;
      for (final memberId in oldMembers) {
        if (usedMembers.contains(memberId)) continue;
        final member = state.memberById(memberId);
        if (member == null) continue;
        if (member.preferredPosition == neededPos) {
          newMap[slotIdx] = memberId;
          usedMembers.add(memberId);
          break;
        }
      }
    }
    // 2단계: 남은 빈 슬롯에 남은 멤버 임의 배치
    for (var slotIdx = 0; slotIdx < newFormation.slots.length; slotIdx++) {
      if (newMap.containsKey(slotIdx)) continue;
      for (final memberId in oldMembers) {
        if (usedMembers.contains(memberId)) continue;
        newMap[slotIdx] = memberId;
        usedMembers.add(memberId);
        break;
      }
    }

    _replaceQuarter(
      state.currentQuarter,
      q.copyWith(formationIndex: formationIndex, slotToMemberId: newMap),
    );
  }

  /// 현재 쿼터의 포메이션을 모든 쿼터에 일괄 적용.
  /// 다른 쿼터의 멤버 배치는 best-effort 보존.
  void applyCurrentFormationToAllQuarters() {
    final targetIndex = state.quarters[state.currentQuarter].formationIndex;
    final newQuarters = <QuarterLineup>[];

    for (var qIdx = 0; qIdx < state.quarters.length; qIdx++) {
      final q = state.quarters[qIdx];
      if (q.formationIndex == targetIndex) {
        newQuarters.add(q);
        continue;
      }
      newQuarters.add(_remapForFormation(q, targetIndex));
    }

    state = state.copyWith(quarters: newQuarters);
  }

  QuarterLineup _remapForFormation(QuarterLineup q, int targetIndex) {
    final oldMembers = q.slotToMemberId.values.toList();
    final newFormation = dummyFormations[targetIndex];
    final newMap = <int, String>{};
    final used = <String>{};

    for (var slotIdx = 0; slotIdx < newFormation.slots.length; slotIdx++) {
      final neededPos = newFormation.slots[slotIdx].position;
      for (final id in oldMembers) {
        if (used.contains(id)) continue;
        final m = state.memberById(id);
        if (m == null) continue;
        if (m.preferredPosition == neededPos) {
          newMap[slotIdx] = id;
          used.add(id);
          break;
        }
      }
    }
    for (var slotIdx = 0; slotIdx < newFormation.slots.length; slotIdx++) {
      if (newMap.containsKey(slotIdx)) continue;
      for (final id in oldMembers) {
        if (used.contains(id)) continue;
        newMap[slotIdx] = id;
        used.add(id);
        break;
      }
    }
    return q.copyWith(formationIndex: targetIndex, slotToMemberId: newMap);
  }

  // ══════════════════════════════════════════════
  // 자동 분배
  // ══════════════════════════════════════════════

  void autoFillEmpty() {
    final updated = AutoDistributor.fillEmpty(
      roster: state.roster,
      formations: dummyFormations,
      currentQuarters: state.quarters,
    );
    state = state.copyWith(quarters: updated);
  }

  // ══════════════════════════════════════════════
  // 슬롯 조작 (드래그앤드롭의 핵심)
  // ══════════════════════════════════════════════

  /// 출석부 카드 탭 → 현재 쿼터 빈 슬롯에 자동 투입.
  /// 포지션 매칭 우선, 없으면 아무 빈 슬롯.
  /// 모두 차있으면 false 반환 (호출부에서 스낵바 표시).
  bool assignToCurrentQuarterAuto(String memberId) {
    final q = state.quarters[state.currentQuarter];
    if (q.containsMember(memberId)) return true; // 이미 있음

    final member = state.memberById(memberId);
    if (member == null) return false;

    final formation = dummyFormations[q.formationIndex];
    final newMap = Map<int, String>.from(q.slotToMemberId);

    // 1순위: 포지션 매칭 빈 슬롯
    for (var i = 0; i < formation.slots.length; i++) {
      if (newMap.containsKey(i)) continue;
      if (formation.slots[i].position == member.preferredPosition) {
        newMap[i] = memberId;
        _replaceQuarter(state.currentQuarter, q.copyWith(slotToMemberId: newMap));
        return true;
      }
    }
    // 2순위: 아무 빈 슬롯
    for (var i = 0; i < formation.slots.length; i++) {
      if (newMap.containsKey(i)) continue;
      newMap[i] = memberId;
      _replaceQuarter(state.currentQuarter, q.copyWith(slotToMemberId: newMap));
      return true;
    }
    return false; // 모두 참
  }

  /// 드래그앤드롭으로 특정 슬롯에 멤버 배치.
  ///
  /// 케이스:
  /// - 같은 쿼터 다른 슬롯에서 드래그됨 → 스왑/이동
  /// - 다른 곳(벤치/다른 쿼터)에서 드래그됨 → 그 자리 차지 (기존자는 벤치행)
  void placeAtSlot(String memberId, int slotIndex) {
    final qIdx = state.currentQuarter;
    final q = state.quarters[qIdx];
    final member = state.memberById(memberId);
    if (member == null) return;

    final newMap = Map<int, String>.from(q.slotToMemberId);

    // 드래그한 멤버가 현재 쿼터에 이미 있는지
    int? sourceSlot;
    newMap.forEach((idx, id) {
      if (id == memberId) sourceSlot = idx;
    });

    if (sourceSlot == slotIndex) return; // noop

    if (sourceSlot != null) {
      // 같은 쿼터 안에서 이동/스왑
      final occupant = newMap[slotIndex];
      if (occupant != null) {
        newMap[sourceSlot!] = occupant; // 스왑
      } else {
        newMap.remove(sourceSlot!); // 빈자리로 이동
      }
      newMap[slotIndex] = memberId;
    } else {
      // 외부에서 들어옴 → 자리 차지 (기존자 방출)
      newMap[slotIndex] = memberId;
    }

    _replaceQuarter(qIdx, q.copyWith(slotToMemberId: newMap));
  }

  /// 슬롯에서 멤버 제거 (현재 쿼터).
  void removeFromSlot(int slotIndex) {
    final qIdx = state.currentQuarter;
    final q = state.quarters[qIdx];
    if (!q.slotToMemberId.containsKey(slotIndex)) return;
    final newMap = Map<int, String>.from(q.slotToMemberId)..remove(slotIndex);
    _replaceQuarter(qIdx, q.copyWith(slotToMemberId: newMap));
  }

  /// 현재 쿼터에서 특정 멤버 제거 (드래그→출석부 케이스).
  void removeMemberFromCurrentQuarter(String memberId) {
    final qIdx = state.currentQuarter;
    final q = state.quarters[qIdx];
    final newMap = Map<int, String>.from(q.slotToMemberId)
      ..removeWhere((_, id) => id == memberId);
    _replaceQuarter(qIdx, q.copyWith(slotToMemberId: newMap));
  }

  // ══════════════════════════════════════════════
  // 용병
  // ══════════════════════════════════════════════

  /// 용병 추가. 추가 즉시 명단에 등장.
  /// [autoAssignToCurrent]가 true면 현재 쿼터에 즉시 투입 시도.
  void addMercenary({
    required String name,
    required String position,
    bool autoAssignToCurrent = true,
  }) {
    final mercCount =
        state.roster.where((m) => m.isMercenary).length;
    final id = 'mc-${DateTime.now().millisecondsSinceEpoch}-$mercCount';
    final displayName = name.trim().isEmpty ? '용병 ${mercCount + 1}' : name.trim();

    final newMember = LineupMember(
      id: id,
      name: displayName,
      preferredPosition: position,
      isMercenary: true,
    );

    state = state.copyWith(roster: [...state.roster, newMember]);

    if (autoAssignToCurrent) {
      assignToCurrentQuarterAuto(id);
    }
  }

  // ══════════════════════════════════════════════
  // 쿼터 단위 조작
  // ══════════════════════════════════════════════

  /// from 쿼터를 to 쿼터에 그대로 복사 (포메이션 + 슬롯 매핑 모두).
  void copyQuarter({required int from, required int to}) {
    if (from == to) return;
    if (from < 0 || from >= state.quarters.length) return;
    if (to < 0 || to >= state.quarters.length) return;
    final source = state.quarters[from];
    final list = [...state.quarters];
    list[to] = QuarterLineup(
      formationIndex: source.formationIndex,
      slotToMemberId: Map<int, String>.from(source.slotToMemberId),
    );
    state = state.copyWith(quarters: list);
  }

  /// 특정 쿼터의 슬롯 매핑을 비움 (포메이션은 유지).
  void clearQuarter(int quarter) {
    if (quarter < 0 || quarter >= state.quarters.length) return;
    final q = state.quarters[quarter];
    _replaceQuarter(quarter, q.copyWith(slotToMemberId: const {}));
  }

  // ── private helpers ──

  void _replaceQuarter(int quarter, QuarterLineup updated) {
    final list = [...state.quarters];
    list[quarter] = updated;
    state = state.copyWith(quarters: list);
  }
}
