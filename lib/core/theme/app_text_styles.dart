import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static const _pretendard = 'Pretendard';
  static const _scDream = 'SCDream';
  static const _barlowCondensed = 'Barlow Condensed';

  // ── Titles ──
  static const pageTitle = TextStyle(
    fontFamily: _scDream,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static const sectionTitle = TextStyle(
    fontFamily: _pretendard,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  // ── Heading ──
  static const heading = TextStyle(
    fontFamily: _pretendard,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  // ── Body (15px) ──
  static const body = TextStyle(
    fontFamily: _pretendard,
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  static const bodyRegular = TextStyle(
    fontFamily: _pretendard,
    fontSize: 15,
    fontWeight: FontWeight.w400,
  );

  // ── Labels (14px) ──
  static const label = TextStyle(
    fontFamily: _pretendard,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static const labelMedium = TextStyle(
    fontFamily: _pretendard,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const labelRegular = TextStyle(
    fontFamily: _pretendard,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  // ── Captions (12~13px) ──
  static const captionBold = TextStyle(
    fontFamily: _pretendard,
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );

  static const captionMedium = TextStyle(
    fontFamily: _pretendard,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  static const caption = TextStyle(
    fontFamily: _pretendard,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  // ── Buttons ──
  static const buttonPrimary = TextStyle(
    fontFamily: _pretendard,
    fontSize: 17,
    fontWeight: FontWeight.w700,
  );

  static const buttonSecondary = TextStyle(
    fontFamily: _pretendard,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // ── Match-specific ──
  static const teamName = TextStyle(
    fontFamily: _scDream,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const matchInfo = TextStyle(
    fontFamily: _scDream,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static const timeBadge = TextStyle(
    fontFamily: _pretendard,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 0.8,
    color: Colors.white,
  );

  static const timeDisplay = TextStyle(
    fontFamily: _barlowCondensed,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  );
}
