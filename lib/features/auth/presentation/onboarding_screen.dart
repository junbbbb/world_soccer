import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../runtime/providers.dart';

/// 첫 가입 후 팀이 없는 사용자가 보는 온보딩 화면.
/// 팀 생성 또는 초대 코드로 가입.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  _OnboardingMode _mode = _OnboardingMode.choice;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: switch (_mode) {
              _OnboardingMode.choice => _ChoiceView(
                  onCreateTeam: () =>
                      setState(() => _mode = _OnboardingMode.createTeam),
                  onJoinTeam: () =>
                      setState(() => _mode = _OnboardingMode.joinTeam),
                ),
              _OnboardingMode.createTeam => _CreateTeamView(
                  onBack: () =>
                      setState(() => _mode = _OnboardingMode.choice),
                  onComplete: () => context.go('/'),
                ),
              _OnboardingMode.joinTeam => _JoinTeamView(
                  onBack: () =>
                      setState(() => _mode = _OnboardingMode.choice),
                  onComplete: () => context.go('/'),
                ),
            },
          ),
        ),
      ),
    );
  }
}

enum _OnboardingMode { choice, createTeam, joinTeam }

// ══════════════════════════════════════════════
// 선택 화면: 팀 만들기 vs 초대 코드 입력
// ══════════════════════════════════════════════

class _ChoiceView extends StatelessWidget {
  const _ChoiceView({
    required this.onCreateTeam,
    required this.onJoinTeam,
  });

  final VoidCallback onCreateTeam;
  final VoidCallback onJoinTeam;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),

        // 환영 메시지
        Text(
          '환영합니다!',
          style: AppTextStyles.sectionTitle.copyWith(
            color: AppColors.textPrimary,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '팀을 만들거나, 초대 코드로\n팀에 참가하세요',
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),

        const Spacer(flex: 2),

        // 팀 만들기
        _OnboardingButton(
          icon: Icons.add_circle_outline_rounded,
          label: '새 팀 만들기',
          description: '감독/운영진이라면 여기서 시작하세요',
          onTap: onCreateTeam,
          isPrimary: true,
        ),
        const SizedBox(height: AppSpacing.base),

        // 초대 코드로 가입
        _OnboardingButton(
          icon: Icons.group_add_outlined,
          label: '초대 코드로 참가',
          description: '팀에서 받은 코드를 입력하세요',
          onTap: onJoinTeam,
          isPrimary: false,
        ),

        const Spacer(flex: 3),
      ],
    );
  }
}

// ══════════════════════════════════════════════
// 팀 생성 화면
// ══════════════════════════════════════════════

class _CreateTeamView extends ConsumerStatefulWidget {
  const _CreateTeamView({
    required this.onBack,
    required this.onComplete,
  });

  final VoidCallback onBack;
  final VoidCallback onComplete;

  @override
  ConsumerState<_CreateTeamView> createState() => _CreateTeamViewState();
}

class _CreateTeamViewState extends ConsumerState<_CreateTeamView> {
  final _nameController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = '팀 이름을 입력해주세요');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final teamRepo = ref.read(teamRepoProvider);
      final team = await teamRepo.create(name: name);

      // 초대 코드 자동 생성
      final code = await teamRepo.createInviteCode(teamId: team.id);

      if (mounted) {
        // 초대 코드를 보여주는 다이얼로그
        await _showInviteCodeDialog(team.name, code);
        widget.onComplete();
      }
    } catch (e) {
      setState(() {
        _error = '팀 생성에 실패했습니다';
        _loading = false;
      });
    }
  }

  Future<void> _showInviteCodeDialog(String teamName, String code) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothLg),
        title: Text(
          '$teamName 생성 완료!',
          style: AppTextStyles.heading.copyWith(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '팀원들에게 아래 초대 코드를 공유하세요',
              style: AppTextStyles.bodyRegular.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: code));
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('코드가 복사되었습니다')),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.base,
                  horizontal: AppSpacing.lg,
                ),
                decoration: ShapeDecoration(
                  color: AppColors.surfaceLight,
                  shape: SmoothRectangleBorder(
                    borderRadius: AppRadius.smoothMd,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      code,
                      style: AppTextStyles.sectionTitle.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Icon(
                      Icons.copy_rounded,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              '확인',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),

        // 뒤로가기
        GestureDetector(
          onTap: widget.onBack,
          behavior: HitTestBehavior.opaque,
          child: const Padding(
            padding: EdgeInsets.all(AppSpacing.xs),
            child: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),

        Text(
          '새 팀 만들기',
          style: AppTextStyles.sectionTitle.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '팀 이름을 입력하세요',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),

        // 팀 이름 입력
        Container(
          decoration: ShapeDecoration(
            color: AppColors.surfaceLight,
            shape: SmoothRectangleBorder(
              borderRadius: AppRadius.smoothMd,
            ),
          ),
          child: TextField(
            controller: _nameController,
            autofocus: true,
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'FC칼로',
              hintStyle: AppTextStyles.body.copyWith(
                color: AppColors.textTertiary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ),

        if (_error != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            _error!,
            style: AppTextStyles.caption.copyWith(color: AppColors.error),
          ),
        ],

        const SizedBox(height: AppSpacing.xl),

        // 생성 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textPrimary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: SmoothRectangleBorder(
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
                : const Text('팀 생성', style: AppTextStyles.buttonPrimary),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════
// 초대 코드 입력 화면
// ══════════════════════════════════════════════

class _JoinTeamView extends ConsumerStatefulWidget {
  const _JoinTeamView({
    required this.onBack,
    required this.onComplete,
  });

  final VoidCallback onBack;
  final VoidCallback onComplete;

  @override
  ConsumerState<_JoinTeamView> createState() => _JoinTeamViewState();
}

class _JoinTeamViewState extends ConsumerState<_JoinTeamView> {
  final _codeController = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _successTeam;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _error = '초대 코드를 입력해주세요');
      return;
    }
    if (code.length != 6) {
      setState(() => _error = '초대 코드는 6자리입니다');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final teamRepo = ref.read(teamRepoProvider);
      final result = await teamRepo.joinByInviteCode(code);
      final teamName = result['team_name'] as String;

      setState(() {
        _successTeam = teamName;
        _loading = false;
      });

      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) widget.onComplete();
    } catch (e) {
      setState(() {
        _error = '유효하지 않은 초대 코드입니다';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_successTeam != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '$_successTeam에 가입했습니다!',
              style: AppTextStyles.heading.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),

        // 뒤로가기
        GestureDetector(
          onTap: widget.onBack,
          behavior: HitTestBehavior.opaque,
          child: const Padding(
            padding: EdgeInsets.all(AppSpacing.xs),
            child: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),

        Text(
          '초대 코드 입력',
          style: AppTextStyles.sectionTitle.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '팀에서 받은 6자리 코드를 입력하세요',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),

        // 코드 입력
        Container(
          decoration: ShapeDecoration(
            color: AppColors.surfaceLight,
            shape: SmoothRectangleBorder(
              borderRadius: AppRadius.smoothMd,
            ),
          ),
          child: TextField(
            controller: _codeController,
            autofocus: true,
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.characters,
            maxLength: 6,
            style: AppTextStyles.sectionTitle.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: 8,
            ),
            decoration: InputDecoration(
              hintText: 'ABC123',
              hintStyle: AppTextStyles.sectionTitle.copyWith(
                color: AppColors.iconInactive,
                letterSpacing: 8,
              ),
              border: InputBorder.none,
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.lg,
              ),
            ),
          ),
        ),

        if (_error != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            _error!,
            style: AppTextStyles.caption.copyWith(color: AppColors.error),
          ),
        ],

        const SizedBox(height: AppSpacing.xl),

        // 가입 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: SmoothRectangleBorder(
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
                : const Text('팀 참가', style: AppTextStyles.buttonPrimary),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════
// Onboarding Button
// ══════════════════════════════════════════════

class _OnboardingButton extends StatelessWidget {
  const _OnboardingButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
    required this.isPrimary,
  });

  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: ShapeDecoration(
          color: isPrimary ? AppColors.textPrimary : AppColors.surfaceLight,
          shape: SmoothRectangleBorder(
            borderRadius: AppRadius.smoothLg,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 28,
              color: isPrimary ? Colors.white : AppColors.textPrimary,
            ),
            const SizedBox(width: AppSpacing.base),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.heading.copyWith(
                      color:
                          isPrimary ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: AppTextStyles.caption.copyWith(
                      color: isPrimary
                          ? Colors.white.withValues(alpha: 0.6)
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isPrimary
                  ? Colors.white.withValues(alpha: 0.5)
                  : AppColors.iconInactive,
            ),
          ],
        ),
      ),
    );
  }
}
