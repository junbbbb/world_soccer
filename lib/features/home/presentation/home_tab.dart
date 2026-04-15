import 'dart:ui';

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
import '../../../shared/widgets/team_logo_view.dart';
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

  bool _hasProfile = false;
  bool _isResultCardDismissed = false;
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
    // 400ms 후 슬라이드인 — "이벤트성 카드"라는 인식 부여.
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _showResultCard = true);
    });
  }

  /// 결과 입력 프롬프트 카드. 표시 조건에 맞지 않으면 null 반환.
  /// Column 에서 null 일 때 주변 spacing 까지 함께 제거하기 위해 widget 을
  /// 만들 여부 자체를 한 곳에서 결정.
  Widget? _buildResultPromptCard({
    required bool showDummy,
    required bool hasNextMatch,
    required List<Match> realMatchList,
  }) {
    if (!showDummy) {
      final needsResult = realMatchList
          .where((m) =>
              (m.displayState == MatchDisplayState.ended ||
                  m.displayState == MatchDisplayState.earlyEnded) &&
              !m.hasResult)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      if (needsResult.isEmpty) return null;
      final m = needsResult.first;
      return _animatedPrompt(
        child: _MatchResultPromptCard(
          title: 'vs ${m.opponentName} 결과 입력',
          matchId: m.id,
          opponentName: m.opponentName,
          onDismiss: () =>
              setState(() => _isResultCardDismissed = true),
        ),
      );
    }
    if (hasNextMatch && !_isResultCardDismissed) {
      return _animatedPrompt(
        child: _MatchResultPromptCard(
          onDismiss: () => setState(() => _isResultCardDismissed = true),
        ),
      );
    }
    return null;
  }

  Widget _animatedPrompt({required Widget child}) {
    return AnimatedSlide(
      offset: _showResultCard ? Offset.zero : const Offset(0, 0.3),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _showResultCard ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showDummy = ref.watch(showDummyDataProvider);
    final topPadding = MediaQuery.of(context).padding.top;

    final team = ref.watch(currentTeamProvider).when<Team?>(
          data: (t) => t,
          loading: () => null,
          error: (_, __) => null,
        );

    final asyncMatches = ref.watch(teamMatchesProvider);
    final realMatchList = asyncMatches.when<List<Match>>(
      data: (list) => list,
      loading: () => <Match>[],
      error: (_, __) => <Match>[],
    );
    final hasRealNextMatch = !showDummy &&
        realMatchList.any((m) => m.isVisibleOnHome);
    final hasNextMatch = showDummy || hasRealNextMatch;

    // 결과 입력 프롬프트 카드 (표시 안 하면 null 반환 → Column 에서
    // 주변 SizedBox 까지 함께 생략되도록).
    final Widget? resultPromptCard = _buildResultPromptCard(
      showDummy: showDummy,
      hasNextMatch: hasNextMatch,
      realMatchList: realMatchList,
    );

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(top: topPadding + _headerHeight),
          child: Column(
            children: [
              NextMatchCard(hasNextMatch: hasNextMatch),
              if (resultPromptCard != null) ...[
                const SizedBox(height: AppSpacing.base),
                resultPromptCard,
              ],
              const SizedBox(height: AppSpacing.xxl),
              TeamRecentResultsSection(hasResults: hasNextMatch),
              const SizedBox(height: AppSpacing.xxl),
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
                          if (team != null)
                            TeamLogoView(
                              team: team,
                              size: 32,
                              // 원형 대신 soft 사각 — 기본 로고일 때 방패 모양이
                              // 잘리지 않도록. 업로드 사진도 부드럽게 라운드.
                              borderRadius: AppRadius.smoothSm,
                            )
                          else
                            Container(
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
                            ),
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
          shape: RoundedRectangleBorder(borderRadius: AppRadius.smoothMd),
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

class _TeamSwitcherSheet extends ConsumerWidget {
  const _TeamSwitcherSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamsAsync = ref.watch(myTeamsProvider);
    final currentAsync = ref.watch(currentTeamProvider);
    final currentId = currentAsync.asData?.value?.id;

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
            teamsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Text(
                  '팀 목록을 불러오지 못했어요',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              data: (teams) => Column(
                children: [
                  for (final team in teams)
                    _TeamSwitcherItem(
                      team: team,
                      isCurrent: team.id == currentId,
                      onTap: () => _onSelect(context, ref, team.id),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/team/create');
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md,
                  ),
                  decoration: ShapeDecoration(
                    color: AppColors.surfaceLight,
                    shape: RoundedRectangleBorder(
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
                        '새 팀 만들기',
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

  Future<void> _onSelect(
      BuildContext context, WidgetRef ref, String teamId) async {
    HapticFeedback.selectionClick();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final supa = ref.read(supabaseClientProvider);
    final uid = supa.auth.currentUser?.id;
    if (uid == null) {
      navigator.pop();
      return;
    }

    try {
      await ref
          .read(teamServiceProvider)
          .switchTeam(playerId: uid, teamId: teamId);
      ref.invalidate(currentTeamProvider);
      ref.invalidate(currentTeamIdProvider);
      ref.invalidate(teamMatchesProvider);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('팀 전환 실패: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    navigator.pop();
  }
}

class _TeamSwitcherItem extends StatelessWidget {
  const _TeamSwitcherItem({
    required this.team,
    required this.isCurrent,
    required this.onTap,
  });

  final Team team;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
            TeamLogoView(
              team: team,
              size: 40,
              borderRadius: AppRadius.smoothXs,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    team.name,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight:
                          isCurrent ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  if (team.description != null &&
                      team.description!.isNotEmpty)
                    Text(
                      team.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
            if (isCurrent)
              const Icon(
                Icons.check_rounded,
                size: 20,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}
