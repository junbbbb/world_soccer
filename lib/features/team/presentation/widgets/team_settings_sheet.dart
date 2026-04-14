import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../runtime/providers.dart';
import '../../../../service/team_service.dart';
import '../../../../types/team.dart';
import 'team_logo_edit_sheet.dart';

/// 팀 설정 바텀시트.
///
/// - 팀 로고 수정 (admin)
/// - 새 팀 만들기 (누구나)
/// - 팀 탈퇴 (누구나, 마지막 admin 은 차단)
Future<void> showTeamSettingsSheet(BuildContext context, Team team) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _TeamSettingsSheet(team: team),
  );
}

class _TeamSettingsSheet extends ConsumerWidget {
  const _TeamSettingsSheet({required this.team});

  final Team team;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
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
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.iconInactive,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Text(
                    team.name,
                    style: AppTextStyles.heading
                        .copyWith(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            _SettingsItem(
              icon: Icons.edit_rounded,
              label: '팀 로고 수정',
              description: '배경색이나 이미지를 바꿉니다',
              onTap: () {
                Navigator.pop(context);
                showTeamLogoEditSheet(context, team);
              },
            ),
            _SettingsItem(
              icon: Icons.add_circle_outline_rounded,
              label: '새 팀 만들기',
              description: '지금 팀을 그대로 두고 다른 팀을 추가로 만듭니다',
              onTap: () {
                Navigator.pop(context);
                context.push('/team/create');
              },
            ),
            _SettingsItem(
              icon: Icons.logout_rounded,
              label: '팀 탈퇴',
              description: '이 팀에서 나갑니다',
              isDestructive: true,
              onTap: () async {
                Navigator.pop(context);
                await _confirmLeave(context, ref, team);
              },
            ),
            const SizedBox(height: AppSpacing.base),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLeave(
      BuildContext context, WidgetRef ref, Team team) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smoothLg),
        title: Text(
          '${team.name} 탈퇴',
          style: AppTextStyles.heading.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          '이 팀에서 나갈까요? 다시 들어오려면 초대 코드가 필요해요.',
          style: AppTextStyles.bodyRegular
              .copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('탈퇴'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final supa = ref.read(supabaseClientProvider);
    final uid = supa.auth.currentUser?.id;
    if (uid == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('로그인 정보가 없어 탈퇴할 수 없어요'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      await ref
          .read(teamServiceProvider)
          .leaveTeam(teamId: team.id, playerId: uid);
    } on LastAdminException {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
              '마지막 관리자는 탈퇴할 수 없어요. 다른 멤버를 관리자로 지정하거나 팀을 삭제하세요.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('탈퇴 실패: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ref.invalidate(myTeamsProvider);
    ref.invalidate(currentTeamProvider);
    messenger.showSnackBar(
      SnackBar(
        content: Text('${team.name}에서 탈퇴했어요'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
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
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;
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
            Icon(icon, size: 24, color: color),
            const SizedBox(width: AppSpacing.base),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.body.copyWith(
                      color: color,
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

