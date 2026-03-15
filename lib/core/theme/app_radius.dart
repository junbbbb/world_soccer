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

  /// figma_squircle SmoothBorderRadius 헬퍼
  static SmoothBorderRadius smooth(double radius) {
    return SmoothBorderRadius(
      cornerRadius: radius,
      cornerSmoothing: 1.0,
    );
  }

  /// ClipSmoothRect 용 SmoothBorderRadius.all 헬퍼
  static SmoothBorderRadius smoothAll(double radius) {
    return SmoothBorderRadius.all(
      SmoothRadius(cornerRadius: radius, cornerSmoothing: 1.0),
    );
  }
}
