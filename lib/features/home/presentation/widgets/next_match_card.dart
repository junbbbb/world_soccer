import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/info_capsule.dart';
import '../../../../shared/widgets/match_time_info.dart';
import '../../../../shared/widgets/team_logo_badge.dart';

class NextMatchCard extends StatefulWidget {
  const NextMatchCard({super.key, this.hasNextMatch = true});

  final bool hasNextMatch;

  static final _cardRadius = BorderRadius.circular(AppRadius.md);

  @override
  State<NextMatchCard> createState() => _NextMatchCardState();
}

class _NextMatchCardState extends State<NextMatchCard> {
  bool _isJoined = false;

  // 참가/취소 토글 (단방향이 아닌 토글로 — 사용자가 실수해도 복구 가능)
  void _toggleJoin() {
    HapticFeedback.mediumImpact();
    setState(() => _isJoined = !_isJoined);
  }

  static const _animDuration = Duration(milliseconds: 350);
  static const _animCurve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    if (!widget.hasNextMatch) return const _EmptyMatchCard();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GestureDetector(
        onTap: () => context.push('/match'),
        child: ClipRRect(
          borderRadius: NextMatchCard._cardRadius,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── 상단: VS 영역 ──
              DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    AppSpacing.xxl,
                    AppSpacing.sm,
                    AppSpacing.xl,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Center(
                              child: TeamLogoBadge(
                                teamName: 'FC칼로',
                                logoPath: 'assets/images/logo_calo.png',
                                size: 52,
                              ),
                            ),
                          ),
                          MatchTimeInfo(
                            time: '20:00',
                            datePlace: '2/7(토) 성내유수지',
                          ),
                          Expanded(
                            child: Center(
                              child: TeamLogoBadge(
                                teamName: 'FC쏘아',
                                logoPath: 'assets/images/logo_ssoa.png',
                                size: 52,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        // 참가 시 "참가완료" 캡슐이 우측에 부드럽게 추가됨
                        // Align(centerLeft)로 좌측 정렬 강제
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: AnimatedSize(
                            duration: _animDuration,
                            curve: _animCurve,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const InfoCapsule(text: '13/16명'),
                                const SizedBox(width: AppSpacing.sm),
                                const InfoCapsule(text: '리벤지 매치'),
                                if (_isJoined) ...[
                                  const SizedBox(width: AppSpacing.sm),
                                  const InfoCapsule(text: '참가완료'),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 구분선 + 참가하기 버튼 (참가 시 부드럽게 collapse) ──
              AnimatedSize(
                duration: _animDuration,
                curve: _animCurve,
                alignment: Alignment.topCenter,
                child: _isJoined
                    ? const SizedBox(width: double.infinity)
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 그라데이션 구분선
                          Container(
                            height: 1,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF1572D1),
                                  Color(0xFF1E64AC),
                                  Color(0xFF1E64AC),
                                  Color(0xFF1E64AC),
                                  Color(0xFF1572D1),
                                ],
                                stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                              ),
                            ),
                          ),
                          _ParticipateButton(onTap: _toggleJoin),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 참가하기 버튼 (press 피드백 + 타원형 방사 그라데이션) ──

class _ParticipateButton extends StatefulWidget {
  const _ParticipateButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_ParticipateButton> createState() => _ParticipateButtonState();
}

class _ParticipateButtonState extends State<_ParticipateButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: _pressed ? 0.7 : 1.0,
        child: CustomPaint(
          painter: const _EllipticalGradientPainter(),
          child: const SizedBox(
            height: 55,
            width: double.infinity,
            child: Center(
              child: Text(
                '참가하기',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EllipticalGradientPainter extends CustomPainter {
  const _EllipticalGradientPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 베이스: primary 파란색
    canvas.drawRect(rect, Paint()..color = AppColors.primary);

    // 타원형 방사 그라데이션
    final center = Offset(size.width / 2, 0); // 중앙 상단
    final hRadius = size.width / 2; // 가로 반지름 (좌측 끝까지)
    final vRadius = size.height; // 세로 반지름 (버튼 높이)
    final scaleY = vRadius / hRadius;

    // Y축 압축 행렬
    final matrix = Float64List(16);
    Matrix4.identity()
      ..translate(center.dx, center.dy)
      ..scale(1.0, scaleY)
      ..translate(-center.dx, -center.dy)
      ..copyIntoArray(matrix);

    final gradient = ui.Gradient.radial(
      center,
      hRadius,
      [const Color(0xFF1869BE), AppColors.primary],
      [0.4375, 1.0],
      TileMode.clamp,
      matrix,
    );

    canvas.drawRect(rect, Paint()..shader = gradient);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── 일정 없을 때 빈 카드 ──

class _EmptyMatchCard extends StatelessWidget {
  const _EmptyMatchCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GestureDetector(
        onTap: () => context.push('/match/create'),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.base),
              Text(
                '예정된 경기가 없습니다',
                style: AppTextStyles.heading.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '새 경기 일정을 추가해보세요',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
