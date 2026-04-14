import 'package:flutter/widgets.dart';

/// 라운딩 토큰. `BorderRadius.circular` 캐시.
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

  // ── Cached BorderRadius (빌드마다 재생성 방지) ──
  static final smoothXs = BorderRadius.circular(xs);
  static final smoothSm = BorderRadius.circular(sm);
  static final smoothMd = BorderRadius.circular(md);
  static final smoothButton = BorderRadius.circular(button);
  static final smoothLg = BorderRadius.circular(lg);
  static final smoothXl = BorderRadius.circular(xl);
  static final smoothFull = BorderRadius.circular(full);

  /// 비표준 값용 팩토리
  static BorderRadius smooth(double radius) {
    return BorderRadius.circular(radius);
  }
}
