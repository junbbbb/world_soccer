import 'package:flutter/material.dart';

import 'widgets/next_match_card.dart';
import 'widgets/team_posts_section.dart';
import 'widgets/team_recent_results_section.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // 상단 헤더 (로고 영역)
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 16),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/fc_calor.png',
                  width: 32,
                  height: 32,
                ),
                const SizedBox(width: 10),
                const Text(
                  '칼로FC',
                  style: TextStyle(
                    fontFamily: 'SCDream',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333D4B),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF8E97A3),
                  size: 24,
                ),
              ],
            ),
          ),
          Expanded(
            child: const SingleChildScrollView(
              child: Column(
                children: [
                  NextMatchCard(),
                  SizedBox(height: 32),
                  TeamRecentResultsSection(),
                  SizedBox(height: 32),
                  TeamPostsSection(),
                  SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
