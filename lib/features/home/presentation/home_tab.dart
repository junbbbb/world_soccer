import 'dart:ui';

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/dev_settings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../runtime/providers.dart';
import '../../../types/enums.dart';
import '../../../types/match.dart' show Match;
import '../../match/presentation/match_result_input_screen.dart';
import '../../../types/team.dart' show Team;
import 'widgets/next_match_card.dart';
import 'widgets/team_posts_section.dart';
import 'widgets/team_recent_results_section.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  static const _headerHeight = 56.0;

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

  static Widget _defaultTeamLogo() {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.shield_rounded,
        size: 18,
        color: AppColors.textTertiary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showDummy = ref.watch(showDummyDataProvider);
    final topPadding = MediaQuery.of(context).padding.top;

    // 팀 데이터 (한 번만 watch)
    final team = ref.watch(currentTeamProvider).when<Team?>(
          data: (t) => t,
          loading: () => null,
          error: (_, __) => null,
        );

    // 실제 데이터: 예정 경기가 있는지 확인
    final asyncMatches = ref.watch(teamMatchesProvider);
    final realMatchList = asyncMatches.when<List<Match>>(
      data: (list) => list,
      loading: () => <Match>[],
      error: (_, __) => <Match>[],
    );
    final hasRealNextMatch = !showDummy &&
        realMatchList.any((m) => m.isVisibleOnHome);
    final hasNextMatch = showDummy || hasRealNextMatch;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(top: topPadding + _headerHeight),
          child: Column(
            children: [
              NextMatchCard(hasNextMatch: hasNextMatch),
              const SizedBox(height: AppSpacing.base),
              // 결과 미입력 경기 알림
              if (!showDummy) ...[
                ...() {
                  final needsResult = realMatchList
                      .where((m) =>
                          (m.displayState == MatchDisplayState.ended ||
                           m.displayState == MatchDisplayState.earlyEnded) &&
                          !m.hasResult)
                      .toList()
                    ..sort((a, b) => b.date.compareTo(a.date));
                  if (needsResult.isEmpty) return <Widget>[];
                  final m = needsResult.first;
                  return [
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
                          title: 'vs ${m.opponentName} 결과 입력',
                          matchId: m.id,
                          opponentName: m.opponentName,
                          onDismiss: () =>
                              setState(() => _isResultCardDismissed = true),
                        ),
                      ),
                    ),
                  ];
                }(),
              ] else if (hasNextMatch && !_isResultCardDismissed) ...[
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
              ],
              const SizedBox(height: AppSpacing.xxl),
              TeamRecentResultsSection(hasResults: hasNextMatch),
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
                          if (team?.logoUrl != null && team!.logoUrl!.isNotEmpty)
                            ClipOval(
                              child: Image.network(
                                team.logoUrl!,
                                width: 32, height: 32, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _defaultTeamLogo(),
                              ),
                            )
                          else
                            _defaultTeamLogo(),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            team?.name ?? '...',
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
  const _MatchResultPromptCard({
    required this.onDismiss,
    this.title,
    this.matchId,
    this.opponentName,
  });
  final VoidCallback onDismiss;
  final String? title;
  final String? matchId;
  final String? opponentName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingPage,
      child: _DismissibleNoticeCard(
        title: title ?? '경기 결과 입력',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => MatchResultInputScreen(
              matchId: matchId,
              opponentName: opponentName,
            ),
          ),
        ),
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
