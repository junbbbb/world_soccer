import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// 상단 바 (뒤로가기 + 공유/일정) — pinned
class MatchTopBarDelegate extends SliverPersistentHeaderDelegate {
  const MatchTopBarDelegate({this.onBack});

  final VoidCallback? onBack;

  @override
  double get minExtent => 52;

  @override
  double get maxExtent => 52;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppColors.matchHeroGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              if (onBack != null)
                _CircleIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: onBack!,
                ),
              const Spacer(),
              _CircleIconButton(
                icon: Icons.share_outlined,
                onTap: () {},
              ),
              const SizedBox(width: AppSpacing.sm),
              _CircleIconButton(
                icon: Icons.calendar_today_outlined,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant MatchTopBarDelegate oldDelegate) => false;
}

/// 반투명 검정 원형 배경 위의 아이콘 버튼
class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Color(0x30000000), // #000000 19%
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            icon,
            size: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
