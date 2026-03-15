import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

import '../../../../shared/widgets/section_title.dart';

class _MatchResult {
  final String result;
  final String score;
  final String opponentLogo;

  const _MatchResult({
    required this.result,
    required this.score,
    required this.opponentLogo,
  });
}

const _dummyResults = [
  _MatchResult(result: 'W', score: '3 - 1', opponentLogo: 'assets/images/fc_bosong.png'),
  _MatchResult(result: 'L', score: '1 - 2', opponentLogo: 'assets/images/fc_calor.png'),
  _MatchResult(result: 'W', score: '4 - 0', opponentLogo: 'assets/images/fc_bosong.png'),
  _MatchResult(result: 'D', score: '2 - 2', opponentLogo: 'assets/images/fc_calor.png'),
  _MatchResult(result: 'W', score: '2 - 1', opponentLogo: 'assets/images/fc_bosong.png'),
];

class TeamRecentResultsSection extends StatelessWidget {
  const TeamRecentResultsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 24, right: 24, bottom: 4),
          child: SectionTitle('팀 최근전적'),
        ),
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _dummyResults.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return _ResultCapsule(result: _dummyResults[index]);
            },
          ),
        ),
        const SizedBox(height: 0),
      ],
    );
  }
}

class _ResultCapsule extends StatelessWidget {
  const _ResultCapsule({required this.result});

  final _MatchResult result;

  String get _resultLabel {
    switch (result.result) {
      case 'W':
        return '승';
      case 'L':
        return '패';
      case 'D':
        return '무';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const ShapeDecoration(
        color: Color(0xFFF6F7F9),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.all(
            SmoothRadius(cornerRadius: 8, cornerSmoothing: 1.0),
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _resultLabel,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF333D4B),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            result.score,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7684),
            ),
          ),
          const SizedBox(width: 10),
          ClipSmoothRect(
            radius: const SmoothBorderRadius.all(
              SmoothRadius(cornerRadius: 4, cornerSmoothing: 1.0),
            ),
            child: Image.asset(
              result.opponentLogo,
              width: 22,
              height: 22,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
