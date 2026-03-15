import 'package:flutter/material.dart';

/// 그림자 토큰
class AppShadows {
  AppShadows._();

  /// 헤더 그림자 (match_header 등)
  static const header = [
    BoxShadow(
      color: Color(0x406C849C),
      offset: Offset(0, 2),
      blurRadius: 8,
    ),
  ];

  /// 하단 네비게이션 바 그림자
  static const bottomBar = [
    BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, -1),
      blurRadius: 4,
    ),
  ];

  /// 플로팅/elevated 요소 그림자
  static const elevated = [
    BoxShadow(
      color: Color(0x21000000),
      offset: Offset(0, -1),
      blurRadius: 6,
    ),
  ];
}
