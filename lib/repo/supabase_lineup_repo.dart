import 'package:supabase_flutter/supabase_flutter.dart';

import 'lineup_repo.dart';

/// LineupRepo의 Supabase 구현체.
class SupabaseLineupRepo implements LineupRepo {
  final SupabaseClient _client;

  SupabaseLineupRepo(this._client);

  @override
  Future<Map<int, ({String formationName, Map<int, String> slotToPlayerId})>>
      getByMatch(String matchId) async {
    final lineups = await _client
        .from('quarter_lineups')
        .select()
        .eq('match_id', matchId)
        .order('quarter');

    final slots = await _client
        .from('slot_assignments')
        .select()
        .eq('match_id', matchId);

    // 슬롯을 쿼터별로 그룹핑
    final slotsByQuarter = <int, Map<int, String>>{};
    for (final s in slots) {
      final quarter = s['quarter'] as int;
      slotsByQuarter
          .putIfAbsent(quarter, () => {})
          .putIfAbsent(s['slot_index'] as int, () => s['player_id'] as String);
    }

    final result =
        <int, ({String formationName, Map<int, String> slotToPlayerId})>{};
    for (final row in lineups) {
      final quarter = row['quarter'] as int;
      result[quarter] = (
        formationName: row['formation_name'] as String,
        slotToPlayerId: slotsByQuarter[quarter] ?? {},
      );
    }

    return result;
  }

  @override
  Future<void> save({
    required String matchId,
    required Map<int, ({String formationName, Map<int, String> slotToPlayerId})>
        quarters,
  }) async {
    // 기존 데이터 삭제 후 재삽입 (트랜잭션 대용)
    await _client
        .from('slot_assignments')
        .delete()
        .eq('match_id', matchId);
    await _client
        .from('quarter_lineups')
        .delete()
        .eq('match_id', matchId);

    // 쿼터 라인업 삽입
    final lineupRows = quarters.entries.map((e) => {
          'match_id': matchId,
          'quarter': e.key,
          'formation_name': e.value.formationName,
        });
    if (lineupRows.isNotEmpty) {
      await _client.from('quarter_lineups').insert(lineupRows.toList());
    }

    // 슬롯 배정 삽입
    final slotRows = <Map<String, dynamic>>[];
    for (final entry in quarters.entries) {
      for (final slot in entry.value.slotToPlayerId.entries) {
        slotRows.add({
          'match_id': matchId,
          'quarter': entry.key,
          'slot_index': slot.key,
          'player_id': slot.value,
        });
      }
    }
    if (slotRows.isNotEmpty) {
      await _client.from('slot_assignments').insert(slotRows);
    }
  }

  @override
  Future<void> clearQuarter({
    required String matchId,
    required int quarter,
  }) async {
    await _client
        .from('slot_assignments')
        .delete()
        .eq('match_id', matchId)
        .eq('quarter', quarter);
    await _client
        .from('quarter_lineups')
        .delete()
        .eq('match_id', matchId)
        .eq('quarter', quarter);
  }
}
