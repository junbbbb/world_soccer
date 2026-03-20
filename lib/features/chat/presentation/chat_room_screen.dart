import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'chat_tab.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_date_separator.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/event_reminder_card.dart';

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
      avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif',
      text: '내일 경기 준비 다들 되셨나요?',
      timestamp: DateTime(2026, 3, 14, 20, 30),
      isMe: false,
      readStatus: MessageReadStatus.read,
    ),
    ChatMessage(
      id: '2',
      senderId: 2,
      senderName: '이준호',
      avatarPath: 'assets/images/avatars/RAYA_Headshot_web_njztl3wr.avif',
      text: '넵! 준비 완료입니다',
      timestamp: DateTime(2026, 3, 14, 20, 31),
      isMe: false,
      readStatus: MessageReadStatus.read,
    ),
    ChatMessage(
      id: '3',
      senderId: 0,
      senderName: '나',
      text: '유니폼 세탁 중이에요 ㅋㅋ',
      timestamp: DateTime(2026, 3, 14, 20, 33),
      isMe: true,
      readStatus: MessageReadStatus.read,
    ),
    // Event Reminder
    ChatMessage(
      id: 'ev1',
      senderId: -1,
      senderName: '',
      text: '3/22(토) 16:00 경기 — 보성 풋살장',
      timestamp: DateTime(2026, 3, 15, 12, 0),
      isMe: false,
      type: MessageType.event,
    ),
    ChatMessage(
      id: '4',
      senderId: 1,
      senderName: '김민수',
      avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif',
      text: '오늘 경기 4시입니다! 보성 풋살장으로 와주세요',
      timestamp: DateTime(2026, 3, 15, 13, 0),
      isMe: false,
      readStatus: MessageReadStatus.read,
    ),
    ChatMessage(
      id: '5',
      senderId: 2,
      senderName: '이준호',
      avatarPath: 'assets/images/avatars/RAYA_Headshot_web_njztl3wr.avif',
      text: '저 도착했어요!',
      timestamp: DateTime(2026, 3, 15, 15, 30),
      isMe: false,
      readStatus: MessageReadStatus.read,
    ),
    ChatMessage(
      id: '6',
      senderId: 3,
      senderName: '박성진',
      avatarPath: 'assets/images/avatars/SALIBA_Headshot_web_khl9z1vw.avif',
      text: '저는 조금 늦을 것 같습니다 ㅠㅠ 10분만 기다려주세요',
      timestamp: DateTime(2026, 3, 15, 15, 42),
      isMe: false,
      readStatus: MessageReadStatus.read,
    ),
    ChatMessage(
      id: '7',
      senderId: 0,
      senderName: '나',
      text: '저도 거의 다 왔어요',
      timestamp: DateTime(2026, 3, 15, 15, 43),
      isMe: true,
      readStatus: MessageReadStatus.delivered,
    ),
    ChatMessage(
      id: '8',
      senderId: 4,
      senderName: '최영훈',
      avatarPath: 'assets/images/avatars/MOSQUERA_Headshot_web_b3sucu1j.avif',
      text: '주차장 자리 있나요?',
      timestamp: DateTime(2026, 3, 15, 15, 45),
      isMe: false,
      readStatus: MessageReadStatus.read,
    ),
    ChatMessage(
      id: '9',
      senderId: 1,
      senderName: '김민수',
      avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif',
      text: '네 아직 자리 많아요',
      timestamp: DateTime(2026, 3, 15, 15, 45),
      isMe: false,
      readStatus: MessageReadStatus.read,
    ),
    ChatMessage(
      id: '10',
      senderId: 1,
      senderName: '김민수',
      avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif',
      text: '빨리 오세요~',
      timestamp: DateTime(2026, 3, 15, 15, 46),
      isMe: false,
      readStatus: MessageReadStatus.read,
    ),
    ChatMessage(
      id: '11',
      senderId: 0,
      senderName: '나',
      text: '도착!',
      timestamp: DateTime(2026, 3, 15, 15, 55),
      isMe: true,
      readStatus: MessageReadStatus.read,
    ),
    ChatMessage(
      id: '12',
      senderId: 5,
      senderName: '정우성',
      avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif',
      text: '혹시 유니폼 가져와야 하나요?',
      timestamp: DateTime(2026, 3, 15, 15, 58),
      isMe: false,
      readStatus: MessageReadStatus.read,
    ),
    ChatMessage(
      id: '13',
      senderId: 1,
      senderName: '김민수',
      avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif',
      text: '네 흰색 유니폼으로 통일하겠습니다',
      timestamp: DateTime(2026, 3, 15, 16, 0),
      isMe: false,
      readStatus: MessageReadStatus.read,
    ),
    ChatMessage(
      id: '14',
      senderId: 0,
      senderName: '나',
      text: '알겠습니다',
      timestamp: DateTime(2026, 3, 15, 16, 1),
      isMe: true,
      readStatus: MessageReadStatus.sent,
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

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
          readStatus: MessageReadStatus.sent,
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
                  color: Colors.white,
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
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
    final messages = _messages;
    final message = messages[messages.length - 1 - index];

    // Event Reminder
    if (message.type == MessageType.event) {
      return EventReminderCard(
        message: message,
        onTap: () => context.push('/match'),
      );
    }

    final olderMessage = (index < messages.length - 1)
        ? messages[messages.length - 2 - index]
        : null;

    final newerMessage =
        (index > 0) ? messages[messages.length - index] : null;

    // event 타입 메시지는 그룹핑에서 제외
    final effectiveOlder = olderMessage?.type == MessageType.event ? null : olderMessage;
    final effectiveNewer = newerMessage?.type == MessageType.event ? null : newerMessage;

    final isFirstInGroup = effectiveOlder == null ||
        effectiveOlder.senderId != message.senderId ||
        !_isSameDay(message.timestamp, effectiveOlder.timestamp);

    final isLastInGroup = effectiveNewer == null ||
        effectiveNewer.senderId != message.senderId ||
        !_isSameDay(message.timestamp, effectiveNewer.timestamp);

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

  /// Messenger 스타일 헤더
  Widget _buildHeader() {
    // 더미 멤버 이름 (스크린샷처럼 "동생, 나" 형식)
    const memberNames = '김민수, 이준호, 박성진, 나';

    return Container(
      height: 56,
      color: Colors.white,
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        right: AppSpacing.md,
      ),
      child: Row(
        children: [
          // ← 백버튼
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 24,
              color: AppColors.textPrimary,
            ),
          ),
          // 아바타 + 이름 (탭 → Group Info)
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/group-info', extra: widget.room),
              child: Row(
                children: [
                  // 원형 그룹 아바타 32×32pt
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
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                      child: Icon(
                        Icons.people_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                  const SizedBox(width: AppSpacing.sm),
                  // 그룹 이름 + 멤버 이름 나열
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.room.name,
                          style: AppTextStyles.heading.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          memberNames,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 전화 + 영상통화 (Messenger 스타일)
          const Icon(
            Icons.phone_outlined,
            color: AppColors.textPrimary,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.base),
          const Icon(
            Icons.videocam_outlined,
            color: AppColors.textPrimary,
            size: 24,
          ),
        ],
      ),
    );
  }
}
