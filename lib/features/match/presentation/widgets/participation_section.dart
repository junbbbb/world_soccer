import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/player_chip.dart';
import '../../../../shared/widgets/section_title.dart';

class ParticipationSection extends StatelessWidget {
  const ParticipationSection({super.key});

  static const _players = [
    (number: 7, name: '김민수'),
    (number: 10, name: '이정호'),
    (number: 3, name: '박서준'),
    (number: 14, name: '최영민'),
    (number: 9, name: '정대현'),
    (number: 5, name: '송재윤'),
    (number: 11, name: '한동우'),
    (number: 8, name: '오승환'),
    (number: 2, name: '윤태경'),
    (number: 17, name: '임현수'),
    (number: 6, name: '강지훈'),
    (number: 13, name: '배준혁'),
    (number: 4, name: '조민기'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingSection,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('참가 현황'),
          ...List.generate(
            (_players.length / 2).ceil(),
            (rowIndex) {
              final left = _players[rowIndex * 2];
              final rightIndex = rowIndex * 2 + 1;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: rightIndex < _players.length || rowIndex * 2 < _players.length - 1
                      ? AppSpacing.sm
                      : 0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: PlayerChip(
                        number: left.number,
                        name: left.name,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    if (rightIndex < _players.length)
                      Expanded(
                        child: PlayerChip(
                          number: _players[rightIndex].number,
                          name: _players[rightIndex].name,
                        ),
                      )
                    else
                      const Expanded(child: SizedBox.shrink()),
                  ],
                ),
              );
            },
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
