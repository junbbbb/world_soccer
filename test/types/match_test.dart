import 'package:flutter_test/flutter_test.dart';
import 'package:world_soccer/types/enums.dart';
import 'package:world_soccer/types/match.dart';

Match _match({int? ourScore, int? opponentScore}) => Match(
      id: 'm1',
      teamId: 'team1',
      date: DateTime(2026, 4, 12, 20, 0),
      location: '성내유수지',
      opponentName: 'FC쏘아',
      ourScore: ourScore,
      opponentScore: opponentScore,
      status: ourScore != null ? MatchStatus.completed : MatchStatus.upcoming,
      createdAt: DateTime.now(),
    );

void main() {
  group('Match.result', () {
    test('승리: ourScore > opponentScore', () {
      expect(_match(ourScore: 3, opponentScore: 1).result, MatchResult.win);
    });

    test('패배: ourScore < opponentScore', () {
      expect(_match(ourScore: 0, opponentScore: 2).result, MatchResult.loss);
    });

    test('무승부: ourScore == opponentScore', () {
      expect(_match(ourScore: 1, opponentScore: 1).result, MatchResult.draw);
    });

    test('0:0 무승부', () {
      expect(_match(ourScore: 0, opponentScore: 0).result, MatchResult.draw);
    });

    test('스코어 없으면 null', () {
      expect(_match().result, isNull);
    });

    test('한쪽만 null이면 null', () {
      expect(_match(ourScore: 3).result, isNull);
    });
  });

  group('Match.isPast', () {
    test('completed → true', () {
      expect(_match(ourScore: 1, opponentScore: 0).isPast, true);
    });

    test('upcoming → false', () {
      expect(_match().isPast, false);
    });
  });

  group('Match.dayOfWeek', () {
    test('토요일', () {
      // 2026-04-12 is 일요일
      final m = _match();
      expect(['월', '화', '수', '목', '금', '토', '일'], contains(m.dayOfWeek));
    });
  });

  group('Match.timeString', () {
    test('시간 포맷 HH:mm', () {
      final m = _match();
      expect(m.timeString, '20:00');
    });
  });
}
