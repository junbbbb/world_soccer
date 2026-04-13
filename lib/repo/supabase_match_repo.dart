import 'package:supabase_flutter/supabase_flutter.dart';

import '../types/enums.dart';
import '../types/match.dart';
import 'match_repo.dart';

/// MatchRepo의 Supabase 구현체.
class SupabaseMatchRepo implements MatchRepo {
  final SupabaseClient _client;

  SupabaseMatchRepo(this._client);

  @override
  Future<List<Match>> getByTeam(String teamId) async {
    final data = await _client
        .from('matches')
        .select()
        .eq('team_id', teamId)
        .order('date', ascending: false);

    return data.map(_fromRow).toList();
  }

  @override
  Future<Match> getById(String matchId) async {
    final data =
        await _client.from('matches').select().eq('id', matchId).single();
    return _fromRow(data);
  }

  @override
  Future<Match> create({
    required String teamId,
    required DateTime date,
    required String location,
    required String opponentName,
    String? opponentLogoUrl,
    int durationMinutes = 120,
  }) async {
    final data = await _client
        .from('matches')
        .insert({
          'team_id': teamId,
          'date': date.toIso8601String(),
          'location': location,
          'opponent_name': opponentName,
          'opponent_logo_url': opponentLogoUrl,
          'duration_minutes': durationMinutes,
        })
        .select()
        .single();
    return _fromRow(data);
  }

  @override
  Future<void> updateResult({
    required String matchId,
    required int ourScore,
    required int opponentScore,
  }) async {
    await _client.from('matches').update({
      'our_score': ourScore,
      'opponent_score': opponentScore,
      'status': 'completed',
    }).eq('id', matchId);
  }

  @override
  Future<void> updateInfo({
    required String matchId,
    DateTime? date,
    String? location,
    String? opponentName,
    int? durationMinutes,
  }) async {
    final updates = <String, dynamic>{};
    if (date != null) updates['date'] = date.toIso8601String();
    if (location != null) updates['location'] = location;
    if (opponentName != null) updates['opponent_name'] = opponentName;
    if (durationMinutes != null) updates['duration_minutes'] = durationMinutes;
    if (updates.isNotEmpty) {
      await _client.from('matches').update(updates).eq('id', matchId);
    }
  }

  @override
  Future<void> updateStatus({
    required String matchId,
    required String status,
  }) async {
    await _client.from('matches').update({
      'status': status,
    }).eq('id', matchId);
  }

  @override
  Future<List<Match>> getH2H({
    required String teamId,
    required String opponentName,
  }) async {
    final data = await _client
        .from('matches')
        .select()
        .eq('team_id', teamId)
        .eq('opponent_name', opponentName)
        .eq('status', 'completed')
        .order('date', ascending: false);

    return data.map(_fromRow).toList();
  }

  Match _fromRow(Map<String, dynamic> row) {
    return Match(
      id: row['id'] as String,
      teamId: row['team_id'] as String,
      date: DateTime.parse(row['date'] as String),
      durationMinutes: (row['duration_minutes'] as int?) ?? 90,
      location: row['location'] as String,
      opponentName: row['opponent_name'] as String,
      opponentLogoUrl: row['opponent_logo_url'] as String?,
      ourScore: row['our_score'] as int?,
      opponentScore: row['opponent_score'] as int?,
      status: switch (row['status'] as String?) {
        'completed' => MatchStatus.completed,
        'cancelled' => MatchStatus.cancelled,
        'early_ended' => MatchStatus.earlyEnded,
        _ => MatchStatus.upcoming,
      },
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}
