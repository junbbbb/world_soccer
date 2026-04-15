import '../types/enums.dart';
import '../types/match.dart';
import '../types/profile.dart';

/// 스탯 저장소 인터페이스.
abstract class StatsRepo {
  /// 시즌 개인 스탯.
  Future<SeasonStats> getSeasonStats({
    required String playerId,
    required String teamId,
    required int year,
    required SeasonHalf half,
  });

  /// 선수 최근 경기 퍼포먼스.
  Future<List<RecentPerformance>> getRecentPerformances({
    required String playerId,
    required String teamId,
    int limit = 5,
  });

  /// 경기별 개인 기록 저장 (골/어시/MOM).
  Future<void> saveMatchStats({
    required String matchId,
    required List<PlayerMatchStats> stats,
  });

  /// 팀 내 랭킹.
  Future<List<PlayerRank>> getTeamRanking({
    required String teamId,
    required RankType rankType,
    int limit = 5,
  });

  /// 선수가 팀·반기 기준 획득한 뱃지 목록.
  ///
  /// 최소 3경기 출전, 공동 1위 포함. 없으면 빈 리스트.
  Future<List<PlayerTitle>> getPlayerTitles({
    required String playerId,
    required String teamId,
    required int year,
    required SeasonHalf half,
  });
}
