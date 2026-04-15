import '../types/chat.dart';

/// 채팅 저장소 인터페이스.
///
/// 팀 단체방 생성/가입은 DB 트리거로 자동 처리.
/// DM 방은 `getOrCreateDirectRoom` RPC 가 팀원 검증 + advisory lock 으로
/// 원자적으로 처리한다.
abstract class ChatRepo {
  /// 내가 참여한 채팅방 목록 (서버에서 집계, 마지막 메시지 기준 내림차순).
  Future<List<ChatRoom>> getMyRooms(String playerId);

  /// 채팅방 상세.
  Future<ChatRoom> getRoom(String roomId);

  /// 내가 특정 방의 참여자인지.
  Future<bool> isMember({required String roomId, required String playerId});

  /// DM 방 얻기/만들기.
  ///
  /// 서버 RPC 에서 다음을 처리:
  /// - 자기 자신 체크
  /// - 같은 팀 검증 → [NotTeammateException]
  /// - advisory lock 으로 동시 생성 방지
  /// - 기존 방 재사용 또는 신규 생성
  Future<ChatRoom> getOrCreateDirectRoom({
    required String meId,
    required String otherId,
  });

  /// 방의 메시지 목록 (시간순).
  ///
  /// [before] 가 주어지면 해당 시각 이전 메시지만 반환 (커서 페이지네이션).
  Future<List<ChatMessage>> getMessages(
    String roomId, {
    int limit = 50,
    DateTime? before,
  });

  /// 메시지 전송.
  Future<ChatMessage> sendMessage({
    required String roomId,
    required String senderId,
    required String text,
  });

  /// 읽음 처리 (last_read_at 갱신).
  Future<void> markAsRead({
    required String roomId,
    required String playerId,
  });

  /// 방의 메시지 실시간 스트림.
  Stream<ChatMessage> subscribeMessages(String roomId);
}

/// DM 대상이 같은 팀원이 아닐 때 발생 (서버가 던지는 Postgrest 에러를 매핑).
class NotTeammateException implements Exception {
  const NotTeammateException();

  @override
  String toString() => '같은 팀원에게만 개인 메시지를 보낼 수 있습니다.';
}
