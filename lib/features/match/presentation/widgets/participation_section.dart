import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/section_title.dart';

class ParticipationSection extends StatelessWidget {
  const ParticipationSection({super.key});

  static const _avA = 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif';
  static const _avB = 'assets/images/avatars/MOSQUERA_Headshot_web_b3sucu1j.avif';
  static const _avC = 'assets/images/avatars/SALIBA_Headshot_web_khl9z1vw.avif';
  static const _avD = 'assets/images/avatars/RAYA_Headshot_web_njztl3wr.avif';

  static const _avatars = [_avA, _avB, _avC, _avD];

  static const _players = [
    '김민수',
    '이정호',
    '박서준',
    '최영민',
    '정대현',
    '송재윤',
    '한동우',
    '오승환',
    '윤태경',
    '임현수',
    '강지훈',
    '배준혁',
    '조민기',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingSection,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('참가 현황'),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: AppSpacing.base,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 0.82,
            ),
            itemCount: _players.length,
            itemBuilder: (_, i) => _ParticipantTile(
              name: _players[i],
              avatarPath: _avatars[i % _avatars.length],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: SmoothRectangleBorder(
                  borderRadius: AppRadius.smoothMd,
                ),
              ),
              child:
                  const Text('용병초대', style: AppTextStyles.buttonSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile({
    required this.name,
    required this.avatarPath,
  });

  final String name;
  final String avatarPath;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipOval(
          child: Image.asset(
            avatarPath,
            width: 52,
            height: 52,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
