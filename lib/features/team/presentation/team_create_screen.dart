import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../runtime/providers.dart';
import '../../../shared/widgets/team_logo_picker.dart';
import '../../../shared/widgets/team_logo_view.dart';

/// 새 팀 만들기 풀스크린.
///
/// 입력:
/// - 팀 이름 (필수)
/// - 로고 색상 (탭해서 팔레트에서 선택, 기본값: primary)
/// - 팀 소개 (선택, 최대 200자)
///
/// 저장: 생성 후 provider 무효화 + 이전 화면으로 pop.
/// 온보딩에서 진입한 경우(canPop=false)는 홈으로 교체 이동.
class TeamCreateScreen extends ConsumerStatefulWidget {
  const TeamCreateScreen({super.key});

  @override
  ConsumerState<TeamCreateScreen> createState() => _TeamCreateScreenState();
}

class _TeamCreateScreenState extends ConsumerState<TeamCreateScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _nameFocus = FocusNode();
  String _selectedColor = kTeamLogoPalette.first;
  Uint8List? _pickedImageBytes;
  String? _pickedImageExt;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  Future<void> _openLogoMenu() async {
    FocusScope.of(context).unfocus();
    final choice = await showModalBottomSheet<_LogoChoice>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _LogoMenuSheet(hasPickedImage: _pickedImageBytes != null),
    );
    if (!mounted || choice == null) return;

    switch (choice) {
      case _LogoChoice.upload:
        await _pickImage();
      case _LogoChoice.color:
        await _pickColor();
      case _LogoChoice.removeImage:
        HapticFeedback.selectionClick();
        setState(() {
          _pickedImageBytes = null;
          _pickedImageExt = null;
        });
    }
  }

  Future<void> _pickImage() async {
    final picked = await pickTeamLogoImage(context);
    if (picked == null || !mounted) return;
    setState(() {
      _pickedImageBytes = picked.bytes;
      _pickedImageExt = picked.ext;
    });
  }

  Future<void> _pickColor() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ColorPickerSheet(selected: _selectedColor),
    );
    if (picked != null && mounted) {
      HapticFeedback.selectionClick();
      setState(() => _selectedColor = picked);
    }
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = '팀 이름을 입력해주세요');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      final team = await ref.read(teamServiceProvider).createTeam(
            name: name,
            logoColor: _selectedColor,
            description: _descCtrl.text,
          );

      // 사진 선택되어 있으면 업로드 후 logoUrl 저장.
      // 팀 생성 성공 후 호출 — 실패해도 팀 자체는 살아있음 (색상 로고로 표시).
      if (_pickedImageBytes != null && _pickedImageExt != null) {
        try {
          final url = await ref.read(teamRepoProvider).uploadLogo(
                teamId: team.id,
                bytes: _pickedImageBytes!,
                extension: _pickedImageExt!,
              );
          await ref.read(teamRepoProvider).updateInfo(
                teamId: team.id,
                logoUrl: url,
              );
        } catch (uploadErr) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('로고 업로드 실패(팀은 생성됨): $uploadErr'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }

      ref.invalidate(myTeamsProvider);
      ref.invalidate(currentTeamProvider);
      if (!mounted) return;
      // 생성 성공 시 홈으로 교체 (onboarding/팀탭 양쪽에서 자연스러움).
      router.go('/');
      messenger.showSnackBar(
        SnackBar(
          content: Text('${team.name} 을(를) 만들었어요'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e is ArgumentError ? '팀 이름을 입력해주세요' : '팀 생성 실패: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () {
            final router = GoRouter.of(context);
            if (router.canPop()) {
              router.pop();
            }
            // canPop=false 일 땐 (온보딩) 뒤로가기 비활성: 아무 동작 안함.
          },
        ),
        title: Text(
          '새 팀 만들기',
          style: AppTextStyles.heading
              .copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: false,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Center(
                child: GestureDetector(
                  onTap: _openLogoMenu,
                  behavior: HitTestBehavior.opaque,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (_pickedImageBytes != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(56),
                          child: Image.memory(
                            _pickedImageBytes!,
                            width: 112,
                            height: 112,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        AnimatedBuilder(
                          animation: _nameCtrl,
                          builder: (_, __) {
                            final name = _nameCtrl.text.trim();
                            return TeamLogoView.byName(
                              name: name.isEmpty ? '팀' : name,
                              logoColor: _selectedColor,
                              size: 112,
                              borderRadius: BorderRadius.circular(56),
                              fontSize: 52,
                            );
                          },
                        ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                                color: AppColors.surface, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Icon(
                            _pickedImageBytes != null
                                ? Icons.edit_rounded
                                : Icons.camera_alt_outlined,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: Text(
                  '로고를 탭해서 사진/색상 선택',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textTertiary),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              _FieldLabel('팀 이름'),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _nameCtrl,
                focusNode: _nameFocus,
                enabled: !_loading,
                textInputAction: TextInputAction.next,
                maxLength: 20,
                decoration: _fieldDecoration(
                  hint: '예: FC미로',
                  errorText: _error,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _FieldLabel('팀 소개 (선택)'),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _descCtrl,
                enabled: !_loading,
                maxLines: 3,
                minLines: 2,
                maxLength: 200,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                decoration: _fieldDecoration(
                  hint: '예: 매주 토요일 저녁, 강동구 40대 모임',
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                child: AnimatedBuilder(
                  animation: _nameCtrl,
                  builder: (_, __) {
                    final canSubmit =
                        !_loading && _nameCtrl.text.trim().isNotEmpty;
                    return ElevatedButton(
                      onPressed: canSubmit ? _submit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textPrimary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.surface,
                        disabledForegroundColor: AppColors.textTertiary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.smoothButton,
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('만들기',
                              style: AppTextStyles.buttonPrimary),
                    );
                  },
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({required String hint, String? errorText}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyRegular
          .copyWith(color: AppColors.textTertiary),
      errorText: errorText,
      filled: true,
      fillColor: AppColors.surfaceLight,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: AppRadius.smoothMd,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.smoothMd,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.smoothMd,
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.smoothMd,
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.labelMedium
          .copyWith(color: AppColors.textPrimary),
    );
  }
}

// ══════════════════════════════════════════════
// 로고 메뉴 바텀시트 (사진 업로드 vs 색상 선택)
// ══════════════════════════════════════════════

enum _LogoChoice { upload, color, removeImage }

class _LogoMenuSheet extends StatelessWidget {
  const _LogoMenuSheet({required this.hasPickedImage});

  final bool hasPickedImage;

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: AppSpacing.base),
            _LogoMenuItem(
              icon: Icons.photo_library_outlined,
              label: '갤러리에서 사진 고르기',
              onTap: () => Navigator.pop(context, _LogoChoice.upload),
            ),
            _LogoMenuItem(
              icon: Icons.palette_outlined,
              label: '색상으로 자동 로고',
              onTap: () => Navigator.pop(context, _LogoChoice.color),
            ),
            if (hasPickedImage)
              _LogoMenuItem(
                icon: Icons.delete_outline_rounded,
                label: '선택한 사진 제거',
                isDestructive: true,
                onTap: () => Navigator.pop(context, _LogoChoice.removeImage),
              ),
            const SizedBox(height: AppSpacing.base),
          ],
        ),
      ),
    );
  }
}

class _LogoMenuItem extends StatelessWidget {
  const _LogoMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;
    return GestureDetector(
      onTap: onTap,
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
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 색상 팔레트 바텀시트
// ══════════════════════════════════════════════

class _ColorPickerSheet extends StatelessWidget {
  const _ColorPickerSheet({required this.selected});

  final String selected;

  @override
  Widget build(BuildContext context) {
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.iconInactive,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '로고 색상',
                style: AppTextStyles.heading
                    .copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.lg),
              TeamLogoPaletteGrid(
                selected: selected,
                onSelect: (hex) => Navigator.pop(context, hex),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
