import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/dev_settings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../runtime/providers.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../../../types/match.dart' show Match;

class AttendanceSection extends ConsumerWidget {
  const AttendanceSection({super.key, this.matchId});

  final String? matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showDummy = ref.watch(showDummyDataProvider);

    if (showDummy || matchId == null) {
      return Padding(
        padding: AppSpacing.paddingSection,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SectionTitle('상세 정보'),
            _InfoRow(icon: Icons.calendar_today, text: '3월 7일 토요일 10:00 ~ 12:00'),
            SizedBox(height: AppSpacing.base),
            _InfoRow(icon: Icons.location_on_outlined, text: '강동구 성내유수지'),
            SizedBox(height: AppSpacing.base),
            _InfoRow(icon: Icons.people_outline, text: '13/16명 참가'),
          ],
        ),
      );
    }

    final matchList = ref.watch(teamMatchesProvider).when<List<Match>>(
          data: (list) => list,
          loading: () => [],
          error: (_, __) => [],
        );
    final match = matchList.where((m) => m.id == matchId).firstOrNull;
    if (match == null) return const SizedBox.shrink();

    // 날짜/시간
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final d = match.date;
    final end = match.endTime;
    final dateStr =
        '${d.month}월 ${d.day}일 ${weekdays[d.weekday - 1]}요일 '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}'
        ' ~ '
        '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: AppSpacing.paddingSection,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('상세 정보'),
          _InfoRow(icon: Icons.calendar_today, text: dateStr),
          const SizedBox(height: AppSpacing.base),
          _InfoRow(
            icon: Icons.location_on_outlined,
            text: match.location.isNotEmpty ? match.location : '장소 미정',
          ),
          const SizedBox(height: AppSpacing.base),
          _InfoRow(
            icon: Icons.timer_outlined,
            text: '${match.durationMinutes}분',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textPrimary),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
