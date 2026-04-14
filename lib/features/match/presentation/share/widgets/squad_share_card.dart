import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../lineup/models/lineup_models.dart';
import 'static_pitch_card.dart';

/// 한 쿼터용 공유 이미지 카드.
///
/// 레이아웃 (위→아래):
///   1. 쿼터 뱃지 + 포메이션
///   2. 팀 로고 VS 팀 로고 + 팀명
///   3. 날짜/시간/장소 한 줄
///   4. 정적 피치 (StaticPitchCard)
///   5. 벤치 명단
///   6. 푸터 (브랜딩)
///
/// 이 위젯을 RepaintBoundary로 감싸서 PNG로 캡처하면 공유 이미지가 된다.
/// 디자인 단계에선 화면에 직접 표시하여 확인용으로 쓴다.
class SquadShareCard extends StatelessWidget {
  const SquadShareCard({
    required this.quarterIndex,
    required this.formation,
    required this.slotMembers,
    required this.benchMembers,
    super.key,
  });

  final int quarterIndex;
  final Formation formation;
  final Map<int, LineupMember> slotMembers;
  final List<LineupMember> benchMembers;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Header(
            quarterIndex: quarterIndex,
            formationName: formation.name,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.base,
            ),
            child: StaticPitchCard(
              formation: formation,
              slotMembers: slotMembers,
            ),
          ),
          _BenchSection(members: benchMembers),
          const _Footer(),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// Header
// ══════════════════════════════════════════════

class _Header extends StatelessWidget {
  const _Header({
    required this.quarterIndex,
    required this.formationName,
  });

  final int quarterIndex;
  final String formationName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        children: [
          // Q뱃지 + 포메이션
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: ShapeDecoration(
                  color: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.smoothXs,
                  ),
                ),
                child: Text(
                  'Q${quarterIndex + 1}',
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                formationName,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // 팀 VS 팀 (로고 + 이름 한 줄)
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ClipRRect(
                      borderRadius: AppRadius.smoothXs,
                      child: Image.asset(
                        'assets/images/logo_calo.png',
                        width: 28,
                        height: 28,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'FC칼로',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                child: Text(
                  'VS',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: AppRadius.smoothXs,
                      child: Image.asset(
                        'assets/images/logo_ssoa.png',
                        width: 28,
                        height: 28,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'FC쏘아',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // 날짜 · 장소 한 줄
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 12,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                '2/7 (토) 20:00',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                ),
                child: Container(
                  width: 2,
                  height: 2,
                  decoration: const BoxDecoration(
                    color: AppColors.iconInactive,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const Icon(
                Icons.place_rounded,
                size: 12,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                '성내유수지',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// Bench
// ══════════════════════════════════════════════

class _BenchSection extends StatelessWidget {
  const _BenchSection({required this.members});
  final List<LineupMember> members;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.base,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      decoration: ShapeDecoration(
        color: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.smoothSm,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.event_seat_rounded,
                size: 13,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '벤치 ${members.length}명',
                style: AppTextStyles.captionMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          if (members.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              members.map((m) => m.name).join('  ·  '),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ] else ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              '벤치 없음',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// Footer
// ══════════════════════════════════════════════

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.base),
      child: Text(
        'CALOR FC  ·  2025-26 SEASON',
        textAlign: TextAlign.center,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.iconInactive,
          letterSpacing: 2,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
