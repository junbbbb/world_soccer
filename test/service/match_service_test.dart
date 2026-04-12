import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:world_soccer/repo/match_repo.dart';
import 'package:world_soccer/repo/player_repo.dart';
import 'package:world_soccer/service/match_service.dart';
import 'package:world_soccer/types/enums.dart';
import 'package:world_soccer/types/match.dart';

@GenerateMocks([MatchRepo, PlayerRepo])
import 'match_service_test.mocks.dart';

// ── 테스트 헬퍼 ──

Match _match({
  String id = 'm1',
  String teamId = 'team1',
  int? ourScore,
  int? opponentScore,
  MatchStatus status = MatchStatus.upcoming,
}) =>
    Match(
      id: id,
      teamId: teamId,
      date: DateTime(2026, 4, 12, 20, 0),
      location: '성내유수지',
      opponentName: 'FC쏘아',
      ourScore: ourScore,
      opponentScore: opponentScore,
      status: status,
      createdAt: DateTime.now(),
    );

void main() {
  late MockMatchRepo mockMatchRepo;
  late MockPlayerRepo mockPlayerRepo;
  late MatchService service;

  setUp(() {
    mockMatchRepo = MockMatchRepo();
    mockPlayerRepo = MockPlayerRepo();
    service = MatchService(
      matchRepo: mockMatchRepo,
      playerRepo: mockPlayerRepo,
    );
  });

  group('getUpcomingMatches', () {
    test('upcoming 경기만 필터링', () async {
      final matches = [
        _match(id: 'm1', status: MatchStatus.upcoming),
        _match(id: 'm2', status: MatchStatus.completed, ourScore: 2, opponentScore: 1),
        _match(id: 'm3', status: MatchStatus.upcoming),
      ];

      when(mockMatchRepo.getByTeam('team1'))
          .thenAnswer((_) async => matches);

      final result = await service.getUpcomingMatches('team1');

      expect(result.length, 2);
      expect(result.every((m) => m.status == MatchStatus.upcoming), true);
    });
  });

  group('getCompletedMatches', () {
    test('completed 경기만 필터링', () async {
      final matches = [
        _match(id: 'm1', status: MatchStatus.upcoming),
        _match(id: 'm2', status: MatchStatus.completed, ourScore: 2, opponentScore: 1),
        _match(id: 'm3', status: MatchStatus.completed, ourScore: 0, opponentScore: 1),
      ];

      when(mockMatchRepo.getByTeam('team1'))
          .thenAnswer((_) async => matches);

      final result = await service.getCompletedMatches('team1');

      expect(result.length, 2);
      expect(result.every((m) => m.status == MatchStatus.completed), true);
    });
  });

  group('submitResult', () {
    test('결과 입력 시 Repo 호출', () async {
      when(mockMatchRepo.updateResult(
        matchId: 'm1',
        ourScore: 3,
        opponentScore: 1,
      )).thenAnswer((_) async {});

      await service.submitResult(
        matchId: 'm1',
        ourScore: 3,
        opponentScore: 1,
      );

      verify(mockMatchRepo.updateResult(
        matchId: 'm1',
        ourScore: 3,
        opponentScore: 1,
      )).called(1);
    });

    test('음수 스코어 거부', () async {
      expect(
        () => service.submitResult(matchId: 'm1', ourScore: -1, opponentScore: 1),
        throwsArgumentError,
      );
    });
  });

  group('joinMatch', () {
    test('참가 신청 시 PlayerRepo.joinMatch 호출', () async {
      when(mockPlayerRepo.joinMatch(
        matchId: 'm1',
        playerId: 'p1',
        preferredPositions: [Position.cm, Position.am],
        availableQuarters: [1, 2, 3, 4],
      )).thenAnswer((_) async {});

      await service.joinMatch(
        matchId: 'm1',
        playerId: 'p1',
        preferredPositions: [Position.cm, Position.am],
        availableQuarters: [1, 2, 3, 4],
      );

      verify(mockPlayerRepo.joinMatch(
        matchId: 'm1',
        playerId: 'p1',
        preferredPositions: [Position.cm, Position.am],
        availableQuarters: [1, 2, 3, 4],
      )).called(1);
    });

    test('빈 포지션으로 참가 신청 거부', () async {
      expect(
        () => service.joinMatch(
          matchId: 'm1',
          playerId: 'p1',
          preferredPositions: const [],
          availableQuarters: [1, 2],
        ),
        throwsArgumentError,
      );
    });

    test('빈 쿼터로 참가 신청 거부', () async {
      expect(
        () => service.joinMatch(
          matchId: 'm1',
          playerId: 'p1',
          preferredPositions: [Position.cm],
          availableQuarters: const [],
        ),
        throwsArgumentError,
      );
    });
  });

  group('getH2H', () {
    test('상대 전적 집계 (승/무/패)', () async {
      final h2hMatches = [
        _match(id: 'm1', status: MatchStatus.completed, ourScore: 3, opponentScore: 1),
        _match(id: 'm2', status: MatchStatus.completed, ourScore: 1, opponentScore: 1),
        _match(id: 'm3', status: MatchStatus.completed, ourScore: 0, opponentScore: 2),
        _match(id: 'm4', status: MatchStatus.completed, ourScore: 2, opponentScore: 0),
        _match(id: 'm5', status: MatchStatus.completed, ourScore: 4, opponentScore: 2),
      ];

      when(mockMatchRepo.getH2H(teamId: 'team1', opponentName: 'FC쏘아'))
          .thenAnswer((_) async => h2hMatches);

      final summary = await service.getH2HSummary(
        teamId: 'team1',
        opponentName: 'FC쏘아',
      );

      expect(summary.wins, 3);
      expect(summary.draws, 1);
      expect(summary.losses, 1);
      expect(summary.totalMatches, 5);
    });
  });
}
