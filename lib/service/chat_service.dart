import '../repo/chat_repo.dart';
import '../types/chat.dart';

/// 채팅 비즈니스 로직.
///
/// 서버 RPC(`get_or_create_direct_room`, `get_my_chat_rooms`) 가 팀원 검증과
/// 원자적 DM 생성을 처리하므로, 서비스는 클라이언트 측 입력 검증과
/// 리포지토리 호출만 담당한다.
class ChatService {
  final ChatRepo chatRepo;

  ChatService({required this.chatRepo});

  /// 내가 참여한 채팅방 목록.
  Future<List<ChatRoom>> getMyRooms(String playerId) {
    return chatRepo.getMyRooms(playerId);
  }

  /// 메시지 조회. 참여자만 허용.
  Future<List<ChatMessage>> getMessages({
    required String roomId,
    required String viewerId,
    int limit = 50,
    DateTime? before,
  }) async {
    final isMember =
        await chatRepo.isMember(roomId: roomId, playerId: viewerId);
    if (!isMember) {
      throw const NotRoomMemberException();
    }
    return chatRepo.getMessages(roomId, limit: limit, before: before);
  }

  /// 메시지 전송. 참여자만 허용하고 trim.
  Future<ChatMessage> sendMessage({
    required String roomId,
    required String senderId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('메시지가 비어있습니다');
    }
    final isMember =
        await chatRepo.isMember(roomId: roomId, playerId: senderId);
    if (!isMember) {
      throw const NotRoomMemberException();
    }
    return chatRepo.sendMessage(
      roomId: roomId,
      senderId: senderId,
      text: trimmed,
    );
  }

  /// 팀원 간 DM 방 얻기(없으면 생성).
  ///
  /// 자기 자신 체크만 클라이언트에서 즉시. 팀원 검증·중복방지는 서버 RPC.
  Future<ChatRoom> getOrCreateDirectRoom({
    required String meId,
    required String otherId,
  }) {
    if (meId == otherId) {
      throw ArgumentError('자기 자신과의 DM 은 생성할 수 없습니다');
    }
    return chatRepo.getOrCreateDirectRoom(meId: meId, otherId: otherId);
  }

  /// 읽음 처리. 참여자 아니면 조용히 무시.
  Future<void> markAsRead({
    required String roomId,
    required String playerId,
  }) async {
    final isMember =
        await chatRepo.isMember(roomId: roomId, playerId: playerId);
    if (!isMember) return;
    await chatRepo.markAsRead(roomId: roomId, playerId: playerId);
  }

  /// 실시간 메시지 스트림.
  Stream<ChatMessage> subscribe(String roomId) =>
      chatRepo.subscribeMessages(roomId);
}

/// 채팅방 참여자가 아닐 때 발생.
class NotRoomMemberException implements Exception {
  const NotRoomMemberException();

  @override
  String toString() => '해당 채팅방의 참여자가 아닙니다.';
}
