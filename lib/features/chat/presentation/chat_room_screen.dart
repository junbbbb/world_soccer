import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
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
      text: '넵! 준비 완료입니다',
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
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Container(
                  color: AppColors.surfaceLight,
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.base,
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: _buildItem,
                  ),
                ),
              ),
              ChatInputBar(
                controller: _textController,
                onSend: _handleSend,
              ),
            ],
          ),
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

    final showDateSeparator = olderMessage == null ||
        !_isSameDay(message.timestamp, olderMessage.timestamp);

    return Column(
      children: [
        if (showDateSeparator) ChatDateSeparator(date: message.timestamp),
        ChatBubble(
          message: message,
          isFirstInGroup: isFirstInGroup,
          isLastInGroup: isLastInGroup,
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        right: AppSpacing.base,
        top: AppSpacing.xs,
        bottom: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // 뒤로가기
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: AppColors.textPrimary,
            ),
          ),
          // 팀 로고
          if (widget.room.logoPath != null)
            ClipOval(
              child: Image.asset(
                widget.room.logoPath!,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
            )
          else
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Text(
                widget.room.name[0],
                style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
              ),
            ),
          const SizedBox(width: AppSpacing.sm),
          // 방 이름 + 멤버 수
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.room.name,
                  style: AppTextStyles.heading.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '멤버 ${widget.room.memberCount}명',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.search_rounded,
            color: AppColors.textTertiary,
            size: 22,
          ),
        ],
      ),
    );
  }
}
