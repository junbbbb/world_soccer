import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/snackbar.dart';
import '../../../runtime/providers.dart';
import '../../../types/chat.dart';
import '../../../types/enums.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_date_separator.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/event_reminder_card.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  const ChatRoomScreen({super.key, required this.room});

  final ChatRoom room;

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  /// 초기 로드된 메시지 + 실시간 스트림 수신분을 합쳐서 보관.
  final List<ChatMessage> _messages = [];
  final Set<String> _messageIds = <String>{};
  bool _initialLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _markRead();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    final user = ref.read(supabaseClientProvider).auth.currentUser;
    if (user == null) return;
    try {
      final msgs = await ref
          .read(chatServiceProvider)
          .getMessages(roomId: widget.room.id, viewerId: user.id);
      if (!mounted) return;
      setState(() {
        for (final m in msgs) {
          if (_messageIds.add(m.id)) _messages.add(m);
        }
        _injectMockMessages();
        _initialLoaded = true;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _injectMockMessages();
          _initialLoaded = true;
        });
      }
    }
  }

  /// 개발용 mock 메시지. 팀 단체방에서만 시각적으로 표시.
  /// 실제 백엔드 메시지와 섞여 예시로만 보이며 전송/저장되지 않는다.
  void _injectMockMessages() {
    if (widget.room.type != ChatRoomType.team) return;

    const avatarA = 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif';
    const avatarB = 'assets/images/avatars/RAYA_Headshot_web_njztl3wr.avif';
    const avatarC = 'assets/images/avatars/SALIBA_Headshot_web_khl9z1vw.avif';
    const avatarD = 'assets/images/avatars/MOSQUERA_Headshot_web_b3sucu1j.avif';
    final roomId = widget.room.id;

    final mocks = <ChatMessage>[
      ChatMessage(
        id: 'mock-1',
        roomId: roomId,
        senderId: 'mock-u1',
        senderName: '김민수',
        avatarPath: avatarA,
        text: '내일 경기 준비 다들 되셨나요?',
        timestamp: DateTime(2026, 3, 14, 20, 30),
        isMe: false,
      ),
      ChatMessage(
        id: 'mock-2',
        roomId: roomId,
        senderId: 'mock-u2',
        senderName: '이준호',
        avatarPath: avatarB,
        text: '넵! 준비 완료입니다',
        timestamp: DateTime(2026, 3, 14, 20, 31),
        isMe: false,
      ),
      ChatMessage(
        id: 'mock-3',
        roomId: roomId,
        senderId: 'mock-me',
        senderName: '나',
        text: '유니폼 세탁 중이에요 ㅋㅋ',
        timestamp: DateTime(2026, 3, 14, 20, 33),
        isMe: true,
      ),
      ChatMessage(
        id: 'mock-ev1',
        roomId: roomId,
        senderId: 'mock-system',
        senderName: '',
        text: '3/22(토) 16:00 경기 — 보성 풋살장',
        timestamp: DateTime(2026, 3, 15, 12, 0),
        isMe: false,
        type: MessageType.event,
      ),
      ChatMessage(
        id: 'mock-4',
        roomId: roomId,
        senderId: 'mock-u1',
        senderName: '김민수',
        avatarPath: avatarA,
        text: '오늘 경기 4시입니다! 보성 풋살장으로 와주세요',
        timestamp: DateTime(2026, 3, 15, 13, 0),
        isMe: false,
      ),
      ChatMessage(
        id: 'mock-5',
        roomId: roomId,
        senderId: 'mock-u2',
        senderName: '이준호',
        avatarPath: avatarB,
        text: '저 도착했어요!',
        timestamp: DateTime(2026, 3, 15, 15, 30),
        isMe: false,
      ),
      ChatMessage(
        id: 'mock-6',
        roomId: roomId,
        senderId: 'mock-u3',
        senderName: '박성진',
        avatarPath: avatarC,
        text: '저는 조금 늦을 것 같습니다 ㅠㅠ 10분만 기다려주세요',
        timestamp: DateTime(2026, 3, 15, 15, 42),
        isMe: false,
      ),
      ChatMessage(
        id: 'mock-7',
        roomId: roomId,
        senderId: 'mock-me',
        senderName: '나',
        text: '저도 거의 다 왔어요',
        timestamp: DateTime(2026, 3, 15, 15, 43),
        isMe: true,
        readStatus: MessageReadStatus.delivered,
      ),
      ChatMessage(
        id: 'mock-8',
        roomId: roomId,
        senderId: 'mock-u4',
        senderName: '최영훈',
        avatarPath: avatarD,
        text: '주차장 자리 있나요?',
        timestamp: DateTime(2026, 3, 15, 15, 45),
        isMe: false,
      ),
      ChatMessage(
        id: 'mock-9',
        roomId: roomId,
        senderId: 'mock-u1',
        senderName: '김민수',
        avatarPath: avatarA,
        text: '네 아직 자리 많아요',
        timestamp: DateTime(2026, 3, 15, 15, 45, 30),
        isMe: false,
      ),
      ChatMessage(
        id: 'mock-10',
        roomId: roomId,
        senderId: 'mock-u1',
        senderName: '김민수',
        avatarPath: avatarA,
        text: '빨리 오세요~',
        timestamp: DateTime(2026, 3, 15, 15, 46),
        isMe: false,
      ),
      ChatMessage(
        id: 'mock-11',
        roomId: roomId,
        senderId: 'mock-me',
        senderName: '나',
        text: '도착!',
        timestamp: DateTime(2026, 3, 15, 15, 55),
        isMe: true,
      ),
      ChatMessage(
        id: 'mock-12',
        roomId: roomId,
        senderId: 'mock-u5',
        senderName: '정우성',
        avatarPath: avatarA,
        text: '혹시 유니폼 가져와야 하나요?',
        timestamp: DateTime(2026, 3, 15, 15, 58),
        isMe: false,
      ),
      ChatMessage(
        id: 'mock-13',
        roomId: roomId,
        senderId: 'mock-u1',
        senderName: '김민수',
        avatarPath: avatarA,
        text: '네 흰색 유니폼으로 통일하겠습니다',
        timestamp: DateTime(2026, 3, 15, 16, 0),
        isMe: false,
      ),
      ChatMessage(
        id: 'mock-14',
        roomId: roomId,
        senderId: 'mock-me',
        senderName: '나',
        text: '알겠습니다',
        timestamp: DateTime(2026, 3, 15, 16, 1),
        isMe: true,
        readStatus: MessageReadStatus.sent,
      ),
    ];

    for (final m in mocks) {
      if (_messageIds.add(m.id)) _messages.add(m);
    }
    _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  Future<void> _markRead() async {
    final user = ref.read(supabaseClientProvider).auth.currentUser;
    if (user == null) return;
    await ref
        .read(chatServiceProvider)
        .markAsRead(roomId: widget.room.id, playerId: user.id);
    // chat_room_members UPDATE 가 realtime 으로 흘러가 chat_tab 이
    // myChatRoomsProvider 를 invalidate 한다. 여기서 재호출 불필요.
  }

  Future<void> _handleSend(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final user = ref.read(supabaseClientProvider).auth.currentUser;
    if (user == null) return;

    _textController.clear();
    try {
      final sent = await ref.read(chatServiceProvider).sendMessage(
            roomId: widget.room.id,
            senderId: user.id,
            text: trimmed,
          );
      // Optimistic: 서버 ack 받자마자 즉시 화면에 반영.
      // 뒤이어 오는 realtime stream 은 같은 id 로 dedup 된다.
      _ingestStreamMessage(sent);
    } catch (e) {
      if (!mounted) return;
      context.showError('전송 실패: $e');
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _ingestStreamMessage(ChatMessage m) {
    if (_messageIds.add(m.id)) {
      setState(() {
        _messages.add(m);
        // 스트림 경합/오프셋 등으로 순서가 깨질 수 있어 timestamp 기준 오름차순 정렬.
        // ListView 는 reverse:true 이므로 배열 끝이 화면 맨 아래(최신).
        _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 실시간 스트림 구독 (새 메시지 도착 시 _messages 에 누적).
    ref.listen<AsyncValue<ChatMessage>>(
      roomMessageStreamProvider(widget.room.id),
      (prev, next) {
        next.whenData(_ingestStreamMessage);
      },
    );

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
                  child: !_initialLoaded
                      ? const Center(child: CircularProgressIndicator())
                      : _messages.isEmpty
                          ? Center(
                              child: Text(
                                '첫 메시지를 남겨보세요',
                                style:
                                    AppTextStyles.bodyRegular.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            )
                          : ListView.builder(
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

    final effectiveOlder =
        olderMessage?.type == MessageType.event ? null : olderMessage;
    final effectiveNewer =
        newerMessage?.type == MessageType.event ? null : newerMessage;

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

  Widget _buildHeader() {
    return Container(
      height: 56,
      color: Colors.white,
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        right: AppSpacing.md,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 24,
              color: AppColors.textPrimary,
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: widget.room.type == ChatRoomType.team
                  ? () => context.push('/group-info', extra: widget.room)
                  : null,
              child: Row(
                children: [
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
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.15),
                      child: Icon(
                        widget.room.type == ChatRoomType.direct
                            ? Icons.person_rounded
                            : Icons.people_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                  const SizedBox(width: AppSpacing.sm),
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
                        if (widget.room.type == ChatRoomType.team)
                          Text(
                            '참여자 ${widget.room.memberCount}명',
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
        ],
      ),
    );
  }
}
