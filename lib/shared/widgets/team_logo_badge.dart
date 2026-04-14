import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'opponent_logo.dart';
import 'team_logo_view.dart';

class TeamLogoBadge extends StatelessWidget {
  const TeamLogoBadge({
    super.key,
    required this.teamName,
    this.logoPath,
    this.logoUrl,
    this.logoColor,
    this.size = 52,
    this.showName = true,
    this.isOpponent = false,
  });

  final String teamName;
  final String? logoPath;
  final String? logoUrl;
  final String? logoColor;
  final double size;
  final bool showName;
  final bool isOpponent;

  Widget _buildLogo() {
    if (isOpponent && (logoUrl == null || logoUrl!.isEmpty)) {
      return OpponentLogo(
        teamName: teamName,
        size: size,
        borderRadius: AppRadius.smoothSm,
      );
    }
    if (logoPath != null) {
      return ClipRRect(
        borderRadius: AppRadius.smoothSm,
        child: Image.asset(logoPath!, width: size, height: size, fit: BoxFit.cover),
      );
    }
    // 실제 로고 URL 또는 색상 이니셜 fallback
    return TeamLogoView.byName(
      name: teamName,
      logoUrl: logoUrl,
      logoColor: logoColor,
      size: size,
      borderRadius: AppRadius.smoothSm,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLogo(),
        if (showName) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(teamName, style: AppTextStyles.teamName),
        ],
      ],
    );
  }
}
