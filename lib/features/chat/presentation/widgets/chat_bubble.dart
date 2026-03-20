import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
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
  static const _nameColor = Color(0xFF8A8D92);
  static const _avatarSize = 28.0;

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
                  topRight: const Radius.circular(18),
                  bottomLeft: const Radius.circular(18),
                  bottomRight: Radius.circular(isLastInGroup ? 4 : 18),
                ),
              ),
              child: Text(
                message.text,
                style: _msgStyle(isSent: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceived(BuildContext context) {
    final colorIndex = message.senderId % _avatarColors.length;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 2),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isFirstInGroup)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4, left: 4),
                    child: Text(
                      message.senderName,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _nameColor,
                      ),
                    ),
                  ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * .72,
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  decoration: BoxDecoration(
                    color: _receivedColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isLastInGroup ? 4 : 18),
                      bottomRight: const Radius.circular(18),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: _msgStyle(isSent: false),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(int colorIndex) {
    if (message.avatarPath != null) {
      return ClipSmoothRect(
        radius: AppRadius.smoothSm,
        child: Image.asset(
          message.avatarPath!,
          width: _avatarSize,
          height: _avatarSize,
          fit: BoxFit.cover,
        ),
      );
    }
    return ClipSmoothRect(
      radius: AppRadius.smoothSm,
      child: Container(
        width: _avatarSize,
        height: _avatarSize,
        color: _avatarColors[colorIndex],
        alignment: Alignment.center,
        child: Text(
          message.senderName[0],
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
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

}
