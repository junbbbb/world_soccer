import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'widgets/chat_room_cell.dart';

/// 읽음 상태 (WhatsApp 체크마크)
enum MessageReadStatus { sent, delivered, read }

/// 메시지 타입
enum MessageType { text, event }

/// 채팅 메시지 모델 (더미)
class ChatMessage {
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

  final String id;
  final int senderId;
  final String senderName;
  final String? memberTag;
  final String? avatarPath;
  final String text;
  final DateTime timestamp;
  final bool isMe;
  final MessageReadStatus readStatus;
  final MessageType type;
}

/// 채팅방 모델 (더미)
class ChatRoom {
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
}

class ChatTab extends StatelessWidget {
  const ChatTab({super.key});

  static final _rooms = [
    ChatRoom(
      id: 'calor',
      name: '칼로FC',
      logoPath: 'assets/images/fc_calor.png',
      lastMessage: '네 흰색 유니폼으로 통일하겠습니다',
      lastMessageSender: '김민수',
      lastMessageTime: DateTime(2026, 3, 15, 16, 0),
      memberCount: 24,
      unreadCount: 3,
      isPinned: true,
    ),
    ChatRoom(
      id: 'bosong',
      name: '보성FC',
      logoPath: 'assets/images/fc_bosong.png',
      lastMessage: '다음 주 연습경기 일정 확인해주세요',
      lastMessageSender: '홍길동',
      lastMessageTime: DateTime(2026, 3, 15, 14, 22),
      memberCount: 18,
      unreadCount: 0,
    ),
    ChatRoom(
      id: 'futsal',
      name: '수요 풋살 모임',
      lastMessage: '이번 주 수요일 7시 맞죠?',
      lastMessageSender: '최영훈',
      lastMessageTime: DateTime(2026, 3, 14, 21, 15),
      memberCount: 12,
      unreadCount: 5,
    ),
    ChatRoom(
      id: 'notice',
      name: '전체 공지방',
      lastMessage: '3월 회비 납부 안내드립니다',
      lastMessageSender: '관리자',
      lastMessageTime: DateTime(2026, 3, 13, 10, 0),
      memberCount: 45,
      unreadCount: 1,
      isMuted: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              top: AppSpacing.sm,
              bottom: AppSpacing.base,
            ),
            child: Row(
              children: [
                Text(
                  '채팅',
                  style: AppTextStyles.pageTitle.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.edit_note_rounded,
                  color: AppColors.textTertiary,
                  size: 26,
                ),
              ],
            ),
          ),
          // 채팅방 목록
          Expanded(
            child: ListView.separated(
              itemCount: _rooms.length,
              separatorBuilder: (_, __) => Divider(
                height: 0.5,
                indent: AppSpacing.base + 52 + AppSpacing.md, // 좌패딩 + 아바타 + 간격
                color: AppColors.iconInactive.withValues(alpha: 0.3),
              ),
              itemBuilder: (context, index) {
                final room = _rooms[index];
                return ChatRoomCell(
                  room: room,
                  onTap: () => context.push('/chat', extra: room),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
