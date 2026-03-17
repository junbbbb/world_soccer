import 'dart:math';

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand ──
  static const primary = Color(0xFF1572D1);
  static const primaryDark = Color(0xFF1C6EC3);
  static const badgeBlue = Color(0xFF2563EB);

  // ── Text ──
  static const textPrimary = Color(0xFF333D4B);
  static const textSecondary = Color(0xFF6B7684);
  static const textTertiary = Color(0xFF8E97A3);

  // ── Surface ──
  static const surface = Color(0xFFF2F4F6);
  static const surfaceLight = Color(0xFFF6F7F9);
  static const background = Colors.white;

  // ── Icon ──
  static const iconInactive = Color(0xFFD1D6DB);

  // ── Overlay ──
  static const overlayDark = Color(0x4D000000); // black 30%

  // ── Gradient ──
  static const headerGradient = LinearGradient(
    transform: GradientRotation(15 * pi / 180),
    stops: [0.38, 0.38],
    colors: [primaryDark, primary],
  );

  /// 상세 페이지 히어로 그라데이션 (좌→우)
  static const matchHeroGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    stops: [0.0, 0.5, 1.0],
    colors: [
      Color(0xFF1572D1),
      Color(0xFF1D74CD),
      Color(0xFF1562B2),
    ],
  );

  // ── Divider Gradients ──
  static const dividerGradientColors = [
    Color(0x009CBAD9),
    Color(0xCC9CBAD9),
    Color(0xFF9CBAD9),
    Color(0xCC9CBAD9),
    Color(0x00FFFFFF),
  ];

  static const headerDividerColors = [
    Color(0x00FFFFFF),
    Color(0x33BFDFFF),
    Color(0xFFBFDFFF),
    Color(0x33BFDFFF),
    Color(0x00FFFFFF),
  ];
}
