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
    int durationMinutes = 120,
  });

  /// 경기 결과 입력.
  Future<void> updateResult({
    required String matchId,
    required int ourScore,
    required int opponentScore,
  });

  /// 경기 정보 수정.
  Future<void> updateInfo({
    required String matchId,
    DateTime? date,
    String? location,
    String? opponentName,
    int? durationMinutes,
  });

  /// 경기 상태 변경 (취소, 조기종료 등).
  Future<void> updateStatus({
    required String matchId,
    required String status,
  });

  /// 상대 전적 (H2H).
  Future<List<Match>> getH2H({
    required String teamId,
    required String opponentName,
  });
}
