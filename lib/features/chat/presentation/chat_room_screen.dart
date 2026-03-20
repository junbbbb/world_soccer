import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import 'chat_tab.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_date_separator.dart';
import 'widgets/chat_input_bar.dart';

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({super.key, required this.room});

  final ChatRoom room;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  final List<ChatMessage> _messages = [
    ChatMessage(
      id: '1',
      senderId: 1,
      senderName: '김민수',
      text: '내일 경기 준비 다들 되셨나요?',
      timestamp: DateTime(2026, 3, 14, 20, 30),
      isMe: false,
    ),
    ChatMessage(
      id: '2',
      senderId: 2,
      senderName: '이준호',
      text: '넵! 준비 완료입니다 💪',
      timestamp: DateTime(2026, 3, 14, 20, 31),
      isMe: false,
    ),
    ChatMessage(
      id: '3',
      senderId: 0,
      senderName: '나',
      text: '유니폼 세탁 중이에요 ㅋㅋ',
      timestamp: DateTime(2026, 3, 14, 20, 33),
      isMe: true,
    ),
    ChatMessage(
      id: '4',
      senderId: 1,
      senderName: '김민수',
      text: '오늘 경기 4시입니다! 보성 풋살장으로 와주세요',
      timestamp: DateTime(2026, 3, 15, 13, 0),
      isMe: false,
    ),
    ChatMessage(
      id: '5',
      senderId: 2,
      senderName: '이준호',
      text: '저 도착했어요!',
      timestamp: DateTime(2026, 3, 15, 15, 30),
      isMe: false,
    ),
    ChatMessage(
      id: '6',
      senderId: 3,
      senderName: '박성진',
      text: '저는 조금 늦을 것 같습니다 ㅠㅠ 10분만 기다려주세요',
      timestamp: DateTime(2026, 3, 15, 15, 42),
      isMe: false,
      reaction: '😫',
    ),
    ChatMessage(
      id: '7',
      senderId: 0,
      senderName: '나',
      text: '저도 거의 다 왔어요',
      timestamp: DateTime(2026, 3, 15, 15, 43),
      isMe: true,
    ),
    ChatMessage(
      id: '8',
      senderId: 4,
      senderName: '최영훈',
      text: '주차장 자리 있나요?',
      timestamp: DateTime(2026, 3, 15, 15, 45),
      isMe: false,
    ),
    ChatMessage(
      id: '9',
      senderId: 1,
      senderName: '김민수',
      text: '네 아직 자리 많아요',
      timestamp: DateTime(2026, 3, 15, 15, 45),
      isMe: false,
    ),
    ChatMessage(
      id: '10',
      senderId: 1,
      senderName: '김민수',
      text: '빨리 오세요~',
      timestamp: DateTime(2026, 3, 15, 15, 46),
      isMe: false,
      reaction: '👍',
    ),
    ChatMessage(
      id: '11',
      senderId: 0,
      senderName: '나',
      text: '도착! 💪',
      timestamp: DateTime(2026, 3, 15, 15, 55),
      isMe: true,
    ),
    ChatMessage(
      id: '12',
      senderId: 5,
      senderName: '정우성',
      text: '혹시 유니폼 가져와야 하나요?',
      timestamp: DateTime(2026, 3, 15, 15, 58),
      isMe: false,
    ),
    ChatMessage(
      id: '13',
      senderId: 1,
      senderName: '김민수',
      text: '네 흰색 유니폼으로 통일하겠습니다',
      timestamp: DateTime(2026, 3, 15, 16, 0),
      isMe: false,
    ),
    ChatMessage(
      id: '14',
      senderId: 0,
      senderName: '나',
      text: '👍',
      timestamp: DateTime(2026, 3, 15, 16, 1),
      isMe: true,
    ),
    ChatMessage(
      id: '15',
      senderId: 3,
      senderName: '박성진',
      text: '경기 끝나고 뒷풀이 갈 사람?',
      timestamp: DateTime(2026, 3, 15, 17, 30),
      isMe: false,
    ),
    ChatMessage(
      id: '16',
      senderId: 2,
      senderName: '이준호',
      replyToSender: '박성진',
      replyToText: '경기 끝나고 뒷풀이 갈 사람?',
      text: '저요! 🙋‍♂️',
      timestamp: DateTime(2026, 3, 15, 17, 32),
      isMe: false,
      reaction: '❤️',
    ),
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSend(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: 0,
          senderName: '나',
          text: text.trim(),
          timestamp: DateTime.now(),
          isMe: true,
        ),
      );
    });
    _textController.clear();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.chatBackground,
        body: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: Stack(
                children: [
                  // WhatsApp 배경: 단색(#F5F2EB) 위에 타일 패턴
                  // CSS: background-blend-mode: difference, normal
                  // 타일: 80%, 온도 최좌측(푸른느낌), 불투명도 10%
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.10,
                      child: Image.asset(
                        'assets/images/chat_bg_pattern.png',
                        repeat: ImageRepeat.repeat,
                        color: AppColors.chatBackground,
                        colorBlendMode: BlendMode.difference,
                      ),
                    ),
                  ),
                  // 채팅 메시지 리스트
                  ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.only(
                      top: AppSpacing.sm,
                      bottom: AppSpacing.sm,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: _buildItem,
                  ),
                ],
              ),
            ),
            ChatInputBar(
              controller: _textController,
              onSend: _handleSend,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final message = _messages[_messages.length - 1 - index];

    final olderMessage = (index < _messages.length - 1)
        ? _messages[_messages.length - 2 - index]
        : null;

    final newerMessage =
        (index > 0) ? _messages[_messages.length - index] : null;

    final isFirstInGroup = olderMessage == null ||
        olderMessage.senderId != message.senderId ||
        !_isSameDay(message.timestamp, olderMessage.timestamp);

    final isLastInGroup = newerMessage == null ||
        newerMessage.senderId != message.senderId ||
        !_isSameDay(message.timestamp, newerMessage.timestamp);

    // 꼬리: 그룹 내 마지막 메시지에만 표시
    final showTail = isLastInGroup;

    final showDateSeparator = olderMessage == null ||
        !_isSameDay(message.timestamp, olderMessage.timestamp);

    return Column(
      children: [
        if (showDateSeparator) ChatDateSeparator(date: message.timestamp),
        ChatBubble(
          message: message,
          isFirstInGroup: isFirstInGroup,
          isLastInGroup: isLastInGroup,
          showTail: showTail,
          isGroup: widget.room.isGroup,
        ),
      ],
    );
  }

  // ── WhatsApp 스타일 상단 바 ──
  Widget _buildTopBar(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      color: AppColors.chatPanel,
      padding: EdgeInsets.only(top: topPadding),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 4,
          right: 22,
          top: 4,
          bottom: 4,
        ),
        child: Row(
          children: [
            // 뒤로가기 + 읽지 않은 수
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const SizedBox(
                width: 32,
                height: 32,
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  size: 20,
                  color: AppColors.chatTextPrimary,
                ),
              ),
            ),
            // 그룹 아이콘
            _buildGroupAvatar(),
            const SizedBox(width: 10),
            // 이름 + 멤버
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.room.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.32,
                      color: AppColors.chatTextPrimary,
                    ),
                  ),
                  if (widget.room.memberNames != null)
                    Text(
                      widget.room.memberNames!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.12,
                        color: AppColors.chatTextSecondary,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // 영상통화
            const Icon(
              Icons.videocam_rounded,
              size: 26,
              color: AppColors.chatTextSecondary,
            ),
            const SizedBox(width: 16),
            // 음성통화
            const Icon(
              Icons.phone_rounded,
              size: 22,
              color: AppColors.chatTextSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupAvatar() {
    if (widget.room.logoPath != null) {
      return ClipOval(
        child: Image.asset(
          widget.room.logoPath!,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
        ),
      );
    }

    // 기본 그룹 아바타
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.grey.shade400,
            Colors.grey.shade500,
          ],
        ),
      ),
      child: const Icon(
        Icons.group_rounded,
        size: 20,
        color: Colors.white,
      ),
    );
  }
}
