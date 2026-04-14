import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../types/team.dart';
import 'opponent_logo.dart' show opponentInitial;

/// 팀 로고 렌더 통합 위젯.
///
/// - `team.logoUrl` 있으면 네트워크 이미지 (실패 시 이니셜 fallback)
/// - 없으면 `team.logoColor` 배경에 팀 이니셜
///
/// 우리팀/상대팀 구분 없이 동일하게 사용.
class TeamLogoView extends StatelessWidget {
  const TeamLogoView({
    super.key,
    required this.team,
    this.size = 52,
    this.borderRadius,
    this.textColor,
    this.fontSize,
  });

  /// 최소 정보만 가진 팀. DB `Team` 를 직접 넘겨도 되고,
  /// 일부 상황(더미)에서 아래 `.byName` 생성자 사용.
  final Team team;
  final double size;
  final BorderRadius? borderRadius;
  final Color? textColor;
  final double? fontSize;

  /// DB Team 없이 이름/색만 있을 때 (더미/미리보기용).
  factory TeamLogoView.byName({
    Key? key,
    required String name,
    String? logoUrl,
    String? logoColor,
    double size = 52,
    BorderRadius? borderRadius,
    Color? textColor,
    double? fontSize,
  }) {
    return TeamLogoView(
      key: key,
      team: Team(
        id: '',
        name: name,
        logoUrl: logoUrl,
        logoColor: logoColor,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      ),
      size: size,
      borderRadius: borderRadius,
      textColor: textColor,
      fontSize: fontSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.smoothSm;
    final url = team.logoUrl;
    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: radius,
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildMonogram(radius),
        ),
      );
    }
    return _buildMonogram(radius);
  }

  Widget _buildMonogram(BorderRadius radius) {
    final bg = _parseHex(team.logoColor) ?? AppColors.primary;
    final fg = textColor ?? _pickForeground(bg);
    final initial = opponentInitial(team.name);
    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        color: bg,
        child: Text(
          initial,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: fontSize ?? size * 0.46,
            fontWeight: FontWeight.w800,
            color: fg,
            height: 1.0,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}

/// `#RRGGBB` / `#AARRGGBB` hex 를 Color 로. 실패 시 null.
Color? _parseHex(String? hex) {
  if (hex == null) return null;
  var v = hex.trim();
  if (v.startsWith('#')) v = v.substring(1);
  if (v.length == 6) v = 'FF$v';
  if (v.length != 8) return null;
  final n = int.tryParse(v, radix: 16);
  if (n == null) return null;
  return Color(n);
}

/// 배경 밝기에 따라 흰/검정 텍스트 선택.
Color _pickForeground(Color bg) {
  final luminance = bg.computeLuminance();
  return luminance > 0.55 ? AppColors.textPrimary : Colors.white;
}

/// 팀 로고 기본 색상 팔레트 (B 모드 선택용).
/// 앱 디자인 톤에 맞춘 8색. 첫 번째(primary) 를 default 로 사용.
const kTeamLogoPalette = <String>[
  '#1572D1', // primary blue
  '#2563EB', // badge blue
  '#22A55B', // green
  '#F57F17', // mom orange
  '#E5484D', // error red
  '#7C3AED', // purple
  '#0F172A', // near-black
  '#F59E0B', // amber
];
