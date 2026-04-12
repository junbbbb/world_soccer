import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:world_soccer/config/app_constants.dart';
import 'package:world_soccer/repo/lineup_repo.dart';
import 'package:world_soccer/repo/player_repo.dart';
import 'package:world_soccer/service/lineup_service.dart';
import 'package:world_soccer/types/enums.dart';
import 'package:world_soccer/types/lineup.dart';
import 'package:world_soccer/types/player.dart';

@GenerateMocks([LineupRepo, PlayerRepo])
import 'lineup_service_test.mocks.dart';

// ── 테스트 헬퍼 ──

LineupMember _member(String id, PositionGroup pos, {int? number}) =>
    LineupMember(
        id: id, name: '선수$id', preferredPosition: pos, number: number);

List<LineupMember> _roster16() => [
      _member('1', PositionGroup.gk, number: 1),
      _member('21', PositionGroup.gk, number: 21),
      _member('2', PositionGroup.df, number: 2),
      _member('4', PositionGroup.df, number: 4),
      _member('5', PositionGroup.df, number: 5),
      _member('15', PositionGroup.df, number: 15),
      _member('23', PositionGroup.df, number: 23),
      _member('7', PositionGroup.mf, number: 7),
      _member('8', PositionGroup.mf, number: 8),
      _member('10', PositionGroup.mf, number: 10),
      _member('14', PositionGroup.mf, number: 14),
      _member('16', PositionGroup.mf, number: 16),
      _member('9', PositionGroup.fw, number: 9),
      _member('11', PositionGroup.fw, number: 11),
      _member('17', PositionGroup.fw, number: 17),
      _member('19', PositionGroup.fw, number: 19),
    ];

List<QuarterLineup> _emptyQuarters() =>
    List.generate(4, (i) => QuarterLineup.empty(0));

void main() {
  late MockLineupRepo mockLineupRepo;
  late MockPlayerRepo mockPlayerRepo;
  late LineupService service;

  setUp(() {
    mockLineupRepo = MockLineupRepo();
    mockPlayerRepo = MockPlayerRepo();
    service = LineupService(
      lineupRepo: mockLineupRepo,
      playerRepo: mockPlayerRepo,
    );
  });

  group('distributeAll - 전체 자동 분배', () {
    test('16명 로스터, 4-4-2 → 모든 슬롯 채워짐', () {
      final roster = _roster16();
      final formation = defaultFormations[0]; // 4-4-2, 11슬롯

      final result = service.distributeAll(
        roster: roster,
        formations: defaultFormations,
        currentQuarters: _emptyQuarters(),
      );

      for (final q in result) {
        expect(q.slotToMemberId.length, formation.slots.length,
            reason: '모든 슬롯이 채워져야 함');
      }
    });

    test('16명 로스터, 4-4-2 → 한 쿼터에 같은 선수 중복 없음', () {
      final roster = _roster16();

      final result = service.distributeAll(
        roster: roster,
        formations: defaultFormations,
        currentQuarters: _emptyQuarters(),
      );

      for (var i = 0; i < result.length; i++) {
        final ids = result[i].slotToMemberId.values.toList();
        expect(ids.toSet().length, ids.length,
            reason: '쿼터 ${i + 1}에 중복 선수 없어야 함');
      }
    });

    test('16명 로스터 → 모든 선수 최소 2쿼터 출전', () {
      final roster = _roster16();

      final result = service.distributeAll(
        roster: roster,
        formations: defaultFormations,
        currentQuarters: _emptyQuarters(),
      );

      final playCount = <String, int>{};
      for (final q in result) {
        for (final id in q.slotToMemberId.values) {
          playCount[id] = (playCount[id] ?? 0) + 1;
        }
      }

      for (final m in roster) {
        expect(playCount[m.id] ?? 0, greaterThanOrEqualTo(2),
            reason: '${m.name}이 최소 2쿼터 출전해야 함');
      }
    });

    test('16명 로스터 → 누구도 4쿼터 초과 안 함', () {
      final roster = _roster16();

      final result = service.distributeAll(
        roster: roster,
        formations: defaultFormations,
        currentQuarters: _emptyQuarters(),
      );

      final playCount = <String, int>{};
      for (final q in result) {
        for (final id in q.slotToMemberId.values) {
          playCount[id] = (playCount[id] ?? 0) + 1;
        }
      }

      for (final entry in playCount.entries) {
        expect(entry.value, lessThanOrEqualTo(4),
            reason: '선수 ${entry.key}가 4쿼터 초과');
      }
    });

    test('11명 로스터 (딱 1팀분) → 모든 선수 4쿼터 풀출전', () {
      final roster = _roster16().sublist(0, 11);

      final result = service.distributeAll(
        roster: roster,
        formations: defaultFormations,
        currentQuarters: _emptyQuarters(),
      );

      final playCount = <String, int>{};
      for (final q in result) {
        for (final id in q.slotToMemberId.values) {
          playCount[id] = (playCount[id] ?? 0) + 1;
        }
      }

      for (final m in roster) {
        expect(playCount[m.id], 4,
            reason: '${m.name}이 4쿼터 풀출전해야 함');
      }
    });

    test('포지션 우선 배치: GK 슬롯에 GK 선수 우선', () {
      final roster = _roster16();

      final result = service.distributeAll(
        roster: roster,
        formations: defaultFormations,
        currentQuarters: _emptyQuarters(),
      );

      for (final q in result) {
        final gkId = q.slotToMemberId[0];
        if (gkId != null) {
          final member = roster.firstWhere((m) => m.id == gkId);
          expect(member.preferredPosition, PositionGroup.gk,
              reason: 'GK 슬롯에 GK 선수가 배치되어야 함');
        }
      }
    });
  });

  group('fillEmpty - 빈 슬롯만 채우기', () {
    test('일부 수동 배치 후 나머지 자동 채움', () {
      final roster = _roster16();

      final quarters = _emptyQuarters();
      quarters[0] = QuarterLineup(
        formationIndex: 0,
        slotToMemberId: {0: '1'}, // 박서준(GK)
      );

      final result = service.fillEmpty(
        roster: roster,
        formations: defaultFormations,
        currentQuarters: quarters,
      );

      expect(result[0].slotToMemberId[0], '1', reason: '수동 배치 유지');
      expect(result[0].slotToMemberId.length,
          defaultFormations[0].slots.length,
          reason: '모든 슬롯 채워져야 함');
    });

    test('이미 다 채워진 쿼터는 변경 없음', () {
      final roster = _roster16();

      final fullSlots = <int, String>{};
      for (var i = 0; i < 11; i++) {
        fullSlots[i] = roster[i].id;
      }

      final quarters = _emptyQuarters();
      quarters[0] = QuarterLineup(
        formationIndex: 0,
        slotToMemberId: fullSlots,
      );

      final result = service.fillEmpty(
        roster: roster,
        formations: defaultFormations,
        currentQuarters: quarters,
      );

      expect(result[0].slotToMemberId, fullSlots,
          reason: '이미 채워진 쿼터 변경 없음');
    });
  });

  group('addMercenary - 용병 추가', () {
    test('용병 추가 시 isMercenary=true, id는 고유', () {
      final roster = _roster16();

      final updated = service.addMercenary(
        roster: roster,
        name: '김용병',
        preferredPosition: PositionGroup.fw,
      );

      expect(updated.length, roster.length + 1);
      final merc = updated.last;
      expect(merc.isMercenary, true);
      expect(merc.name, '김용병');
      expect(merc.preferredPosition, PositionGroup.fw);
      expect(merc.number, isNull);
      final existingIds = roster.map((m) => m.id).toSet();
      expect(existingIds.contains(merc.id), false);
    });

    test('빈 이름 → 자동 이름 부여', () {
      final roster = _roster16();

      final updated = service.addMercenary(
        roster: roster,
        name: '',
        preferredPosition: PositionGroup.mf,
      );

      expect(updated.last.name, '용병 1');
    });
  });

  group('saveLineup - 저장 (Repo 호출 검증)', () {
    test('save 호출 시 LineupRepo.save 위임', () async {
      final quarters = {
        1: (formationName: '4-4-2', slotToPlayerId: <int, String>{0: '1'}),
      };

      when(mockLineupRepo.save(
        matchId: 'match-1',
        quarters: quarters,
      )).thenAnswer((_) async {});

      await service.saveLineup(
        matchId: 'match-1',
        quarters: quarters,
      );

      verify(mockLineupRepo.save(
        matchId: 'match-1',
        quarters: quarters,
      )).called(1);
    });
  });
}
