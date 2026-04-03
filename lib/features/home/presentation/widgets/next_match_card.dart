import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/info_capsule.dart';
import '../../../../shared/widgets/match_time_info.dart';
import '../../../../shared/widgets/team_logo_badge.dart';

class NextMatchCard extends StatelessWidget {
  const NextMatchCard({super.key});

  static final _cardRadius = BorderRadius.circular(AppRadius.md);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GestureDetector(
        onTap: () => context.push('/match'),
        child: ClipRRect(
          borderRadius: _cardRadius,
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
                        child: Row(
                          children: [
                            InfoCapsule(text: '13/16명'),
                            const SizedBox(width: AppSpacing.sm),
                            InfoCapsule(text: '참가완료'),
                            const SizedBox(width: AppSpacing.sm),
                            InfoCapsule(text: '리벤지 매치'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 구분선 (그라데이션) ──
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

              // ── 하단: 참가하기 버튼 ──
              _ParticipateButton(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 참가하기 버튼 (press 피드백 + 타원형 방사 그라데이션) ──

class _ParticipateButton extends StatefulWidget {
  @override
  State<_ParticipateButton> createState() => _ParticipateButtonState();
}

class _ParticipateButtonState extends State<_ParticipateButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
