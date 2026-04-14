import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';

/// 상대팀 기본 로고 — `defaultteamlogo.svg` 위 가운데 원 안에 팀 이니셜을 표시.
///
/// [teamName] 예: `FC뽀잉` → `B`, `드림FC` → `D`, `올스타FC` → `O`
class OpponentLogo extends StatelessWidget {
  const OpponentLogo({
    super.key,
    required this.teamName,
    this.size = 52,
    this.borderRadius,
    this.textColor,
    this.fontSize,
  });

  final String teamName;
  final double size;
  final BorderRadius? borderRadius;
  final Color? textColor;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final initial = opponentInitial(teamName);
    return ClipRRect(
      borderRadius: borderRadius ?? AppRadius.smoothSm,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/images/defaultteamlogo.png',
              width: size,
              height: size,
              fit: BoxFit.contain,
            ),
            Text(
              initial,
              style: TextStyle(
                fontSize: fontSize ?? size * 0.38,
                fontWeight: FontWeight.w800,
                color: textColor ?? Colors.white,
                height: 1.0,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 팀 이름에서 "FC"를 제거한 뒤 첫 글자의 이니셜을 반환.
///
/// - 한글 초성은 영문 대표 글자로 매핑 (예: 뽀→B, 쏘→S, 드→D)
/// - 영문/숫자는 대문자로 반환
/// - 비어 있으면 `?`
String opponentInitial(String teamName) {
  final name =
      teamName.replaceAll(RegExp(r'FC', caseSensitive: false), '').trim();
  if (name.isEmpty) return '?';

  final first = name.runes.first;

  // Hangul Syllables: 0xAC00 ~ 0xD7A3
  if (first >= 0xAC00 && first <= 0xD7A3) {
    final syllableIdx = first - 0xAC00;
    final choseongIdx = syllableIdx ~/ (21 * 28);
    const choseong = [
      'G', // ㄱ
      'G', // ㄲ
      'N', // ㄴ
      'D', // ㄷ
      'D', // ㄸ
      'R', // ㄹ
      'M', // ㅁ
      'B', // ㅂ
      'B', // ㅃ
      'S', // ㅅ
      'S', // ㅆ
      'O', // ㅇ
      'J', // ㅈ
      'J', // ㅉ
      'C', // ㅊ
      'K', // ㅋ
      'T', // ㅌ
      'P', // ㅍ
      'H', // ㅎ
    ];
    return choseong[choseongIdx];
  }

  // Hangul Jamo Choseong: 0x1100 ~ 0x1112
  if (first >= 0x1100 && first <= 0x1112) {
    const jamo = [
      'G', 'G', 'N', 'D', 'D', 'R', 'M', 'B', 'B',
      'S', 'S', 'O', 'J', 'J', 'C', 'K', 'T', 'P', 'H',
    ];
    return jamo[first - 0x1100];
  }

  return String.fromCharCode(first).toUpperCase();
}
