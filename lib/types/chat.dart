/// 채팅 모델.

import 'enums.dart';

/// 채팅방 종류.
enum ChatRoomType {
  team,   // 팀 단체방 (팀당 1개, 자동 생성)
  direct, // 팀원 간 1:1 DM
}

class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String? memberTag;
  final String? avatarPath;
  final String text;
  final DateTime timestamp;
  final bool isMe;
  final MessageReadStatus readStatus;
  final MessageType type;

  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    this.memberTag,
    this.avatarPath,
    required this.text,
    required this.timestamp,
    required this.isMe,
    this.readStatus = MessageReadStatus.read,
    this.type = MessageType.text,
  });
}

class ChatRoom {
  final String id;
  final ChatRoomType type;
  final String? teamId; // type == team 일 때만
  final String name;
  final String? logoPath; // asset 경로 (legacy)
  final String? logoUrl;  // 서버 업로드된 팀 로고 또는 DM 상대 아바타 URL
  final String? logoColor; // URL 없을 때 이니셜 배경 hex (#RRGGBB)
  final String lastMessage;
  final String lastMessageSender;
  final DateTime? lastMessageTime;
  final int memberCount;
  final int unreadCount;
  final bool isPinned;
  final bool isMuted;

  const ChatRoom({
    required this.id,
    required this.type,
    this.teamId,
    required this.name,
    this.logoPath,
    this.logoUrl,
    this.logoColor,
    this.lastMessage = '',
    this.lastMessageSender = '',
    this.lastMessageTime,
    this.memberCount = 0,
    this.unreadCount = 0,
    this.isPinned = false,
    this.isMuted = false,
  });
}
