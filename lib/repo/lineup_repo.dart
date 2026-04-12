/// 라인업 저장소 인터페이스.
abstract class LineupRepo {
  /// 경기의 전체 라인업 조회 (4쿼터).
  /// 반환: 쿼터 번호(1~4) → (formationName, slotToPlayerId)
  Future<Map<int, ({String formationName, Map<int, String> slotToPlayerId})>>
      getByMatch(String matchId);

  /// 라인업 저장 (전체 4쿼터 한 번에).
  /// [quarters]: 쿼터 번호(1~4) → (formationName, slotToPlayerId)
  Future<void> save({
    required String matchId,
    required Map<int, ({String formationName, Map<int, String> slotToPlayerId})>
        quarters,
  });

  /// 특정 쿼터 라인업 삭제.
  Future<void> clearQuarter({
    required String matchId,
    required int quarter,
  });
}
