import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/dev_settings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/snackbar.dart';
import '../../../../runtime/providers.dart';
import '../../../../shared/widgets/info_capsule.dart';
import '../../../../shared/widgets/match_badges.dart';
import '../../../../shared/widgets/match_time_info.dart';
import '../../../../shared/widgets/team_logo_badge.dart';
import '../../../../types/enums.dart';
import '../../../../types/match.dart' show Match;
import 'join_match_sheet.dart';

/// 홈 카드에 표시할 경기 선택.
///
/// 1. 예정/진행 중 경기가 있으면 가장 가까운 것을 표시.
/// 2. 없으면 종료/결과입력 경기 중 가장 최근 것을 표시 (다음날 06시까지).
/// 3. 둘 다 있으면: 다음 경기가 종료 경기의 visibilityDeadline 안에 있으면
///    (같은날 or 다음날 아침) 다음 경기를 우선 표시.
Match? _pickHomeMatch(List<Match> matchList) {
  final visible = matchList.where((m) => m.isVisibleOnHome).toList();
  if (visible.isEmpty) return null;

  // 예정/진행 중 → 날짜순 가장 가까운 것
  final upcoming = visible
      .where((m) =>
          m.displayState == MatchDisplayState.upcoming ||
          m.displayState == MatchDisplayState.inProgress)
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  // 종료/결과입력 → 날짜순 가장 최근 것
  final finished = visible
      .where((m) =>
          m.displayState == MatchDisplayState.ended ||
          m.displayState == MatchDisplayState.earlyEnded ||
          m.displayState == MatchDisplayState.completed)
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  final nearestUpcoming = upcoming.isNotEmpty ? upcoming.first : null;
  final latestFinished = finished.isNotEmpty ? finished.first : null;

  if (nearestUpcoming == null) return latestFinished;
  if (latestFinished == null) return nearestUpcoming;

  // 다음 경기가 종료 경기의 visibility 기한 안이면 → 다음 경기 우선
  if (nearestUpcoming.date.isBefore(latestFinished.visibilityDeadline)) {
    return nearestUpcoming;
  }
  return latestFinished;
}

class NextMatchCard extends ConsumerStatefulWidget {
  const NextMatchCard({super.key, this.hasNextMatch = true});

  final bool hasNextMatch;

  static final _cardRadius = BorderRadius.circular(AppRadius.md);

  @override
  ConsumerState<NextMatchCard> createState() => _NextMatchCardState();
}

class _NextMatchCardState extends ConsumerState<NextMatchCard> {
  /// 더미 모드 전용 로컬 토글. 실데이터는 `isParticipatingProvider` 사용.
  bool _dummyJoined = false;
  bool _busy = false;

  void _showError(String message) {
    if (!mounted) return;
    context.showError(message);
  }

  /// 짧게 탭 → 프로필 선호 포지션으로 바로 참가 (전 쿼터).
  /// 이미 참가 상태면 참가 취소.
  Future<void> _onParticipateTap(Match? match, bool currentlyJoined) async {
    if (_busy) return;
    HapticFeedback.mediumImpact();

    if (ref.read(showDummyDataProvider) || match == null) {
      setState(() => _dummyJoined = !_dummyJoined);
      return;
    }

    final user = ref.read(supabaseClientProvider).auth.currentUser;
    if (user == null) {
      _showError('로그인이 필요합니다');
      return;
    }

    setState(() => _busy = true);
    try {
      final service = ref.read(matchServiceProvider);
      if (currentlyJoined) {
        await service.leaveMatch(matchId: match.id, playerId: user.id);
        ref.invalidate(isParticipatingProvider(match.id));
        return;
      }

      final player = await ref.read(currentPlayerProvider.future);
      if (player == null || player.preferredPositions.isEmpty) {
        _showError('프로필에서 선호 포지션을 먼저 설정해주세요');
        return;
      }
      await service.joinMatch(
        matchId: match.id,
        playerId: user.id,
        preferredPositions: player.preferredPositions,
        availableQuarters: const [1, 2, 3, 4],
      );
      ref.invalidate(isParticipatingProvider(match.id));
    } catch (e) {
      _showError('참가 처리 실패: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// 길게 누름 → 기존 바텀시트에서 포지션/쿼터 커스텀 입력.
  Future<void> _onParticipateLongPress(Match? match) async {
    if (_busy) return;
    HapticFeedback.heavyImpact();

    if (ref.read(showDummyDataProvider) || match == null) {
      final result = await showJoinMatchSheet(context);
      if (!mounted || result == null) return;
      setState(() => _dummyJoined = true);
      return;
    }

    final user = ref.read(supabaseClientProvider).auth.currentUser;
    if (user == null) {
      _showError('로그인이 필요합니다');
      return;
    }

    final result = await showJoinMatchSheet(context);
    if (!mounted || result == null) return;

    setState(() => _busy = true);
    try {
      await ref.read(matchServiceProvider).joinMatch(
        matchId: match.id,
        playerId: user.id,
        preferredPositions: result.preferredPositions.toList(),
        availableQuarters: result.availableQuarters.toList(),
      );
      ref.invalidate(isParticipatingProvider(match.id));
    } catch (e) {
      _showError('참가 처리 실패: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static const _animDuration = Duration(milliseconds: 350);
  static const _animCurve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    if (!widget.hasNextMatch) return const _EmptyMatchCard();

    final showDummy = ref.watch(showDummyDataProvider);

    // 실제 팀 데이터
    final team = ref.watch(currentTeamProvider).when(
          data: (t) => t,
          loading: () => null,
          error: (_, __) => null,
        );

    // 실제 다음 경기 데이터
    final matchList = ref.watch(teamMatchesProvider).when<List<Match>>(
          data: (list) => list,
          loading: () => [],
          error: (_, __) => [],
        );
    final match = showDummy ? null : _pickHomeMatch(matchList);
    final isMatchEnded = match != null && match.isFinished;

    // 참가 여부: 실데이터 모드면 서버에서 조회, 더미면 로컬 토글.
    final isJoined = (match == null || showDummy)
        ? _dummyJoined
        : ref.watch(isParticipatingProvider(match.id)).maybeWhen(
              data: (v) => v,
              orElse: () => false,
            );

    // 표시할 값
    final ourName = showDummy ? 'FC칼로' : (team?.name ?? '...');
    final ourLogoPath = showDummy ? 'assets/images/logo_calo.png' : null;
    final ourLogoUrl = showDummy ? null : team?.logoUrl;

    final opponentName = showDummy ? 'FC쏘아' : (match?.opponentName ?? '미정');
    final opponentLogoPath = showDummy ? 'assets/images/logo_ssoa.png' : null;

    final timeStr = showDummy ? '20:00' : (match?.timeString ?? '--:--');
    final datePlaceStr = showDummy
        ? '2/7(토) 성내유수지'
        : match != null
            ? '${match.date.month}/${match.date.day}(${match.dayOfWeek}) ${match.location}'
            : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GestureDetector(
        onTap: () => context.push('/match', extra: match?.id),
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Center(
                              child: TeamLogoBadge(
                                teamName: ourName,
                                logoPath: ourLogoPath,
                                logoUrl: ourLogoUrl,
                                size: 52,
                              ),
                            ),
                          ),
                          MatchTimeInfo(
                            time: timeStr,
                            datePlace: datePlaceStr,
                          ),
                          Expanded(
                            child: Center(
                              child: TeamLogoBadge(
                                teamName: opponentName,
                                logoPath: opponentLogoPath,
                                size: 52,
                                isOpponent: true,
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
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: AnimatedSize(
                            duration: _animDuration,
                            curve: _animCurve,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (showDummy) ...[
                                  const InfoCapsule(text: '13/16명'),
                                  const SizedBox(width: AppSpacing.sm),
                                  const InfoCapsule(text: '리벤지 매치'),
                                ] else ...[
                                  ...buildMatchBadges(matchList, match),
                                ],
                                if (isJoined) ...[
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

              // ── 구분선 + 참가하기 버튼 (경기 종료 시 숨김) ──
              AnimatedSize(
                duration: _animDuration,
                curve: _animCurve,
                alignment: Alignment.topCenter,
                child: (isJoined || isMatchEnded)
                    ? const SizedBox(width: double.infinity)
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                          _ParticipateButton(
                            onTap: () => _onParticipateTap(match, isJoined),
                            onLongPress: () =>
                                _onParticipateLongPress(match),
                          ),
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
  const _ParticipateButton({
    required this.onTap,
    required this.onLongPress,
    this.label = '참가하기',
  });
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final String label;

  @override
  State<_ParticipateButton> createState() => _ParticipateButtonState();
}

class _ParticipateButtonState extends State<_ParticipateButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: _pressed ? 0.7 : 1.0,
        child: CustomPaint(
          painter: const _EllipticalGradientPainter(),
          child: SizedBox(
            height: 55,
            width: double.infinity,
            child: Center(
              child: Text(
                widget.label,
                style: const TextStyle(
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
