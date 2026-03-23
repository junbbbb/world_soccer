import 'dart:ui';

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/section_title.dart';

// ── 더미 데이터 ──

const _teamInfo = _TeamInfo(
  name: 'FC칼로',
  foundedYear: 2020,
  region: '서울 강동구',
  memberCount: 24,
  activityDay: '매주 토요일',
  totalRecord: '48승 12무 8패',
  seasonBest: '5연승',
);

const _dummyMembers = [
  // GK
  _Member(name: '박서준', position: 'GK', number: 1, avatarPath: 'assets/images/avatars/RAYA_Headshot_web_njztl3wr.avif'),
  _Member(name: '한준혁', position: 'GK', number: 21, avatarPath: 'assets/images/avatars/RAYA_Headshot_web_njztl3wr.avif'),
  // DF
  _Member(name: '윤태경', position: 'DF', number: 2, avatarPath: 'assets/images/avatars/SALIBA_Headshot_web_khl9z1vw.avif'),
  _Member(name: '정도현', position: 'DF', number: 4, avatarPath: 'assets/images/avatars/SALIBA_Headshot_web_khl9z1vw.avif'),
  _Member(name: '김재윤', position: 'DF', number: 5, avatarPath: 'assets/images/avatars/SALIBA_Headshot_web_khl9z1vw.avif'),
  _Member(name: '이현우', position: 'DF', number: 15, avatarPath: 'assets/images/avatars/SALIBA_Headshot_web_khl9z1vw.avif'),
  _Member(name: '송민호', position: 'DF', number: 23, avatarPath: 'assets/images/avatars/SALIBA_Headshot_web_khl9z1vw.avif'),
  // MF
  _Member(name: '이병준', position: 'MF', number: 7, avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif'),
  _Member(name: '최민수', position: 'MF', number: 8, avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif'),
  _Member(name: '윤서준', position: 'MF', number: 10, avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif'),
  _Member(name: '강지훈', position: 'MF', number: 14, avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif'),
  _Member(name: '조원빈', position: 'MF', number: 16, avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif'),
  _Member(name: '배준서', position: 'MF', number: 18, avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif'),
  _Member(name: '임시우', position: 'MF', number: 22, avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif'),
  // FW
  _Member(name: '김태호', position: 'FW', number: 9, avatarPath: 'assets/images/avatars/MOSQUERA_Headshot_web_b3sucu1j.avif'),
  _Member(name: '박정우', position: 'FW', number: 11, avatarPath: 'assets/images/avatars/MOSQUERA_Headshot_web_b3sucu1j.avif'),
  _Member(name: '신유찬', position: 'FW', number: 17, avatarPath: 'assets/images/avatars/MOSQUERA_Headshot_web_b3sucu1j.avif'),
  _Member(name: '오준영', position: 'FW', number: 19, avatarPath: 'assets/images/avatars/MOSQUERA_Headshot_web_b3sucu1j.avif'),
];

// ── 모델 ──

class _TeamInfo {
  final String name;
  final int foundedYear;
  final String region;
  final int memberCount;
  final String activityDay;
  final String totalRecord;
  final String seasonBest;

  const _TeamInfo({
    required this.name,
    required this.foundedYear,
    required this.region,
    required this.memberCount,
    required this.activityDay,
    required this.totalRecord,
    required this.seasonBest,
  });
}

class _Member {
  final String name;
  final String position;
  final int number;
  final String avatarPath;

  const _Member({
    required this.name,
    required this.position,
    required this.number,
    required this.avatarPath,
  });
}

// ── TeamTab ──

class TeamTab extends StatelessWidget {
  const TeamTab({super.key});

  static const _headerHeight = 56.0;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(top: topPadding + _headerHeight),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TeamInfoSection(),
              SizedBox(height: AppSpacing.xxl),
              _TeamSummarySection(),
              SizedBox(height: AppSpacing.xxl),
              _TeamMembersSection(),
              SizedBox(height: AppSpacing.xxxl),
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
                      '팀',
                      style: AppTextStyles.pageTitle.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.settings_outlined,
                      color: AppColors.textTertiary,
                      size: 24,
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

// ── 팀 정보 섹션 ──

class _TeamInfoSection extends StatelessWidget {
  const _TeamInfoSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingPage,
      child: Column(
        children: [
          ClipSmoothRect(
            radius: AppRadius.smoothLg,
            child: Image.asset(
              'assets/images/logo_calo.png',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _teamInfo.name,
            style: AppTextStyles.sectionTitle.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${_teamInfo.foundedYear}년 창단 · ${_teamInfo.region}',
            style: AppTextStyles.bodyRegular.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _InfoBadge(label: '${_teamInfo.memberCount}명'),
              const SizedBox(width: AppSpacing.sm),
              _InfoBadge(label: _teamInfo.activityDay),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: ShapeDecoration(
        color: AppColors.surface,
        shape: SmoothRectangleBorder(
          borderRadius: AppRadius.smoothFull,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.captionMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ── 팀 기록 요약 섹션 ──

class _TeamSummarySection extends StatelessWidget {
  const _TeamSummarySection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingPage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('팀 기록'),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: '통산 전적',
                  value: _teamInfo.totalRecord,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _SummaryCard(
                  label: '시즌 최고',
                  value: _teamInfo.seasonBest,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: ShapeDecoration(
        color: AppColors.surfaceLight,
        shape: SmoothRectangleBorder(
          borderRadius: AppRadius.smoothMd,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.heading.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 팀원 목록 섹션 ──

class _TeamMembersSection extends StatelessWidget {
  const _TeamMembersSection();

  static const _positionOrder = ['GK', 'DF', 'MF', 'FW'];
  static const _positionLabels = {
    'GK': '골키퍼',
    'DF': '수비수',
    'MF': '미드필더',
    'FW': '공격수',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingPage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('팀원'),
          GestureDetector(
            onTap: () {
              // TODO: 멤버 추가
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              decoration: ShapeDecoration(
                color: AppColors.surface,
                shape: SmoothRectangleBorder(
                  borderRadius: AppRadius.smoothMd,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '멤버 추가',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ..._positionOrder.map((pos) {
            final members =
                _dummyMembers.where((m) => m.position == pos).toList();
            if (members.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${_positionLabels[pos]} (${members.length})',
                  style: AppTextStyles.captionMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...members.map((m) => _MemberRow(member: m)),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.member});

  final _Member member;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          ClipSmoothRect(
            radius: AppRadius.smoothSm,
            child: Image.asset(
              member.avatarPath,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${member.position} · #${member.number}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.phone_outlined,
            size: 20,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}
