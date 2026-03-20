import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../chat_tab.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.isFirstInGroup,
    required this.isLastInGroup,
    required this.showTail,
    this.isGroup = true,
  });

  final ChatMessage message;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final bool showTail;
  final bool isGroup;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.73;

    return Padding(
      padding: EdgeInsets.only(
        top: isFirstInGroup ? AppSpacing.md : 2,
        bottom: message.reaction != null ? 20 : 0,
      ),
      child: message.isMe
          ? _buildMyBubble(maxWidth)
          : _buildFriendBubble(maxWidth),
    );
  }

  // ── 내 메시지 (오른쪽, 초록) ──
  Widget _buildMyBubble(double maxWidth) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                showTail
                    ? CustomPaint(
                        painter: _BubbleWithTailPainter(
                          color: AppColors.bubbleMe,
                          borderColor: AppColors.bubbleBorder,
                          isMe: true,
                        ),
                        child: Container(
                          constraints:
                              BoxConstraints(maxWidth: maxWidth, minWidth: 88),
                          margin: const EdgeInsets.only(right: 8),
                          child: _buildMyContent(),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Container(
                          constraints:
                              BoxConstraints(maxWidth: maxWidth, minWidth: 88),
                          decoration: BoxDecoration(
                            color: AppColors.bubbleMe,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.bubbleBorder,
                              width: 0.66,
                            ),
                          ),
                          child: _buildMyContent(),
                        ),
                      ),
                if (message.reaction != null)
                  Positioned(
                    bottom: -20,
                    right: 10,
                    child: _buildReaction(isMe: true),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 타임스탬프 영역 예약 폭 (시간 + 체크마크 + 여유)
  static const double _myTimestampSpacerWidth = 62;
  static const double _friendTimestampSpacerWidth = 45;

  Widget _buildMyContent() {
    final hasImage = message.imageUrl != null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          // ── 콘텐츠 영역 ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasImage)
                Container(
                  height: 200,
                  width: double.infinity,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.chatBackground,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      message.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.image,
                            size: 48, color: AppColors.chatTextSecondary),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  10,
                  hasImage ? 3 : 6,
                  10,
                  6,
                ),
                child: Text.rich(
                  TextSpan(
                    text: message.text,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 15.8,
                      fontWeight: FontWeight.w400,
                      height: 21 / 15.8,
                      letterSpacing: -0.2,
                      color: AppColors.chatTextPrimary,
                    ),
                    children: [
                      // 타임스탬프 자리 확보용 투명 스페이서
                      WidgetSpan(
                        alignment: PlaceholderAlignment.bottom,
                        child: SizedBox(
                          width: _myTimestampSpacerWidth,
                          height: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // ── 타임스탬프: 버블 우측·하단 테두리 기준 ──
          Positioned(
            bottom: 4,
            right: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.55,
                    color: AppColors.chatTextSecondary,
                  ),
                ),
                const SizedBox(width: 2),
                const _ReadCheckMark(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 상대 메시지 (왼쪽, 흰색) ──
  Widget _buildFriendBubble(double maxWidth) {
    final colorIndex = message.senderId % AppColors.groupNameColors.length;
    final nameColor = AppColors.groupNameColors[colorIndex];

    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isGroup)
            SizedBox(
              width: 28,
              child: showTail
                  ? CircleAvatar(
                      radius: 14,
                      backgroundColor: nameColor.withValues(alpha: 0.15),
                      child: Text(
                        message.senderName[0],
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: nameColor,
                        ),
                      ),
                    )
                  : null,
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    showTail
                        ? CustomPaint(
                            painter: _BubbleWithTailPainter(
                              color: AppColors.bubbleFriend,
                              borderColor: AppColors.bubbleBorder,
                              isMe: false,
                            ),
                            child: Container(
                              constraints: BoxConstraints(
                                  maxWidth: maxWidth, minWidth: 88),
                              margin: const EdgeInsets.only(left: 8),
                              child: _buildFriendContent(nameColor),
                            ),
                          )
                        : Padding(
                            // 꼬리 없어도 꼬리 영역(8px)만큼 왼쪽 여백 → 정렬 통일
                            padding: const EdgeInsets.only(left: 8),
                            child: Container(
                              constraints:
                                  BoxConstraints(maxWidth: maxWidth, minWidth: 88),
                              decoration: BoxDecoration(
                                color: AppColors.bubbleFriend,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.bubbleBorder,
                                  width: 0.66,
                                ),
                              ),
                              child: _buildFriendContent(nameColor),
                            ),
                          ),
                    if (message.reaction != null)
                      Positioned(
                        bottom: -20,
                        left: 10,
                        child: _buildReaction(isMe: false),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendContent(Color nameColor) {
    final hasReply = message.replyToText != null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          // ── 콘텐츠 영역 ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── 1) 이름 (그룹 채팅, 그룹 내 첫 메시지) ──
              if (isGroup && isFirstInGroup)
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 6, 10, hasReply ? 2 : 0),
                  child: Text(
                    message.senderName,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 15 / 14,
                      letterSpacing: -0.07,
                      color: nameColor,
                    ),
                  ),
                ),
              // ── 2) 인용 (reply) ──
              if (hasReply) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.quoteBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          Container(width: 4, color: AppColors.quoteBar),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(9, 8, 9, 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.replyToSender ?? 'You',
                                    style: const TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      height: 19 / 14,
                                      letterSpacing: -0.14,
                                      color: AppColors.quoteBar,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    message.replyToText!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      height: 16 / 12,
                                      color: AppColors.quoteText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              // ── 3) 메시지 내용 (타임스탬프 스페이서 포함) ──
              Padding(
                padding: EdgeInsets.fromLTRB(
                  10,
                  hasReply ? 3 : (isGroup && isFirstInGroup ? 2 : 6),
                  10,
                  6,
                ),
                child: Text.rich(
                  TextSpan(
                    text: message.text,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 15.8,
                      fontWeight: FontWeight.w400,
                      height: 21 / 15.8,
                      letterSpacing: -0.2,
                      color: AppColors.chatTextPrimary,
                    ),
                    children: [
                      // 타임스탬프 자리 확보용 투명 스페이서
                      WidgetSpan(
                        alignment: PlaceholderAlignment.bottom,
                        child: SizedBox(
                          width: _friendTimestampSpacerWidth,
                          height: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // ── 타임스탬프: 버블 우측·하단 테두리 기준 ──
          Positioned(
            bottom: 4,
            right: 8,
            child: Text(
              _formatTime(message.timestamp),
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.55,
                color: AppColors.chatTextSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReaction({required bool isMe}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: const Color(0xFFF0E9DF)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.bubbleBorder,
            offset: Offset(0, 0.66),
          ),
        ],
      ),
      child: Text(
        message.reaction!,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  static String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ── 읽음 체크마크 ──
class _ReadCheckMark extends StatelessWidget {
  const _ReadCheckMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 17,
      height: 17,
      child: CustomPaint(painter: _CheckPainter()),
    );
  }
}

class _CheckPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.checkRead
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path1 = Path()
      ..moveTo(size.width * 0.15, size.height * 0.5)
      ..lineTo(size.width * 0.4, size.height * 0.72)
      ..lineTo(size.width * 0.7, size.height * 0.3);
    canvas.drawPath(path1, paint);

    final path2 = Path()
      ..moveTo(size.width * 0.35, size.height * 0.5)
      ..lineTo(size.width * 0.55, size.height * 0.72)
      ..lineTo(size.width * 0.88, size.height * 0.3);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ══════════════════════════════════════════════════════════════
// ── 버블 + 꼬리를 하나의 통합 Shape로 그리는 CustomPainter
// ══════════════════════════════════════════════════════════════
//
// ★ 핵심: 버블과 꼬리를 하나의 Path로 합쳐서 그림
// → border가 끊기지 않고 자연스럽게 이어짐
// → z-order 문제 없음
// → 꼬리 모양이 정확히 WhatsApp과 동일
//
// Me (우측 꼬리):
//   ┌─────────────────────┐
//   │                     │
//   │      bubble         │
//   │                     │
//   └─────────────────────┘\
//                            \  ← 꼬리 (우측 하단)
//                            /
//
// Friend (좌측 꼬리):
//                ┌─────────────────────┐
//               /│                     │
//   꼬리 →    /  │      bubble         │
//               \│                     │
//                └─────────────────────┘
//
class _BubbleWithTailPainter extends CustomPainter {
  _BubbleWithTailPainter({
    required this.color,
    required this.borderColor,
    required this.isMe,
  });

  final Color color;
  final Color borderColor;
  final bool isMe;

  static const double _radius = 12;
  static const double _tailWidth = 8;
  static const double _tailHeight = 14;

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 0.66
      ..style = PaintingStyle.stroke;

    final Path path;

    if (isMe) {
      path = _buildMePath(size);
    } else {
      path = _buildFriendPath(size);
    }

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  // ── 내 메시지: 버블 + 우측 하단 꼬리 (WhatsApp iOS 스타일) ──
  // child에 margin-right: 8 적용 → 버블 body는 0~(width-8), 꼬리는 우측 8px
  Path _buildMePath(Size size) {
    final r = _radius;
    final bw = size.width;
    final bh = size.height;
    final br = bw - _tailWidth; // 버블 body 우측 끝

    final path = Path();

    // 좌상단 모서리
    path.moveTo(r, 0);
    path.lineTo(br - r, 0);
    path.quadraticBezierTo(br, 0, br, r);

    // 우측 변 → 꼬리 시작점
    path.lineTo(br, bh - _tailHeight);

    // ── 꼬리: cubicTo로 자연스러운 S-curve ──
    // 1) 우측 변에서 바깥(우하단)으로 부드럽게 나감
    path.cubicTo(
      br, bh - _tailHeight * 0.25, // cp1: 거의 수직으로 내려감
      br + _tailWidth * 0.6, bh - 3, // cp2: 꼬리 끝 쪽으로 커브
      br + _tailWidth, bh, // end: 꼬리 끝점 (우하단)
    );
    // 2) 꼬리 끝에서 버블 하단으로 되돌아옴 (sharp hook)
    path.cubicTo(
      br + _tailWidth * 0.2, bh + 0.5, // cp1: 꼬리 끝 근처
      br, bh, // cp2: 버블 하단 모서리
      br - r * 0.5, bh, // end: 하단 변 위
    );

    // 하단 변 → 좌하단 모서리
    path.lineTo(r, bh);
    path.quadraticBezierTo(0, bh, 0, bh - r);

    // 좌측 변 → 좌상단 모서리
    path.lineTo(0, r);
    path.quadraticBezierTo(0, 0, r, 0);

    path.close();
    return path;
  }

  // ── 상대 메시지: 버블 + 좌측 하단 꼬리 (WhatsApp iOS 스타일) ──
  // child에 margin-left: 8 적용 → 꼬리는 좌측 8px, 버블 body는 8~width
  Path _buildFriendPath(Size size) {
    final r = _radius;
    final bw = size.width;
    final bh = size.height;
    final bl = _tailWidth; // 버블 body 좌측 시작

    final path = Path();

    // 좌상단 모서리 (꼬리 영역 오른쪽에서 시작)
    path.moveTo(bl + r, 0);
    path.lineTo(bw - r, 0);
    path.quadraticBezierTo(bw, 0, bw, r);

    // 우측 변
    path.lineTo(bw, bh - r);
    path.quadraticBezierTo(bw, bh, bw - r, bh);

    // 하단 변 → 꼬리 시작
    path.lineTo(bl + r * 0.5, bh);

    // ── 꼬리: cubicTo로 자연스러운 S-curve ──
    // 1) 하단에서 좌하단으로 나감
    path.cubicTo(
      bl, bh, // cp1: 버블 좌하단 모서리
      bl - _tailWidth * 0.2, bh + 0.5, // cp2: 꼬리 끝 근처
      0, bh, // end: 꼬리 끝점 (좌하단)
    );
    // 2) 꼬리 끝에서 버블 좌측 변으로 되돌아옴 (sharp hook)
    path.cubicTo(
      bl - _tailWidth * 0.6, bh - 3, // cp1: 꼬리 끝 쪽에서 올라감
      bl, bh - _tailHeight * 0.25, // cp2: 거의 수직으로 올라감
      bl, bh - _tailHeight, // end: 좌측 변 위
    );

    // 좌측 변 → 좌상단 모서리
    path.lineTo(bl, r);
    path.quadraticBezierTo(bl, 0, bl + r, 0);

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
