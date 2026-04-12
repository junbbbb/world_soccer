import 'dart:ui';

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'widgets/next_match_card.dart';
import 'widgets/team_posts_section.dart';
import 'widgets/team_recent_results_section.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  static const _headerHeight = 56.0;

  // 개발용: 일정 유무 토글
  bool _hasNextMatch = true;
  // 개발용: 프로필 완성 여부 (false = 첫 가입자 상태)
  bool _hasProfile = false;

  // 알림 카드 dismiss 상태
  bool _isResultCardDismissed = false;

  // 결과 입력 카드 지연 등장
  bool _showResultCard = false;

  void _showTeamSwitcher(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _TeamSwitcherSheet(),
    );
  }

  @override
  void initState() {
    super.initState();
    // 400ms 후 슬라이드인 — "이벤트성 카드"라는 인식 부여
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _showResultCard = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(top: topPadding + _headerHeight),
          child: Column(
            children: [
              NextMatchCard(hasNextMatch: _hasNextMatch),
              const SizedBox(height: AppSpacing.base),
              if (_hasNextMatch && !_isResultCardDismissed)
                AnimatedSlide(
                  offset: _showResultCard
                      ? Offset.zero
                      : const Offset(0, 0.3),
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  child: AnimatedOpacity(
                    opacity: _showResultCard ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    child: _MatchResultPromptCard(
                      onDismiss: () =>
                          setState(() => _isResultCardDismissed = true),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.xxl),
              TeamRecentResultsSection(hasResults: _hasNextMatch),
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
                    GestureDetector(
                      onTap: () => _showTeamSwitcher(context),
                      behavior: HitTestBehavior.opaque,
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
                          const SizedBox(width: AppSpacing.xs),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 20,
                            color: AppColors.textTertiary,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // DEV: 일정 유무 토글
                    GestureDetector(
                      onTap: () =>
                          setState(() => _hasNextMatch = !_hasNextMatch),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _hasNextMatch
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _hasNextMatch ? 'DEV:일정있음' : 'DEV:일정없음',
                          style: AppTextStyles.caption.copyWith(
                            color: _hasNextMatch
                                ? AppColors.primary
                                : AppColors.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    GestureDetector(
                      onTap: () => context.push('/profile'),
                      behavior: HitTestBehavior.opaque,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              size: 20,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          // 프로필 미완성 시 빨간 점
                          if (!_hasProfile)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                        ],
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
}

// ── 이벤트성 알림 카드 ──

class _MatchResultPromptCard extends StatelessWidget {
  const _MatchResultPromptCard({required this.onDismiss});
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingPage,
      child: _DismissibleNoticeCard(
        title: '3/21 vs FC쏘아 결과 입력',
        onTap: () => context.push('/match/result-input'),
        onDismiss: onDismiss,
      ),
    );
  }
}

// ── 닫기 가능한 알림 카드 (공용) ──
// 텍스트 중심. 좌측 아이콘 없음 — 텍스트가 명확하면 아이콘은 redundant.
// X 버튼만 액션 어피던스로 유지.
class _DismissibleNoticeCard extends StatelessWidget {
  const _DismissibleNoticeCard({
    required this.title,
    required this.onTap,
    required this.onDismiss,
  });

  final String title;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        decoration: ShapeDecoration(
          color: AppColors.surfaceLight,
          shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothMd),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: onDismiss,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// Team Switcher Sheet — 소속팀 변경
// ══════════════════════════════════════════════

class _TeamSwitcherSheet extends StatelessWidget {
  const _TeamSwitcherSheet();

  static const _teams = <({String name, String logo, bool isCurrent})>[
    (name: 'FC칼로', logo: 'assets/images/logo_calo.png', isCurrent: true),
    (name: 'FC쏘아', logo: 'assets/images/logo_ssoa.png', isCurrent: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.only(
            topLeft: SmoothRadius(
              cornerRadius: AppRadius.xl,
              cornerSmoothing: 1.0,
            ),
            topRight: SmoothRadius(
              cornerRadius: AppRadius.xl,
              cornerSmoothing: 1.0,
            ),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.iconInactive,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                '소속팀',
                style: AppTextStyles.heading.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final team in _teams)
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).pop();
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      ClipSmoothRect(
                        radius: AppRadius.smoothXs,
                        child: Image.asset(
                          team.logo,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          team.name,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: team.isCurrent
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (team.isCurrent)
                        const Icon(
                          Icons.check_rounded,
                          size: 20,
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.base),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md,
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
                      const Icon(
                        Icons.add_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '새 팀 참가하기',
                        style: AppTextStyles.captionMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.base),
          ],
        ),
      ),
    );
  }
}
