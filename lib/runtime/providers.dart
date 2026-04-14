import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../types/match.dart' as types;
import '../types/team.dart';
import '../repo/supabase_auth_repo.dart';
import '../repo/supabase_lineup_repo.dart';
import '../repo/supabase_match_repo.dart';
import '../repo/supabase_player_repo.dart';
import '../repo/supabase_profile_repo.dart';
import '../repo/supabase_stats_repo.dart';
import '../repo/supabase_team_repo.dart';
import '../repo/auth_repo.dart';
import '../repo/lineup_repo.dart';
import '../repo/match_repo.dart';
import '../repo/player_repo.dart';
import '../repo/profile_repo.dart';
import '../repo/stats_repo.dart';
import '../repo/team_repo.dart';
import '../service/lineup_service.dart';
import '../service/match_service.dart';
import '../service/team_service.dart';

part 'providers.g.dart';

// ── Supabase Client ──

@Riverpod(keepAlive: true)
SupabaseClient supabaseClient(Ref ref) {
  return Supabase.instance.client;
}

// ── Repo Providers ──

@Riverpod(keepAlive: true)
AuthRepo authRepo(Ref ref) {
  return SupabaseAuthRepo(ref.watch(supabaseClientProvider));
}

@riverpod
MatchRepo matchRepo(Ref ref) {
  return SupabaseMatchRepo(ref.watch(supabaseClientProvider));
}

@riverpod
PlayerRepo playerRepo(Ref ref) {
  return SupabasePlayerRepo(ref.watch(supabaseClientProvider));
}

@riverpod
LineupRepo lineupRepo(Ref ref) {
  return SupabaseLineupRepo(ref.watch(supabaseClientProvider));
}

@riverpod
TeamRepo teamRepo(Ref ref) {
  return SupabaseTeamRepo(ref.watch(supabaseClientProvider));
}

@riverpod
StatsRepo statsRepo(Ref ref) {
  return SupabaseStatsRepo(ref.watch(supabaseClientProvider));
}

@riverpod
ProfileRepo profileRepo(Ref ref) {
  return SupabaseProfileRepo(ref.watch(supabaseClientProvider));
}

// ── Service Providers ──

@riverpod
MatchService matchService(Ref ref) {
  return MatchService(
    matchRepo: ref.watch(matchRepoProvider),
    playerRepo: ref.watch(playerRepoProvider),
  );
}

@riverpod
LineupService lineupService(Ref ref) {
  return LineupService(
    lineupRepo: ref.watch(lineupRepoProvider),
    playerRepo: ref.watch(playerRepoProvider),
  );
}

@riverpod
TeamService teamService(Ref ref) {
  return TeamService(
    teamRepo: ref.watch(teamRepoProvider),
    playerRepo: ref.watch(playerRepoProvider),
  );
}

// ── Data Providers ──

/// 현재 유저의 팀 목록.
@riverpod
Future<List<Team>> myTeams(Ref ref) async {
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return [];
  final teamRepo = ref.watch(teamRepoProvider);
  return teamRepo.getMyTeams(user.id);
}

/// 현재 선택된 팀.
///
/// `players.active_team_id` 를 우선 조회. 없거나 해당 팀이 더 이상 내 팀 목록에
/// 없으면 가입한 첫 팀으로 폴백.
@riverpod
Future<Team?> currentTeam(Ref ref) async {
  final teams = await ref.watch(myTeamsProvider.future);
  if (teams.isEmpty) return null;

  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return teams.first;

  final playerRepo = ref.watch(playerRepoProvider);
  try {
    final activeId = await playerRepo.getActiveTeamId(user.id);
    if (activeId != null) {
      final match = teams.where((t) => t.id == activeId).firstOrNull;
      if (match != null) return match;
    }
  } catch (_) {
    // 실패해도 앱이 멈추지 않게: 첫 팀으로 폴백.
  }
  return teams.first;
}

/// 현재 유저의 첫 번째 팀 ID.
@riverpod
Future<String?> currentTeamId(Ref ref) async {
  final team = await ref.watch(currentTeamProvider.future);
  return team?.id;
}

/// 팀의 전체 경기 목록 (최신순).
@riverpod
Future<List<types.Match>> teamMatches(Ref ref) async {
  final teamId = await ref.watch(currentTeamIdProvider.future);
  if (teamId == null) return [];
  final matchRepo = ref.watch(matchRepoProvider);
  return matchRepo.getByTeam(teamId);
}
