import 'package:flutter/material.dart';
import '../../../../shared/widgets/player_chip.dart';
import '../../../../shared/widgets/section_title.dart';

class AttendanceSection extends StatelessWidget {
  const AttendanceSection({super.key});

  static const _dummyPlayers = [
    (number: 9, name: '이병준'),
    (number: 4, name: '성준혁'),
    (number: 10, name: '정범석'),
    (number: 7, name: '김효진'),
    (number: 7, name: '김효진'),
  ];

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      ..._dummyPlayers.map((p) => PlayerChip(number: p.number, name: p.name)),
      const MoreChip(),
    ];

    final rows = <Widget>[];
    for (var i = 0; i < chips.length; i += 3) {
      final end = (i + 3 > chips.length) ? chips.length : i + 3;
      final rowChildren = <Widget>[];
      for (var j = i; j < end; j++) {
        if (j > i) rowChildren.add(const SizedBox(width: 8));
        rowChildren.add(Expanded(child: chips[j]));
      }
      // 빈 칸 채우기 (마지막 줄이 3개 미만일 때)
      final count = end - i;
      for (var k = count; k < 3; k++) {
        rowChildren.add(const SizedBox(width: 8));
        rowChildren.add(const Expanded(child: SizedBox.shrink()));
      }
      rows.add(Row(children: rowChildren));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('참가현황'),
          ...rows.expand((row) => [row, const SizedBox(height: 8)]),
        ],
      ),
    );
  }
}
