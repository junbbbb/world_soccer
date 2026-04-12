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

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLogin = true;
  bool _loading = false;
  String? _error;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final authRepo = ref.read(authRepoProvider);
      if (_isLogin) {
        await authRepo.signIn(email: email, password: password);
      } else {
        final name = _nameController.text.trim();
        if (name.isEmpty) {
          setState(() {
            _error = '이름을 입력해주세요';
            _loading = false;
          });
          return;
        }
        await authRepo.signUp(email: email, password: password, name: name);
      }

      if (!mounted) return;

      // 팀 소속 확인 → 없으면 온보딩
      final teamRepo = ref.read(teamRepoProvider);
      final userId =
          ref.read(authRepoProvider).currentUser!.id;
      final teams = await teamRepo.getMyTeams(userId);
      if (mounted) {
        context.go(teams.isEmpty ? '/onboarding' : '/');
      }
    } catch (e) {
      setState(() {
        _error = _isLogin ? '이메일 또는 비밀번호를 확인해주세요' : '회원가입에 실패했습니다';
        _loading = false;
      });
    }
  }

  Future<void> _signInWithProvider(String provider) async {
    // TODO: Supabase 대시보드에서 provider 활성화 후 구현
    setState(() => _error = '$provider 로그인은 준비 중입니다');
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppColors.matchHeroGradient,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: bottomPadding + AppSpacing.xxl,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // ── 브랜드 히어로 ──
                  _buildHero(),

                  const SizedBox(height: 48),

                  // ── 소셜 로그인 ──
                  _buildSocialButtons(),

                  const SizedBox(height: AppSpacing.xxl),

                  // ── 구분선 ──
                  _buildDivider(),

                  const SizedBox(height: AppSpacing.xl),

                  // ── 이메일 폼 ──
                  _buildEmailForm(),

                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _error!,
                      style: AppTextStyles.caption.copyWith(
                        color: const Color(0xFFFFB4AB),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      children: [
        // 앱 로고
        Container(
          width: 80,
          height: 80,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: SmoothRectangleBorder(
              borderRadius: AppRadius.smoothXl,
            ),
          ),
          child: ClipSmoothRect(
            radius: AppRadius.smoothXl,
            child: Image.asset(
              'assets/images/logo_calo.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // 앱 이름
        Text(
          'World Soccer',
          style: AppTextStyles.sectionTitle.copyWith(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '우리 팀의 모든 것',
          style: AppTextStyles.body.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        // 카카오
        _SocialButton(
          label: '카카오로 시작하기',
          icon: Icons.chat_bubble_rounded,
          backgroundColor: const Color(0xFFFEE500),
          textColor: const Color(0xFF191919),
          onTap: () => _signInWithProvider('카카오'),
        ),
        const SizedBox(height: AppSpacing.md),

        // 네이버
        _SocialButton(
          label: '네이버로 시작하기',
          icon: Icons.north_east_rounded,
          backgroundColor: const Color(0xFF03C75A),
          textColor: Colors.white,
          onTap: () => _signInWithProvider('네이버'),
        ),
        const SizedBox(height: AppSpacing.md),

        // 구글
        _SocialButton(
          label: 'Google로 시작하기',
          icon: Icons.g_mobiledata_rounded,
          backgroundColor: Colors.white,
          textColor: AppColors.textPrimary,
          onTap: () => _signInWithProvider('Google'),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
          child: Text(
            '또는',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailForm() {
    return Column(
      children: [
        // 로그인/회원가입 토글
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => setState(() {
                _isLogin = true;
                _error = null;
              }),
              child: Text(
                '로그인',
                style: AppTextStyles.labelMedium.copyWith(
                  color: _isLogin
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                '|',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() {
                _isLogin = false;
                _error = null;
              }),
              child: Text(
                '회원가입',
                style: AppTextStyles.labelMedium.copyWith(
                  color: !_isLogin
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // 이름 (회원가입 시)
        if (!_isLogin) ...[
          _InputField(
            controller: _nameController,
            hint: '이름',
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // 이메일
        _InputField(
          controller: _emailController,
          hint: '이메일',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: AppSpacing.md),

        // 비밀번호
        _InputField(
          controller: _passwordController,
          hint: '비밀번호',
          obscureText: true,
        ),
        const SizedBox(height: AppSpacing.xl),

        // 제출 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : _submitEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              disabledBackgroundColor: Colors.white.withValues(alpha: 0.3),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
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
                      color: AppColors.primary,
                    ),
                  )
                : Text(
                    _isLogin ? '로그인' : '회원가입',
                    style: AppTextStyles.buttonPrimary.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════
// Social Button
// ══════════════════════════════════════════════

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: ShapeDecoration(
          color: backgroundColor,
          shape: SmoothRectangleBorder(
            borderRadius: AppRadius.smoothButton,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: textColor),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.buttonSecondary.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// Input Field
// ══════════════════════════════════════════════

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        shape: SmoothRectangleBorder(
          borderRadius: AppRadius.smoothMd,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: AppTextStyles.body.copyWith(color: Colors.white),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.body.copyWith(
            color: Colors.white.withValues(alpha: 0.35),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }
}
