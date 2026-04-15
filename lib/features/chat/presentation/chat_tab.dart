import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../runtime/providers.dart';
import '../../../types/chat.dart';
import 'widgets/chat_room_cell.dart';

class ChatTab extends ConsumerStatefulWidget {
  const ChatTab({super.key});

  @override
  ConsumerState<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends ConsumerState<ChatTab> {
  static const _headerHeight = 56.0;

  RealtimeChannel? _channel;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _subscribeRealtime();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    final ch = _channel;
    if (ch != null) {
      ref.read(supabaseClientProvider).removeChannel(ch);
    }
    super.dispose();
  }

  /// chat_messages / chat_room_members 변경 시 방 목록을 재요청.
  /// 다발 이벤트 대비해 200ms debounce.
  void _subscribeRealtime() {
    final client = ref.read(supabaseClientProvider);
    _channel = client
        .channel('chat-tab-updates')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          callback: (_) => _scheduleRefresh(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'chat_room_members',
          callback: (_) => _scheduleRefresh(),
        )
        .subscribe();
  }

  void _scheduleRefresh() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (mounted) ref.invalidate(myChatRoomsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(myChatRoomsProvider);
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        roomsAsync.when(
          data: (rooms) => _buildList(context, ref, rooms, topPadding),
          loading: () => Padding(
            padding: EdgeInsets.only(top: topPadding + _headerHeight),
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (err, _) => Padding(
            padding: EdgeInsets.only(top: topPadding + _headerHeight),
            child: Center(
              child: Text(
                '채팅방을 불러오지 못했습니다\n$err',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyRegular.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
        ),
        _buildHeader(context, topPadding),
      ],
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<ChatRoom> rooms,
    double topPadding,
  ) {
    if (rooms.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: topPadding + _headerHeight),
        child: Center(
          child: Text(
            '아직 채팅방이 없어요\n팀에 가입하면 자동으로 방이 생깁니다',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyRegular.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(myChatRoomsProvider),
      child: ListView.separated(
        padding: EdgeInsets.only(top: topPadding + _headerHeight),
        itemCount: rooms.length,
        separatorBuilder: (_, __) => Divider(
          height: 0.5,
          indent: AppSpacing.base + 52 + AppSpacing.md,
          color: AppColors.iconInactive.withValues(alpha: 0.3),
        ),
        itemBuilder: (context, index) {
          final room = rooms[index];
          return ChatRoomCell(
            room: room,
            onTap: () => context.push('/chat', extra: room),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double topPadding) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: Colors.white.withValues(alpha: 0.85),
            padding: EdgeInsets.only(
              top: topPadding + AppSpacing.sm,
              left: AppSpacing.xl,
              right: AppSpacing.xl,
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
        ),
      ),
    );
  }
}
