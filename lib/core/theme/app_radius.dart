import 'package:figma_squircle/figma_squircle.dart';

/// cornerSmoothing 1.0 기본, squircle 라운딩 시스템
class AppRadius {
  AppRadius._();

  // ── Scale ──
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double button = 14;
  static const double lg = 16;
  static const double xl = 20;
  static const double full = 100;

  // ── Cached SmoothBorderRadius (빌드마다 재생성 방지) ──
  static final smoothXs = SmoothBorderRadius(
    cornerRadius: xs,
    cornerSmoothing: 1.0,
  );
  static final smoothSm = SmoothBorderRadius(
    cornerRadius: sm,
    cornerSmoothing: 1.0,
  );
  static final smoothMd = SmoothBorderRadius(
    cornerRadius: md,
    cornerSmoothing: 1.0,
  );
  static final smoothButton = SmoothBorderRadius(
    cornerRadius: button,
    cornerSmoothing: 1.0,
  );
  static final smoothLg = SmoothBorderRadius(
    cornerRadius: lg,
    cornerSmoothing: 1.0,
  );

  /// 비표준 값용 팩토리
  static SmoothBorderRadius smooth(double radius) {
    return SmoothBorderRadius(
      cornerRadius: radius,
      cornerSmoothing: 1.0,
    );
  }
}
