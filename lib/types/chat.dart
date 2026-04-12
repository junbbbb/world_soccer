/// 채팅 모델.

import 'enums.dart';

class ChatMessage {
  final String id;
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
  final String name;
  final String? logoPath;
  final String lastMessage;
  final String lastMessageSender;
  final DateTime lastMessageTime;
  final int memberCount;
  final int unreadCount;
  final bool isPinned;
  final bool isMuted;

  const ChatRoom({
    required this.id,
    required this.name,
    this.logoPath,
    required this.lastMessage,
    required this.lastMessageSender,
    required this.lastMessageTime,
    required this.memberCount,
    this.unreadCount = 0,
    this.isPinned = false,
    this.isMuted = false,
  });
}
