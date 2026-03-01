import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class PlayerChip extends StatelessWidget {
  const PlayerChip({super.key, required this.number, required this.name});

  final int number;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          Text(
            '$number',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w900),
          ),
          const Spacer(),
          Text(name, style: AppTextStyles.body),
        ],
      ),
    );
  }
}

class MoreChip extends StatelessWidget {
  const MoreChip({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              '더보기',
              style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
