import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../runtime/providers.dart';
import '../../../../shared/widgets/team_logo_picker.dart';
import '../../../../shared/widgets/team_logo_view.dart';
import '../../../../types/team.dart';

/// 팀 로고 편집 바텀시트 (기존 팀).
///
/// 두 모드:
///   - 자동 로고: 팔레트에서 색 선택
///   - 사진 업로드: 갤러리에서 사진 고르기 → Storage 업로드
Future<void> showTeamLogoEditSheet(BuildContext context, Team team) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _TeamLogoEditSheet(team: team),
  );
}

class _TeamLogoEditSheet extends ConsumerStatefulWidget {
  const _TeamLogoEditSheet({required this.team});

  final Team team;

  @override
  ConsumerState<_TeamLogoEditSheet> createState() => _TeamLogoEditSheetState();
}

class _TeamLogoEditSheetState extends ConsumerState<_TeamLogoEditSheet> {
  late String _selectedColor;
  Uint8List? _pickedImageBytes;
  String? _pickedImageExt;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.team.logoColor ?? kTeamLogoPalette.first;
  }

  Future<void> _pickImage() async {
    final picked = await pickTeamLogoImage(context);
    if (picked == null || !mounted) return;
    setState(() {
      _pickedImageBytes = picked.bytes;
      _pickedImageExt = picked.ext;
    });
  }

  void _clearPickedImage() {
    HapticFeedback.selectionClick();
    setState(() {
      _pickedImageBytes = null;
      _pickedImageExt = null;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final repo = ref.read(teamRepoProvider);
      String? uploadedUrl;

      if (_pickedImageBytes != null && _pickedImageExt != null) {
        uploadedUrl = await repo.uploadLogo(
          teamId: widget.team.id,
          bytes: _pickedImageBytes!,
          extension: _pickedImageExt!,
        );
      }

      await repo.updateInfo(
        teamId: widget.team.id,
        logoColor: _selectedColor,
        // 사진 업로드 했으면 logoUrl 저장, 아니면 건드리지 않음.
        logoUrl: uploadedUrl,
      );
      ref.invalidate(myTeamsProvider);
      ref.invalidate(currentTeamProvider);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text('저장 실패: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (!mounted) return;
    navigator.pop();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('팀 로고가 저장되었어요'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final previewTeam = widget.team.copyWith(
      logoUrl: _pickedImageBytes != null ? null : widget.team.logoUrl,
      logoColor: _selectedColor,
    );
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
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
              const SizedBox(height: AppSpacing.base),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: [
                    Text(
                      '팀 로고',
                      style: AppTextStyles.heading
                          .copyWith(color: AppColors.textPrimary),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _saving ? null : () => Navigator.pop(context),
                      behavior: HitTestBehavior.opaque,
                      child: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textTertiary,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // 미리보기
              if (_pickedImageBytes != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(48),
                  child: Image.memory(
                    _pickedImageBytes!,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  ),
                )
              else
                TeamLogoView(
                  team: previewTeam,
                  size: 96,
                  borderRadius: BorderRadius.circular(48),
                  fontSize: 44,
                ),
              const SizedBox(height: AppSpacing.md),
              Text(
                widget.team.name,
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionChip(
                        icon: Icons.photo_library_outlined,
                        label: '사진',
                        onTap: _saving ? null : _pickImage,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    if (_pickedImageBytes != null)
                      Expanded(
                        child: _ActionChip(
                          icon: Icons.close_rounded,
                          label: '사진 제거',
                          isDestructive: true,
                          onTap: _saving ? null : _clearPickedImage,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // 팔레트 (사진 없을 때만 의미 있음, 있어도 fallback 색으로 저장되므로 선택 가능)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: TeamLogoPaletteGrid(
                  selected: _selectedColor,
                  enabled: !_saving,
                  onSelect: (hex) {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedColor = hex);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textPrimary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.surface,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.smoothButton,
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('저장',
                            style: AppTextStyles.buttonPrimary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: ShapeDecoration(
          color: AppColors.surfaceLight,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.smoothMd),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.captionMedium.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

