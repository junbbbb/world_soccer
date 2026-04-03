import 'dart:ui';

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'widgets/next_match_card.dart';
import 'widgets/team_posts_section.dart';
import 'widgets/team_recent_results_section.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  static const _headerHeight = 56.0;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(top: topPadding + _headerHeight),
          child: Column(
            children: [
              const NextMatchCard(),
              const SizedBox(height: AppSpacing.base),
              _MatchResultPromptCard(),
              const SizedBox(height: AppSpacing.xxl),
              const TeamRecentResultsSection(),
              const SizedBox(height: AppSpacing.xxl),
              // 두꺼운 섹션 구분선
              Container(
                height: 12,
                color: AppColors.surface,
              ),
              const SizedBox(height: AppSpacing.xxl),
              const TeamPostsSection(),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: Colors.white.withValues(alpha: 0.85),
                padding: EdgeInsets.only(
                  top: topPadding + AppSpacing.sm,
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  bottom: AppSpacing.base,
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/logo_calo.png',
                      width: 32,
                      height: 32,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'FC칼로',
                      style: AppTextStyles.pageTitle.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _showShareSheet(context),
                      child: SvgPicture.asset(
                        'assets/icons/majesticons_share.svg',
                        width: 32,
                        height: 32,
                        colorFilter: const ColorFilter.mode(
                          AppColors.textTertiary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _ShareTicketSheet(),
    );
  }
}

// ── 경기 결과 입력 프롬프트 카드 ──

class _MatchResultPromptCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingPage,
      child: GestureDetector(
        onTap: () => context.push('/match/result-input'),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.md,
          ),
          decoration: ShapeDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothMd),
          ),
          child: Row(
            children: [
              const Icon(Icons.edit_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '3/21 vs FC쏘아 결과 입력',
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.primary.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 공유 티켓 시트 ──

class _ShareTicketSheet extends StatelessWidget {
  const _ShareTicketSheet();

  // header(48) + team section(200) = 248
  static const _notchY = 248.0;
  static const _notchRadius = 14.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 핸들바
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.iconInactive,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            // 티켓
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x20000000),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ClipPath(
              clipper: const _TicketClipper(
                notchY: _notchY,
                notchRadius: _notchRadius,
              ),
              child: Container(
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 블루 헤더
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(AppRadius.lg),
                        ),
                      ),
                      child: Text(
                        'MATCH DAY',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Colors.white,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                    // 팀 VS 섹션
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.xxxl,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                ClipSmoothRect(
                                  radius: AppRadius.smoothMd,
                                  child: Image.asset(
                                    'assets/images/logo_calo.png',
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  'FC칼로',
                                  style: AppTextStyles.heading.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'VS',
                            style: AppTextStyles.sectionTitle.copyWith(
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.w800,
                              fontSize: 24,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                ClipSmoothRect(
                                  radius: AppRadius.smoothMd,
                                  child: Image.asset(
                                    'assets/images/logo_ssoa.png',
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  'FC쏘아',
                                  style: AppTextStyles.heading.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 점선 구분
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxl,
                      ),
                      child: Row(
                        children: List.generate(
                          30,
                          (i) => Expanded(
                            child: Container(
                              height: 1,
                              color: i.isEven
                                  ? AppColors.iconInactive
                                  : Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // 경기 정보
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xxl,
                        AppSpacing.xl,
                        AppSpacing.xxl,
                        AppSpacing.base,
                      ),
                      child: Column(
                        children: [
                          _infoRow(
                            Icons.calendar_month_rounded,
                            '2026년 2월 7일 (토)',
                          ),
                          const SizedBox(height: AppSpacing.base),
                          _infoRow(
                            Icons.access_time_rounded,
                            '오후 8:00',
                          ),
                          const SizedBox(height: AppSpacing.base),
                          _infoRow(
                            Icons.location_on_outlined,
                            '성내유수지',
                          ),
                          const SizedBox(height: AppSpacing.base),
                          _infoRow(
                            Icons.people_outline_rounded,
                            '13/16명 참가',
                          ),
                        ],
                      ),
                    ),
                    // 태그
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxl,
                      ),
                      child: Row(
                        children: [
                          _tag('리벤지 매치'),
                          const SizedBox(width: AppSpacing.sm),
                          _tag('홈경기'),
                          const SizedBox(width: AppSpacing.sm),
                          _tag('리그전'),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // 하단 브랜딩
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.xl,
                      ),
                      child: Text(
                        'CALOR FC  ·  2025-26 SEASON',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.iconInactive,
                          letterSpacing: 2,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ),
            const SizedBox(height: AppSpacing.base),
            // 공유 버튼들
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: SmoothRectangleBorder(
                          borderRadius: AppRadius.smoothMd,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.link_rounded,
                            size: 18,
                            color: AppColors.textPrimary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            '링크 복사',
                            style: AppTextStyles.buttonSecondary.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFFEE500),
                        shape: SmoothRectangleBorder(
                          borderRadius: AppRadius.smoothMd,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.chat_bubble,
                            size: 16,
                            color: Color(0xFF3C1E1E),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            '카카오 보내기',
                            style: AppTextStyles.buttonSecondary.copyWith(
                              color: const Color(0xFF3C1E1E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: ShapeDecoration(
        color: AppColors.surface,
        shape: SmoothRectangleBorder(
          borderRadius: AppRadius.smoothSm,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textPrimary),
        const SizedBox(width: AppSpacing.md),
        Text(
          text,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ── 티켓 모양 클리퍼 (양쪽 반원 노치) ──

class _TicketClipper extends CustomClipper<Path> {
  const _TicketClipper({
    required this.notchY,
    this.notchRadius = 14,
    this.cornerRadius = AppRadius.lg,
  });

  final double notchY;
  final double notchRadius;
  final double cornerRadius;

  @override
  Path getClip(Size size) {
    final outer = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(cornerRadius),
        ),
      );

    final notches = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(0, notchY),
        radius: notchRadius,
      ))
      ..addOval(Rect.fromCircle(
        center: Offset(size.width, notchY),
        radius: notchRadius,
      ));

    return Path.combine(PathOperation.difference, outer, notches);
  }

  @override
  bool shouldReclip(covariant _TicketClipper oldClipper) =>
      notchY != oldClipper.notchY;
}
