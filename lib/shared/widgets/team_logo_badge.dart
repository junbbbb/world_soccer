import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class TeamLogoBadge extends StatelessWidget {
  const TeamLogoBadge({
    super.key,
    required this.teamName,
    required this.logoPath,
    this.size = 52,
    this.showName = true,
  });

  final String teamName;
  final String logoPath;
  final double size;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipSmoothRect(
          radius: AppRadius.smoothSm,
          child: Image.asset(
            logoPath,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
        if (showName) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(teamName, style: AppTextStyles.teamName),
        ],
      ],
    );
  }
}
