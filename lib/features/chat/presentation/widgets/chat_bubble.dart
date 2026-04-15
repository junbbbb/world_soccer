import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../types/chat.dart';

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

  static const _avatarColors = [
    Color(0xFFE57373),
    Color(0xFFFFB74D),
    Color(0xFF9575CD),
    Color(0xFF81C784),
    Color(0xFF4DD0E1),
    Color(0xFF64B5F6),
    Color(0xFFF06292),
  ];

  // Messenger 색상
  static const _sentColor = Color(0xFF007AFF);
  static const _receivedColor = Color(0xFFF1F2F6);
  static const _sentTextColor = Colors.white;
  static const _receivedTextColor = Color(0xFF000000);
  static const _avatarSize = 42.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: isFirstInGroup ? AppSpacing.md : AppSpacing.xxs,
      ),
      child: message.isMe ? _buildSent(context) : _buildReceived(context),
    );
  }

  Widget _buildSent(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(left: 56, right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * .72,
              ),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              decoration: BoxDecoration(
                color: _sentColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: Radius.circular(isFirstInGroup ? 18 : 4),
                  bottomLeft: const Radius.circular(18),
                  bottomRight: const Radius.circular(4),
                ),
              ),
              child: Text(
                message.text,
                style: _msgStyle(isSent: true),
              ),
            ),
            if (isLastInGroup)
              Padding(
                padding: const EdgeInsets.only(top: 3, right: 4),
                child: Text(
                  _formatTime(message.timestamp),
                  style: _metaStyle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceived(BuildContext context) {
    final colorIndex = message.senderId.hashCode.abs() % _avatarColors.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: SizedBox(
                width: _avatarSize,
                height: _avatarSize,
                child: isLastInGroup ? _buildAvatar(colorIndex) : null,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(right: 56),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * .72,
                    minHeight: _avatarSize,
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  decoration: BoxDecoration(
                    color: _receivedColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isFirstInGroup ? 18 : 4),
                      topRight: const Radius.circular(18),
                      bottomLeft: const Radius.circular(4),
                      bottomRight: const Radius.circular(18),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: _msgStyle(isSent: false),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (isLastInGroup)
          Padding(
            padding: const EdgeInsets.only(top: 3, left: 66),
            child: Text(
              '${message.senderName} · ${_formatTime(message.timestamp)}',
              style: _metaStyle,
            ),
          ),
      ],
    );
  }

  Widget _buildAvatar(int colorIndex) {
    if (message.avatarPath != null) {
      return ClipOval(
        child: Image.asset(
          message.avatarPath!,
          width: _avatarSize,
          height: _avatarSize,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: _avatarSize,
      height: _avatarSize,
      decoration: BoxDecoration(
        color: _avatarColors[colorIndex],
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        message.senderName.isNotEmpty ? message.senderName[0] : '?',
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  static TextStyle _msgStyle({required bool isSent}) => TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 17,
        fontWeight: FontWeight.w400,
        height: 1.29,
        color: isSent ? _sentTextColor : _receivedTextColor,
      );

  static const _metaStyle = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: Color(0xFF8A8D92),
  );

  static String _formatTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = h < 12 ? '오전' : '오후';
    final hour12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$period $hour12:$m';
  }
}
