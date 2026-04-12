import 'package:supabase_flutter/supabase_flutter.dart';

import '../types/enums.dart';
import '../types/match.dart';
import '../types/player.dart';
import 'player_repo.dart';

/// PlayerRepo의 Supabase 구현체.
class SupabasePlayerRepo implements PlayerRepo {
  final SupabaseClient _client;

  SupabasePlayerRepo(this._client);

  @override
  Future<Player> getById(String playerId) async {
    final data =
        await _client.from('players').select().eq('id', playerId).single();
    return _playerFromRow(data);
  }

  @override
  Future<void> joinMatch({
    required String matchId,
    required String playerId,
    required List<Position> preferredPositions,
    required List<int> availableQuarters,
  }) async {
    await _client.from('match_participations').upsert({
      'match_id': matchId,
      'player_id': playerId,
      'preferred_positions': preferredPositions.map((p) => p.label).toList(),
      'available_quarters': availableQuarters,
    });
  }

  @override
  Future<void> leaveMatch({
    required String matchId,
    required String playerId,
  }) async {
    await _client
        .from('match_participations')
        .delete()
        .eq('match_id', matchId)
        .eq('player_id', playerId);
  }

  @override
  Future<List<MatchParticipation>> getParticipations(String matchId) async {
    final data = await _client
        .from('match_participations')
        .select('*, players(name, avatar_url, number)')
        .eq('match_id', matchId);

    return data.map((row) {
      final player = row['players'] as Map<String, dynamic>?;
      final posLabels = (row['preferred_positions'] as List<dynamic>?)
              ?.cast<String>() ??
          [];

      return MatchParticipation(
        matchId: row['match_id'] as String,
        playerId: row['player_id'] as String,
        preferredPositions: posLabels
            .map((label) => Position.values.firstWhere((p) => p.label == label,
                orElse: () => Position.cm))
            .toList(),
        availableQuarters:
            (row['available_quarters'] as List<dynamic>?)?.cast<int>() ?? [],
        playerName: player?['name'] as String?,
        playerAvatarUrl: player?['avatar_url'] as String?,
        playerNumber: player?['number'] as int?,
      );
    }).toList();
  }

  Player _playerFromRow(Map<String, dynamic> row) {
    final posLabels =
        (row['preferred_positions'] as List<dynamic>?)?.cast<String>() ?? [];

    return Player(
      id: row['id'] as String,
      name: row['name'] as String,
      number: row['number'] as int?,
      avatarUrl: row['avatar_url'] as String?,
      preferredPositions: posLabels
          .map((label) => Position.values.firstWhere((p) => p.label == label,
              orElse: () => Position.cm))
          .toList(),
      preferredFoot: _parseFoot(row['preferred_foot'] as String?),
      height: row['height'] as int?,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }

  PreferredFoot? _parseFoot(String? value) {
    if (value == null) return null;
    return PreferredFoot.values
        .cast<PreferredFoot?>()
        .firstWhere((f) => f!.label == value, orElse: () => null);
  }
}
