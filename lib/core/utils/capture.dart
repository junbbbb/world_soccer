import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// `RepaintBoundary` GlobalKey 하위를 PNG 바이트로 캡처.
///
/// 공유/크롭 등 위젯 → 이미지 변환 공용 헬퍼. `pixelRatio` 는 기본 3x.
/// 내부 `ui.Image` 는 인코딩 후 dispose 되어 누수 없음.
Future<Uint8List> captureWidgetAsPng(
  GlobalKey key, {
  double pixelRatio = 3,
}) async {
  final boundary =
      key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) {
    throw StateError('캡처 대상 위젯을 찾을 수 없습니다');
  }
  final image = await boundary.toImage(pixelRatio: pixelRatio);
  try {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('이미지 인코딩 실패');
    }
    return byteData.buffer.asUint8List();
  } finally {
    image.dispose();
  }
}
