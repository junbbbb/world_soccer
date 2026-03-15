import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../chat_tab.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.isFirstInGroup,
    required this.isLastInGroup,
  });

  final ChatMessage message;
  final bool isFirstInGroup;
  final bool isLastInGroup;

  // Telegram 스타일 7색 아바타 배경
  static const _avatarColors = [
    Color(0xFFE57373), // Red
    Color(0xFFFFB74D), // Orange
    Color(0xFF9575CD), // Violet
    Color(0xFF81C784), // Green
    Color(0xFF4DD0E1), // Cyan
    Color(0xFF64B5F6), // Blue
    Color(0xFFF06292), // Pink
  ];

  // 이름 표시 색상 (아바타보다 약간 진하게)
  static const _nameColors = [
    Color(0xFFE17076), // Red
    Color(0xFFE09B55), // Orange
    Color(0xFF7B72E9), // Violet
    Color(0xFF55B561), // Green
    Color(0xFF42B5CF), // Cyan
    Color(0xFF549BD2), // Blue
    Color(0xFFEE7AAE), // Pink
  ];

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.72;

    return Padding(
      padding: EdgeInsets.only(
        top: isFirstInGroup ? AppSpacing.md : AppSpacing.xxs,
      ),
      child: message.isMe ? _buildMyBubble(maxWidth) : _buildOtherBubble(maxWidth),
    );
  }

  Widget _buildMyBubble(double maxWidth) {
    return Padding(
      padding: const EdgeInsets.only(left: 56),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: Radius.circular(isFirstInGroup ? 18 : 6),
              bottomLeft: const Radius.circular(18),
              bottomRight: Radius.circular(isLastInGroup ? 4 : 6),
            ),
          ),
          child: _buildContent(
            textColor: Colors.white,
            timeColor: Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildOtherBubble(double maxWidth) {
    const avatarSize = 36.0;
    final colorIndex = message.senderId % _avatarColors.length;

    return Padding(
      padding: const EdgeInsets.only(right: 56),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 아바타 (그룹 마지막 메시지에만 표시)
          if (isLastInGroup)
            CircleAvatar(
              radius: avatarSize / 2,
              backgroundColor: _avatarColors[colorIndex],
              child: Text(
                message.senderName[0],
                style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
              ),
            )
          else
            const SizedBox(width: avatarSize),
          const SizedBox(width: AppSpacing.sm),
          // 이름 + 버블
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isFirstInGroup)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.xs,
                      bottom: AppSpacing.xxs,
                    ),
                    child: Text(
                      message.senderName,
                      style: AppTextStyles.captionMedium.copyWith(
                        color: _nameColors[colorIndex],
                      ),
                    ),
                  ),
                Container(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isFirstInGroup ? 18 : 6),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isLastInGroup ? 4 : 6),
                      bottomRight: const Radius.circular(18),
                    ),
                  ),
                  child: _buildContent(
                    textColor: AppColors.textPrimary,
                    timeColor: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent({required Color textColor, required Color timeColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message.text,
          style: AppTextStyles.bodyRegular.copyWith(color: textColor),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Align(
          alignment: Alignment.bottomRight,
          child: Text(
            _formatTime(message.timestamp),
            style: AppTextStyles.caption.copyWith(
              color: timeColor,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  static String _formatTime(DateTime time) {
    final period = time.hour < 12 ? '오전' : '오후';
    final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    return '$period $hour:${time.minute.toString().padLeft(2, '0')}';
  }
}
