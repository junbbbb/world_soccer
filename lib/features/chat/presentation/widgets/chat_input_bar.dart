import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSend;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _send() {
    widget.onSend(widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.chatPanel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5.5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // + 버튼
                _iconButton(Icons.add, size: 32, onTap: () {}),
                const SizedBox(width: 8),
                // 텍스트 입력
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: AppColors.chatInputBorder,
                        width: 0.33,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 105),
                            child: TextField(
                              controller: widget.controller,
                              decoration: const InputDecoration(
                                hintText: 'Message',
                                hintStyle: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.chatTextSecondary,
                                  letterSpacing: -0.32,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.fromLTRB(10, 6, 0, 6),
                                isDense: true,
                              ),
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppColors.chatTextPrimary,
                                letterSpacing: -0.32,
                                height: 21 / 16,
                              ),
                              maxLines: 5,
                              minLines: 1,
                              textInputAction: TextInputAction.newline,
                            ),
                          ),
                        ),
                        // 스티커 아이콘
                        const Padding(
                          padding: EdgeInsets.only(right: 9, bottom: 4),
                          child: Icon(
                            Icons.emoji_emotions_outlined,
                            size: 24,
                            color: AppColors.chatTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 카메라
                if (!_hasText)
                  _iconButton(Icons.camera_alt_rounded, size: 32, onTap: () {}),
                if (!_hasText) const SizedBox(width: 7),
                // 마이크 또는 전송
                _hasText
                    ? _iconButton(Icons.send_rounded, size: 32, onTap: _send,
                        color: AppColors.primary)
                    : _iconButton(Icons.mic_none_rounded, size: 32, onTap: () {}),
              ],
            ),
          ),
          // 하단 안전영역
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _iconButton(
    IconData icon, {
    double size = 32,
    VoidCallback? onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(icon, size: size * 0.65, color: color ?? AppColors.chatTextSecondary),
      ),
    );
  }
}
