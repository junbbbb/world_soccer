import '../types/match.dart';

/// 경기 저장소 인터페이스.
abstract class MatchRepo {
  /// 팀의 경기 목록 (최신순).
  Future<List<Match>> getByTeam(String teamId);

  /// 경기 상세 조회.
  Future<Match> getById(String matchId);

  /// 경기 생성.
  Future<Match> create({
    required String teamId,
    required DateTime date,
    required String location,
    required String opponentName,
    String? opponentLogoUrl,
  });

  /// 경기 결과 입력.
  Future<void> updateResult({
    required String matchId,
    required int ourScore,
    required int opponentScore,
  });

  /// 상대 전적 (H2H).
  Future<List<Match>> getH2H({
    required String teamId,
    required String opponentName,
  });
}
