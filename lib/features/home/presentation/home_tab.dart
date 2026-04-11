import 'dart:ui';

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
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

  // 알림 카드 dismiss 상태 (사용자가 X 버튼으로 닫음)
  bool _isProfileCardDismissed = false;
  bool _isResultCardDismissed = false;

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
              if (!_hasProfile && !_isProfileCardDismissed) ...[
                _ProfileSetupCard(
                  onDismiss: () =>
                      setState(() => _isProfileCardDismissed = true),
                ),
                const SizedBox(height: AppSpacing.base),
              ],
              if (_hasNextMatch && !_isResultCardDismissed)
                _MatchResultPromptCard(
                  onDismiss: () =>
                      setState(() => _isResultCardDismissed = true),
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
                      onTap: () {
                        // TODO: 프로필 화면으로 이동
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
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

// ── 알림 카드 (프로필/결과) 공통 스타일 ──
// 일시성을 시각적으로 표현:
// 1) surfaceLight 회색 배경 — 영구 콘텐츠와 구분
// 2) 작은 패딩/폰트 — 보조 정보 톤
// 3) 우측 X 버튼 — 사용자가 닫을 수 있음 = 영구 아님
//    (가장 강력한 일시성 신호)
// 카드 전체 = 액션, X = dismiss로 hit area 분리.

class _ProfileSetupCard extends StatelessWidget {
  const _ProfileSetupCard({required this.onDismiss});
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingPage,
      child: _DismissibleNoticeCard(
        title: '프로필을 완성해주세요',
        subtitle: '팀원들이 나를 알아볼 수 있어요',
        onTap: () {
          // TODO: 프로필 편집 화면으로 이동
        },
        onDismiss: onDismiss,
      ),
    );
  }
}

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
    this.subtitle,
    required this.onTap,
    required this.onDismiss,
  });

  final String title;
  final String? subtitle;
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
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
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

