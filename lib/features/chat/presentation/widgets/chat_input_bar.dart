import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

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
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x08000000),
            offset: Offset(0, -1),
            blurRadius: 4,
          ),
        ],
      ),
      padding: const EdgeInsets.only(
        left: AppSpacing.base,
        right: AppSpacing.sm,
        top: AppSpacing.sm,
        bottom: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: TextField(
                controller: widget.controller,
                decoration: InputDecoration(
                  hintText: '메시지를 입력하세요',
                  hintStyle: AppTextStyles.bodyRegular.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base,
                    vertical: AppSpacing.md,
                  ),
                  isDense: true,
                ),
                style: AppTextStyles.bodyRegular.copyWith(
                  color: AppColors.textPrimary,
                ),
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: _hasText ? _send : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _hasText ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_upward_rounded,
                color: _hasText ? Colors.white : AppColors.textTertiary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
