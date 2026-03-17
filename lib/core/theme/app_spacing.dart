import 'package:flutter/material.dart';

/// 8px 그리드 기반 여백 시스템
class AppSpacing {
  AppSpacing._();

  // ── Scale ──
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
  static const double xxxxl = 80;

  // ── Common EdgeInsets ──
  static const EdgeInsets paddingPage = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingSection =
      EdgeInsets.symmetric(horizontal: lg, vertical: xl);
}
