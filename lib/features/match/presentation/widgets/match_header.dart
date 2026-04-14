import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 상단 바 (뒤로가기 + 공유/일정/더보기) — pinned
class MatchTopBarDelegate extends SliverPersistentHeaderDelegate {
  const MatchTopBarDelegate({
    this.onBack,
    this.onStatusChange,
    this.onEdit,
    this.onDelete,
  });

  final VoidCallback? onBack;
  final ValueChanged<String>? onStatusChange;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

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
                onTap: () => context.push('/match/share'),
              ),
              const SizedBox(width: AppSpacing.sm),
              _CircleIconButton(
                icon: Icons.calendar_today_outlined,
                onTap: () {},
              ),
              if (onStatusChange != null) ...[
                const SizedBox(width: AppSpacing.sm),
                _CircleIconButton(
                  icon: Icons.more_horiz_rounded,
                  onTap: () => _showStatusSheet(context),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showStatusSheet(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppRadius.xl),
              topRight: Radius.circular(AppRadius.xl),
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(top: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.iconInactive,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  '경기 관리',
                  style: AppTextStyles.heading.copyWith(color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: AppSpacing.base),
              _StatusOption(
                icon: Icons.edit_rounded,
                label: '경기 정보 수정',
                description: '날짜, 시간, 장소, 상대팀을 수정합니다',
                onTap: () {
                  Navigator.pop(context);
                  onEdit?.call();
                },
              ),
              _StatusOption(
                icon: Icons.timer_off_rounded,
                label: '조기 종료',
                description: '경기를 예정보다 일찍 종료합니다',
                onTap: () {
                  Navigator.pop(context);
                  onStatusChange?.call('early_ended');
                },
              ),
              _StatusOption(
                icon: Icons.cancel_outlined,
                label: '경기 취소',
                description: '경기를 취소합니다',
                isDestructive: true,
                onTap: () {
                  Navigator.pop(context);
                  onStatusChange?.call('cancelled');
                },
              ),
              if (onDelete != null)
                _StatusOption(
                  icon: Icons.delete_outline_rounded,
                  label: '경기 삭제',
                  description: '경기를 영구 삭제합니다 (복구 불가)',
                  isDestructive: true,
                  onTap: () {
                    Navigator.pop(context);
                    onDelete!();
                  },
                ),
              const SizedBox(height: AppSpacing.base),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant MatchTopBarDelegate oldDelegate) =>
      onStatusChange != oldDelegate.onStatusChange ||
      onEdit != oldDelegate.onEdit ||
      onDelete != oldDelegate.onDelete;
}

class _StatusOption extends StatelessWidget {
  const _StatusOption({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isDestructive ? AppColors.error : AppColors.textPrimary,
            ),
            const SizedBox(width: AppSpacing.base),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.body.copyWith(
                      color: isDestructive ? AppColors.error : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    description,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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
