import 'dart:math' as math;

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../runtime/providers.dart';

// ── Provider 공식 색상 ──
const _kakaoYellow = Color(0xFFFEE500);
const _kakaoBrown = Color(0xFF191919);

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLogin = true;
  bool _showEmailForm = false;
  bool _loading = false;
  String? _loadingProvider;
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
      _loadingProvider = 'email';
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
            _loadingProvider = null;
          });
          return;
        }
        await authRepo.signUp(email: email, password: password, name: name);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _isLogin ? '이메일 또는 비밀번호를 확인해주세요' : '회원가입에 실패했습니다';
        _loading = false;
        _loadingProvider = null;
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _loading = true;
      _loadingProvider = 'google';
      _error = null;
    });

    try {
      final authRepo = ref.read(authRepoProvider);
      await authRepo.signInWithGoogle();
    } catch (e) {
      debugPrint('Google 로그인 에러: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Google 로그인에 실패했습니다';
        _loading = false;
        _loadingProvider = null;
      });
    }
  }

  Future<void> _signInWithKakao() async {
    setState(() {
      _loading = true;
      _loadingProvider = 'kakao';
      _error = null;
    });

    try {
      final authRepo = ref.read(authRepoProvider);
      await authRepo.signInWithOAuth('kakao');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '카카오 로그인에 실패했습니다';
        _loading = false;
        _loadingProvider = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _showEmailForm
            ? _EmailFormView(
                isLogin: _isLogin,
                loading: _loading && _loadingProvider == 'email',
                error: _error,
                emailController: _emailController,
                passwordController: _passwordController,
                nameController: _nameController,
                onToggleMode: () => setState(() {
                  _isLogin = !_isLogin;
                  _error = null;
                }),
                onSubmit: _submitEmail,
                onBack: () => setState(() {
                  _showEmailForm = false;
                  _error = null;
                }),
                bottomPadding: bottom,
              )
            : _LandingView(
                loading: _loading,
                loadingProvider: _loadingProvider,
                error: _error,
                onGoogle: _signInWithGoogle,
                onKakao: _signInWithKakao,
                onEmail: () => setState(() {
                  _showEmailForm = true;
                  _error = null;
                }),
                bottomPadding: bottom,
              ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// Landing View — 첫 화면 (브랜드 + 소셜 로그인)
// ══════════════════════════════════════════════

class _LandingView extends StatelessWidget {
  const _LandingView({
    required this.loading,
    required this.loadingProvider,
    required this.error,
    required this.onGoogle,
    required this.onKakao,
    required this.onEmail,
    required this.bottomPadding,
  });

  final bool loading;
  final String? loadingProvider;
  final String? error;
  final VoidCallback onGoogle;
  final VoidCallback onKakao;
  final VoidCallback onEmail;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── 상단: 브랜드 히어로 (화면의 ~60%) ──
        Expanded(
          flex: 3,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 앱 로고
                  Image.asset(
                    'assets/images/logo_app.png',
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // 가치 제안 (가장 눈에 띄는 요소)
                  Text(
                    '경기 참가부터\n전적 관리까지',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '우리 팀의 모든 것, 한 곳에서',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── 하단: 로그인 버튼 영역 (Thumb zone) ──
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              bottomPadding + AppSpacing.base,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 에러 메시지
                if (error != null) ...[
                  Text(
                    error!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                // ── 카카오 (한국 시장 1순위) ──
                _SocialButton(
                  label: '카카오로 계속하기',
                  icon: const _KakaoIcon(),
                  backgroundColor: _kakaoYellow,
                  foregroundColor: _kakaoBrown,
                  onTap: loading ? null : onKakao,
                  loading: loadingProvider == 'kakao',
                ),
                const SizedBox(height: AppSpacing.sm),

                // ── Google ──
                _SocialButton(
                  label: 'Google로 계속하기',
                  icon: const _GoogleIcon(),
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.textPrimary,
                  borderColor: const Color(0xFFE1E3E6),
                  onTap: loading ? null : onGoogle,
                  loading: loadingProvider == 'google',
                ),

                const SizedBox(height: AppSpacing.xl),

                // ── 이메일 (텍스트 링크 — Progressive disclosure) ──
                GestureDetector(
                  onTap: loading ? null : onEmail,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    child: Text(
                      '이메일로 로그인',
                      style: AppTextStyles.labelRegular.copyWith(
                        color: AppColors.textTertiary,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.iconInactive,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════
// Email Form View — 이메일 로그인/회원가입
// ══════════════════════════════════════════════

class _EmailFormView extends StatelessWidget {
  const _EmailFormView({
    required this.isLogin,
    required this.loading,
    required this.error,
    required this.emailController,
    required this.passwordController,
    required this.nameController,
    required this.onToggleMode,
    required this.onSubmit,
    required this.onBack,
    required this.bottomPadding,
  });

  final bool isLogin;
  final bool loading;
  final String? error;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nameController;
  final VoidCallback onToggleMode;
  final VoidCallback onSubmit;
  final VoidCallback onBack;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.base,
          AppSpacing.lg,
          bottomPadding + AppSpacing.base,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 뒤로가기 ──
            GestureDetector(
              onTap: onBack,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 24,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ── 제목 ──
            Text(
              isLogin ? '다시 만나서\n반갑습니다' : '함께\n시작해볼까요',
              style: AppTextStyles.sectionTitle.copyWith(
                color: AppColors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                height: 1.35,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // ── 입력 필드 ──
            if (!isLogin) ...[
              _InputField(
                controller: nameController,
                hint: '이름',
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],

            _InputField(
              controller: emailController,
              hint: '이메일',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppSpacing.sm),

            _InputField(
              controller: passwordController,
              hint: '비밀번호',
              obscureText: true,
            ),

            // 에러 메시지
            if (error != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                error!,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],

            const Spacer(),

            // ── 모드 전환 ──
            Center(
              child: GestureDetector(
                onTap: onToggleMode,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Text.rich(
                    TextSpan(
                      text: isLogin ? '계정이 없으신가요? ' : '이미 계정이 있으신가요? ',
                      style: AppTextStyles.labelRegular.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      children: [
                        TextSpan(
                          text: isLogin ? '회원가입' : '로그인',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.base),

            // ── 제출 버튼 ──
            _SocialButton(
              label: isLogin ? '로그인' : '회원가입',
              backgroundColor: AppColors.textPrimary,
              foregroundColor: Colors.white,
              onTap: loading ? null : onSubmit,
              loading: loading,
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// Social Button
// ══════════════════════════════════════════════

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.icon,
    this.borderColor,
    this.onTap,
    this.loading = false,
  });

  final String label;
  final Widget? icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap == null || loading) return;
        HapticFeedback.lightImpact();
        onTap!();
      },
      child: AnimatedOpacity(
        opacity: onTap == null && !loading ? 0.45 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: ShapeDecoration(
            color: backgroundColor,
            shape: SmoothRectangleBorder(
              borderRadius: AppRadius.smoothButton,
              side: borderColor != null
                  ? BorderSide(color: borderColor!)
                  : BorderSide.none,
            ),
          ),
          child: Center(
            child: loading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: foregroundColor,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        icon!,
                        const SizedBox(width: 10),
                      ],
                      Text(
                        label,
                        style: AppTextStyles.buttonSecondary.copyWith(
                          color: foregroundColor,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// Google Icon (공식 멀티컬러 G)
// ══════════════════════════════════════════════

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final r = w / 2;

    final arcR = r * 0.6;
    final strokeW = r * 0.38;

    // Blue (top-right → right)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: arcR),
      -math.pi * 0.4,
      -math.pi * 0.65,
      false,
      Paint()
        ..color = const Color(0xFF4285F4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW,
    );

    // Green (bottom-right)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: arcR),
      math.pi * 0.1,
      math.pi * 0.5,
      false,
      Paint()
        ..color = const Color(0xFF34A853)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW,
    );

    // Yellow (bottom-left)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: arcR),
      math.pi * 0.6,
      math.pi * 0.45,
      false,
      Paint()
        ..color = const Color(0xFFFBBC05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW,
    );

    // Red (top-left)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: arcR),
      -math.pi * 1.05,
      math.pi * 0.45,
      false,
      Paint()
        ..color = const Color(0xFFEA4335)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW,
    );

    // 가로 바 (Blue)
    canvas.drawRect(
      Rect.fromLTRB(cx, cy - r * 0.12, w, cy + r * 0.18),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ══════════════════════════════════════════════
// Kakao Icon (말풍선)
// ══════════════════════════════════════════════

class _KakaoIcon extends StatelessWidget {
  const _KakaoIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(painter: _KakaoLogoPainter()),
    );
  }
}

class _KakaoLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = _kakaoBrown
      ..style = PaintingStyle.fill;

    // 말풍선 몸통
    canvas.drawOval(Rect.fromLTWH(0, h * 0.05, w, h * 0.7), paint);

    // 말풍선 꼬리
    final tail = Path()
      ..moveTo(w * 0.28, h * 0.65)
      ..lineTo(w * 0.18, h * 0.92)
      ..lineTo(w * 0.48, h * 0.68)
      ..close();
    canvas.drawPath(tail, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
        color: AppColors.surfaceLight,
        shape: SmoothRectangleBorder(
          borderRadius: AppRadius.smoothMd,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
        cursorColor: AppColors.textPrimary,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
