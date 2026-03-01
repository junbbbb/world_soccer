import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static const _heroFont = 'NanumSquareNeo';
  static const _contentFont = 'Pretendard';

  static const heading = TextStyle(
    fontFamily: _contentFont,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const title = TextStyle(
    fontFamily: _contentFont,
    fontSize: 16,
    fontWeight: FontWeight.w900,
  );

  static const body = TextStyle(
    fontFamily: _contentFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const caption = TextStyle(
    fontFamily: _contentFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static const teamName = TextStyle(
    fontFamily: _heroFont,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const playerName = TextStyle(
    fontFamily: _contentFont,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static const badgeNumber = TextStyle(
    fontFamily: _contentFont,
    fontSize: 12,
    fontWeight: FontWeight.w900,
    color: Colors.white,
  );

  static const buttonText = TextStyle(
    fontFamily: _contentFont,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
}
