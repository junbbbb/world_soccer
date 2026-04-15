import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../types/team.dart';
import 'opponent_logo.dart';

/// 팀 로고 렌더 통합 위젯.
///
/// - `team.logoUrl` 있으면 네트워크 이미지 (실패 시 기본 로고 fallback)
/// - 없으면 기본 로고: `OpponentLogo` 스타일(방패 이미지 + 이니셜)
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
          errorBuilder: (_, __, ___) => _buildDefault(radius),
        ),
      );
    }
    return _buildDefault(radius);
  }

  /// 업로드된 사진이 없을 때의 기본 로고.
  /// 상대팀 기본 로고와 동일하게 `defaultteamlogo.png` 방패 위에 이니셜.
  Widget _buildDefault(BorderRadius radius) {
    return OpponentLogo(
      teamName: team.name,
      size: size,
      borderRadius: radius,
      textColor: textColor,
      fontSize: fontSize,
    );
  }
}

/// `#RRGGBB` / `#AARRGGBB` hex 를 Color 로. 실패 시 null.
Color? parseLogoHex(String? hex) {
  if (hex == null) return null;
  var v = hex.trim();
  if (v.startsWith('#')) v = v.substring(1);
  if (v.length == 6) v = 'FF$v';
  if (v.length != 8) return null;
  final n = int.tryParse(v, radix: 16);
  if (n == null) return null;
  return Color(n);
}

/// 파일 경로에서 지원 확장자(jpg/png/webp) 추출. 미지원은 jpg 로 폴백.
String extensionFromPath(String path) {
  final i = path.lastIndexOf('.');
  if (i < 0 || i == path.length - 1) return 'jpg';
  final ext = path.substring(i + 1).toLowerCase();
  if (ext == 'jpeg') return 'jpg';
  if (ext == 'png' || ext == 'webp' || ext == 'jpg') return ext;
  return 'jpg';
}

/// 8색 팔레트를 4-col 그리드로 선택하는 위젯.
class TeamLogoPaletteGrid extends StatelessWidget {
  const TeamLogoPaletteGrid({
    super.key,
    required this.selected,
    required this.onSelect,
    this.enabled = true,
  });

  final String selected;
  final ValueChanged<String> onSelect;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final hex in kTeamLogoPalette)
          GestureDetector(
            onTap: enabled ? () => onSelect(hex) : null,
            behavior: HitTestBehavior.opaque,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: parseLogoHex(hex),
                border: hex == selected
                    ? Border.all(color: AppColors.textPrimary, width: 3)
                    : null,
              ),
            ),
          ),
      ],
    );
  }
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
