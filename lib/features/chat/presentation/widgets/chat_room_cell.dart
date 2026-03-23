import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../chat_tab.dart';

class ChatRoomCell extends StatelessWidget {
  const ChatRoomCell({
    super.key,
    required this.room,
    required this.onTap,
  });

  final ChatRoom room;
  final VoidCallback onTap;

  static const _avatarColors = [
    Color(0xFFE57373),
    Color(0xFFFFB74D),
    Color(0xFF9575CD),
    Color(0xFF81C784),
    Color(0xFF4DD0E1),
    Color(0xFF64B5F6),
    Color(0xFFF06292),
  ];

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            // 아바타
            _buildAvatar(),
            const SizedBox(width: AppSpacing.md),
            // 이름 + 마지막 메시지
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                room.name,
                                style: AppTextStyles.heading.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '${room.memberCount}',
                              style: AppTextStyles.labelRegular.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                            if (room.isMuted) ...[
                              const SizedBox(width: AppSpacing.xs),
                              Icon(
                                Icons.notifications_off_outlined,
                                size: 14,
                                color: AppColors.textTertiary,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _formatTime(room.lastMessageTime),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${room.lastMessageSender}: ${room.lastMessage}',
                          style: AppTextStyles.bodyRegular.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (room.unreadCount > 0) ...[
                        const SizedBox(width: AppSpacing.sm),
                        _buildUnreadBadge(),
                      ] else if (room.isPinned) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Icon(
                          Icons.push_pin,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    const size = 52.0;

    if (room.logoPath != null) {
      return ClipOval(
        child: Image.asset(
          room.logoPath!,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    final colorIndex = room.id.hashCode.abs() % _avatarColors.length;
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: _avatarColors[colorIndex],
      child: Text(
        room.name[0],
        style: AppTextStyles.sectionTitle.copyWith(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildUnreadBadge() {
    final text = room.unreadCount > 99 ? '99+' : '${room.unreadCount}';
    return Container(
      constraints: const BoxConstraints(minWidth: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: room.isMuted ? AppColors.textTertiary : const Color(0xFFE5484D),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  static String _formatTime(DateTime time) {
    final now = DateTime(2026, 3, 15, 18, 0); // 더미 기준 시간
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(time.year, time.month, time.day);
    final diff = today.difference(messageDay).inDays;

    if (diff == 0) {
      final period = time.hour < 12 ? '오전' : '오후';
      final hour =
          time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
      return '$period $hour:${time.minute.toString().padLeft(2, '0')}';
    } else if (diff == 1) {
      return '어제';
    } else if (diff < 7) {
      const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
      return weekdays[time.weekday - 1];
    } else {
      return '${time.month}/${time.day}';
    }
  }
}
