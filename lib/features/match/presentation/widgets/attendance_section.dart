import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

import '../../../../shared/widgets/section_title.dart';

class AttendanceSection extends StatelessWidget {
  const AttendanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('상세 정보'),
          const SizedBox(height: 16),
          // 일정
          _InfoRow(
            icon: Icons.calendar_today,
            text: '3월 7일 토요일 10:00 ~ 12:00',
          ),
          const SizedBox(height: 16),
          // 위치
          _InfoRow(
            icon: Icons.location_on_outlined,
            text: '강동구 성내유수지',
          ),
          const SizedBox(height: 16),
          // 참가 인원
          _InfoRow(
            icon: Icons.people_outline,
            text: '13/16명 참가',
          ),
          const SizedBox(height: 24),
          // 용병초대 버튼
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF2F4F6),
                foregroundColor: const Color(0xFF333D4B),
                elevation: 0,
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 12,
                    cornerSmoothing: 1.0,
                  ),
                ),
              ),
              child: const Text(
                '용병초대',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
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
        Icon(icon, size: 20, color: const Color(0xFF8E97A3)),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333D4B),
          ),
        ),
      ],
    );
  }
}
