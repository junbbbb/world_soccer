import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../types/enums.dart';
import 'profile_repo.dart';

/// ProfileRepo의 Supabase 구현체.
class SupabaseProfileRepo implements ProfileRepo {
  final SupabaseClient _client;

  SupabaseProfileRepo(this._client);

  @override
  Future<String> uploadAvatar({
    required String playerId,
    required List<int> bytes,
    required String extension,
  }) async {
    final ext = extension.toLowerCase().replaceAll('.', '');
    final ts = DateTime.now().millisecondsSinceEpoch;
    final path = '$playerId/avatar_$ts.$ext';
    final contentType = switch (ext) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
    await _client.storage.from('player-avatars').uploadBinary(
          path,
          Uint8List.fromList(bytes),
          fileOptions: FileOptions(
            contentType: contentType,
            upsert: true,
          ),
        );
    return _client.storage.from('player-avatars').getPublicUrl(path);
  }

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
      final result = await _client
          .from('players')
          .update(updates)
          .eq('id', playerId)
          .select('id');
      if (result.isEmpty) {
        throw StateError('프로필 수정 실패: 권한이 없거나 존재하지 않는 플레이어');
      }
    }
  }
}
