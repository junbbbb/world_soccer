import 'package:flutter/material.dart';

import '../lineup_design.dart';

/// 축구장 라인 페인터.
///
/// [color]/[strokeWidth] 를 외부에서 받음 — 라인업 빌더(흰 피치)와
/// 공유 카드(초록 피치)에서 다른 톤으로 사용 가능.
class PitchLinesPainter extends CustomPainter {
  const PitchLinesPainter({
    this.color = LineupColors.pitchLine,
    this.strokeWidth = 1.0,
  });

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    const inset = 8.0;
    final rect = Rect.fromLTRB(
      inset,
      inset,
      size.width - inset,
      size.height - inset,
    );
    canvas.drawRect(rect, paint);

    // 센터 라인
    canvas.drawLine(
      Offset(inset, size.height / 2),
      Offset(size.width - inset, size.height / 2),
      paint,
    );

    // 센터 서클
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.13,
      paint,
    );

    // 양 골 박스
    final boxW = size.width * 0.55;
    final boxH = size.height * 0.16;
    canvas.drawRect(
      Rect.fromLTWH((size.width - boxW) / 2, inset, boxW, boxH),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - boxW) / 2,
        size.height - inset - boxH,
        boxW,
        boxH,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant PitchLinesPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
