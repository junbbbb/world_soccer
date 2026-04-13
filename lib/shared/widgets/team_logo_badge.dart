import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class TeamLogoBadge extends StatelessWidget {
  const TeamLogoBadge({
    super.key,
    required this.teamName,
    this.logoPath,
    this.logoUrl,
    this.size = 52,
    this.showName = true,
    this.isOpponent = false,
  });

  final String teamName;
  final String? logoPath;
  final String? logoUrl;
  final double size;
  final bool showName;
  final bool isOpponent;

  Widget _buildLogo() {
    if (logoPath != null) {
      return ClipSmoothRect(
        radius: AppRadius.smoothSm,
        child: Image.asset(logoPath!, width: size, height: size, fit: BoxFit.cover),
      );
    }
    if (logoUrl != null && logoUrl!.isNotEmpty) {
      return ClipSmoothRect(
        radius: AppRadius.smoothSm,
        child: Image.network(
          logoUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _defaultLogo(),
        ),
      );
    }
    return _defaultLogo();
  }

  Widget _defaultLogo() {
    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothSm),
      ),
      child: Icon(
        isOpponent ? Icons.sports_soccer : Icons.shield_rounded,
        size: size * 0.5,
        color: Colors.white.withValues(alpha: 0.7),
      ),
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
