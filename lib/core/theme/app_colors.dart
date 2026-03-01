import 'dart:math';

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Header gradient
  static const gradientStart = Color(0xFF1C6EC3);
  static const gradientEnd = Color(0xFF1572D1);

  // Accent
  static const accentBlue = Color(0xFF1572D1);

  // Surfaces
  static const surface = Color(0xFFF2F4F6);
  static const background = Colors.white;

  // Text
  static const textPrimary = Colors.black;
  static const textSecondary = Color(0xFF666666);

  // Badge
  static const badgeBlue = Color(0xFF2563EB);

  // Header gradient: angled linear gradient
  static const headerGradient = LinearGradient(
    transform: GradientRotation(15 * pi / 180),
    stops: [0.38, 0.38],
    colors: [gradientStart, gradientEnd],
  );
}
