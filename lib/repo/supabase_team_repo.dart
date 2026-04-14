import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../types/enums.dart';
import '../types/team.dart';
import 'team_repo.dart';

/// TeamRepo의 Supabase 구현체.
class SupabaseTeamRepo implements TeamRepo {
  final SupabaseClient _client;

  SupabaseTeamRepo(this._client);

  @override
  Future<List<Team>> getMyTeams(String playerId) async {
    final data = await _client
        .from('team_members')
        .select('teams(*)')
        .eq('player_id', playerId);

    return data
        .map((row) => _teamFromRow(row['teams'] as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Team> getById(String teamId) async {
    final data =
        await _client.from('teams').select().eq('id', teamId).single();
    return _teamFromRow(data);
  }

  @override
  Future<List<TeamMember>> getMembers(String teamId) async {
    final data = await _client
        .from('team_members')
        .select('*, players(name, avatar_url, number, preferred_positions)')
        .eq('team_id', teamId)
        .order('joined_at');

    return data.map((row) {
      final player = row['players'] as Map<String, dynamic>?;
      final positions =
          (player?['preferred_positions'] as List<dynamic>?)?.cast<String>();

      return TeamMember(
        teamId: row['team_id'] as String,
        playerId: row['player_id'] as String,
        role: switch (row['role'] as String) {
          'admin' => TeamRole.admin,
          'mercenary' => TeamRole.mercenary,
          _ => TeamRole.member,
        },
        joinedAt: DateTime.parse(row['joined_at'] as String),
        playerName: player?['name'] as String?,
        playerAvatarUrl: player?['avatar_url'] as String?,
        playerNumber: player?['number'] as int?,
        playerPosition: positions?.isNotEmpty == true ? positions!.first : null,
      );
    }).toList();
  }

  @override
  Future<Team> create({
    required String name,
    String? logoUrl,
    String? logoColor,
    String? description,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final data = await _client
        .from('teams')
        .insert({
          'name': name,
          'logo_url': logoUrl,
          'logo_color': logoColor,
          'description': description,
        })
        .select()
        .single();

    final team = _teamFromRow(data);

    // 생성자를 admin으로 자동 등록
    await _client.from('team_members').insert({
      'team_id': team.id,
      'player_id': userId,
      'role': 'admin',
    });

    return team;
  }

  @override
  Future<Team> updateInfo({
    required String teamId,
    String? name,
    String? logoUrl,
    String? logoColor,
    String? description,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (logoUrl != null) updates['logo_url'] = logoUrl;
    if (logoColor != null) updates['logo_color'] = logoColor;
    if (description != null) updates['description'] = description;
    if (updates.isEmpty) {
      return getById(teamId);
    }
    final data = await _client
        .from('teams')
        .update(updates)
        .eq('id', teamId)
        .select()
        .single();
    return _teamFromRow(data);
  }

  @override
  Future<void> join({
    required String teamId,
    required String playerId,
  }) async {
    await _client.from('team_members').insert({
      'team_id': teamId,
      'player_id': playerId,
      'role': 'member',
    });
  }

  @override
  Future<void> leave({
    required String teamId,
    required String playerId,
  }) async {
    final removed = await _client
        .from('team_members')
        .delete()
        .eq('team_id', teamId)
        .eq('player_id', playerId)
        .select('team_id');
    if (removed.isEmpty) {
      throw StateError('탈퇴 실패: 권한이 없거나 소속되지 않은 팀');
    }
  }

  @override
  Future<String> uploadLogo({
    required String teamId,
    required List<int> bytes,
    required String extension,
  }) async {
    final ext = extension.toLowerCase().replaceAll('.', '');
    final ts = DateTime.now().millisecondsSinceEpoch;
    final path = '$teamId/logo_$ts.$ext';
    final contentType = switch (ext) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
    await _client.storage.from('team-logos').uploadBinary(
          path,
          Uint8List.fromList(bytes),
          fileOptions: FileOptions(
            contentType: contentType,
            upsert: true,
          ),
        );
    return _client.storage.from('team-logos').getPublicUrl(path);
  }

  @override
  Future<TeamStats> getStats(String teamId) async {
    final data = await _client
        .from('matches')
        .select('our_score, opponent_score')
        .eq('team_id', teamId)
        .eq('status', 'completed');

    var wins = 0, draws = 0, losses = 0, goalsFor = 0, goalsAgainst = 0;
    var cleanSheets = 0;

    for (final row in data) {
      final our = row['our_score'] as int;
      final opp = row['opponent_score'] as int;
      goalsFor += our;
      goalsAgainst += opp;
      if (our > opp) {
        wins++;
      } else if (our == opp) {
        draws++;
      } else {
        losses++;
      }
      if (opp == 0) cleanSheets++;
    }

    return TeamStats(
      totalMatches: data.length,
      wins: wins,
      draws: draws,
      losses: losses,
      goalsFor: goalsFor,
      goalsAgainst: goalsAgainst,
      cleanSheets: cleanSheets,
    );
  }

  @override
  Future<String> createInviteCode({
    required String teamId,
    String role = 'member',
  }) async {
    final code = _generateCode();
    final userId = _client.auth.currentUser!.id;

    await _client.from('team_invites').insert({
      'team_id': teamId,
      'invite_code': code,
      'created_by': userId,
      'role': role,
    });

    return code;
  }

  @override
  Future<Map<String, dynamic>> joinByInviteCode(String inviteCode) async {
    final response = await _client.rpc(
      'join_team_by_invite',
      params: {'p_invite_code': inviteCode},
    );
    return response as Map<String, dynamic>;
  }

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // 혼동 문자 제외 (0/O, 1/I)
    final random = DateTime.now().millisecondsSinceEpoch;
    final buffer = StringBuffer();
    for (var i = 0; i < 6; i++) {
      buffer.write(chars[(random ~/ (i + 1) * 7 + i * 13) % chars.length]);
    }
    return buffer.toString();
  }

  Team _teamFromRow(Map<String, dynamic> row) {
    return Team(
      id: row['id'] as String,
      name: row['name'] as String,
      logoUrl: row['logo_url'] as String?,
      logoColor: row['logo_color'] as String?,
      description: row['description'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}
