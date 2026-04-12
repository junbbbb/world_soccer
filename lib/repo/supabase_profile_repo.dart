import 'package:supabase_flutter/supabase_flutter.dart';

import '../types/enums.dart';
import 'profile_repo.dart';

/// ProfileRepo의 Supabase 구현체.
class SupabaseProfileRepo implements ProfileRepo {
  final SupabaseClient _client;

  SupabaseProfileRepo(this._client);

  @override
  Future<void> update({
    required String playerId,
    String? name,
    int? number,
    String? avatarUrl,
    List<Position>? preferredPositions,
    PreferredFoot? preferredFoot,
    int? height,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (number != null) updates['number'] = number;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (preferredPositions != null) {
      updates['preferred_positions'] =
          preferredPositions.map((p) => p.label).toList();
    }
    if (preferredFoot != null) {
      updates['preferred_foot'] = preferredFoot.label;
    }
    if (height != null) updates['height'] = height;

    if (updates.isNotEmpty) {
      await _client.from('players').update(updates).eq('id', playerId);
    }
  }
}
