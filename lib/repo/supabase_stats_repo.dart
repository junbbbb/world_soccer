import 'package:supabase_flutter/supabase_flutter.dart';

import '../types/enums.dart';
import '../types/match.dart';
import '../types/profile.dart';
import 'stats_repo.dart';

/// StatsRepo의 Supabase 구현체.
class SupabaseStatsRepo implements StatsRepo {
  final SupabaseClient _client;

  SupabaseStatsRepo(this._client);

  @override
  Future<SeasonStats> getSeasonStats({
    required String playerId,
    required String teamId,
    required int year,
    required SeasonHalf half,
  }) async {
    final data = await _client
        .from('season_player_stats')
        .select()
        .eq('player_id', playerId)
        .eq('team_id', teamId)
        .eq('year', year)
        .eq('half', half.label)
        .maybeSingle();

    if (data == null) {
      return const SeasonStats(appearances: 0, goals: 0, assists: 0, mom: 0);
    }

    return SeasonStats(
      appearances: data['appearances'] as int,
      goals: data['goals'] as int,
      assists: data['assists'] as int,
      mom: data['mom_count'] as int,
    );
  }

  @override
  Future<List<RecentPerformance>> getRecentPerformances({
    required String playerId,
    required String teamId,
    int limit = 5,
  }) async {
    final data = await _client
        .from('player_match_stats')
        .select('*, matches(date, opponent_name, opponent_logo_url, team_id)')
        .eq('player_id', playerId)
        .order('matches(date)', ascending: false)
        .limit(limit);

    return data.where((row) {
      final match = row['matches'] as Map<String, dynamic>?;
      return match != null && match['team_id'] == teamId;
    }).map((row) {
      final match = row['matches'] as Map<String, dynamic>;
      return RecentPerformance(
        opponent: match['opponent_name'] as String,
        opponentLogoUrl: match['opponent_logo_url'] as String?,
        date: DateTime.parse(match['date'] as String),
        goals: row['goals'] as int,
        assists: row['assists'] as int,
        isMom: row['is_mom'] as bool,
      );
    }).toList();
  }

  @override
  Future<void> saveMatchStats({
    required String matchId,
    required List<PlayerMatchStats> stats,
  }) async {
    // 기존 기록 삭제 후 재삽입
    await _client
        .from('player_match_stats')
        .delete()
        .eq('match_id', matchId);

    if (stats.isEmpty) return;

    await _client.from('player_match_stats').insert(
          stats
              .map((s) => {
                    'match_id': matchId,
                    'player_id': s.playerId,
                    'goals': s.goals,
                    'assists': s.assists,
                    'is_mom': s.isMom,
                  })
              .toList(),
        );
  }

  @override
  Future<List<PlayerRank>> getTeamRanking({
    required String teamId,
    required RankType rankType,
    int limit = 5,
  }) async {
    final column = switch (rankType) {
      RankType.goals => 'goals',
      RankType.assists => 'assists',
      RankType.mom => 'mom_count',
    };

    final data = await _client
        .from('season_player_stats')
        .select('player_id, name, $column')
        .eq('team_id', teamId)
        .order(column, ascending: false)
        .limit(limit);

    return data.map((row) {
      return PlayerRank(
        name: row['name'] as String,
        position: '', // 뷰에 포지션 없음 — 필요 시 join 추가
        value: row[column] as int,
      );
    }).toList();
  }

  @override
  Future<List<PlayerTitle>> getPlayerTitles({
    required String playerId,
    required String teamId,
    required int year,
    required SeasonHalf half,
  }) async {
    final raw = await _client.rpc(
      'get_player_titles',
      params: {
        'p_player_id': playerId,
        'p_team_id': teamId,
        'p_year': year,
        'p_half': half == SeasonHalf.first ? 'H1' : 'H2',
      },
    );
    if (raw == null) return const [];
    final labels = (raw as List<dynamic>).cast<String>();
    return labels
        .map(PlayerTitle.fromLabel)
        .whereType<PlayerTitle>()
        .toList();
  }
}
