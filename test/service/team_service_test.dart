import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:world_soccer/repo/player_repo.dart';
import 'package:world_soccer/repo/team_repo.dart';
import 'package:world_soccer/service/team_service.dart';
import 'package:world_soccer/types/enums.dart';
import 'package:world_soccer/types/team.dart';

@GenerateMocks([TeamRepo, PlayerRepo])
import 'team_service_test.mocks.dart';

// ── 테스트 헬퍼 ──

TeamMember _member({
  required String playerId,
  TeamRole role = TeamRole.member,
  String teamId = 'team1',
}) =>
    TeamMember(
      teamId: teamId,
      playerId: playerId,
      role: role,
      joinedAt: DateTime(2026, 1, 1),
    );

Team _team({String id = 'team1', String name = 'FC칼로'}) => Team(
      id: id,
      name: name,
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  late MockTeamRepo mockTeamRepo;
  late MockPlayerRepo mockPlayerRepo;
  late TeamService service;

  setUp(() {
    mockTeamRepo = MockTeamRepo();
    mockPlayerRepo = MockPlayerRepo();
    service = TeamService(
      teamRepo: mockTeamRepo,
      playerRepo: mockPlayerRepo,
    );
  });

  group('leaveTeam', () {
    test('일반 멤버는 탈퇴 가능', () async {
      when(mockTeamRepo.getMembers('team1')).thenAnswer((_) async => [
            _member(playerId: 'u1', role: TeamRole.admin),
            _member(playerId: 'u2', role: TeamRole.member),
            _member(playerId: 'u3', role: TeamRole.member),
          ]);
      when(mockTeamRepo.leave(teamId: 'team1', playerId: 'u2'))
          .thenAnswer((_) async {});

      await service.leaveTeam(teamId: 'team1', playerId: 'u2');

      verify(mockTeamRepo.leave(teamId: 'team1', playerId: 'u2')).called(1);
    });

    test('용병도 탈퇴 가능', () async {
      when(mockTeamRepo.getMembers('team1')).thenAnswer((_) async => [
            _member(playerId: 'u1', role: TeamRole.admin),
            _member(playerId: 'merc', role: TeamRole.mercenary),
          ]);
      when(mockTeamRepo.leave(teamId: 'team1', playerId: 'merc'))
          .thenAnswer((_) async {});

      await service.leaveTeam(teamId: 'team1', playerId: 'merc');

      verify(mockTeamRepo.leave(teamId: 'team1', playerId: 'merc')).called(1);
    });

    test('다른 admin 이 있으면 admin 도 탈퇴 가능', () async {
      when(mockTeamRepo.getMembers('team1')).thenAnswer((_) async => [
            _member(playerId: 'u1', role: TeamRole.admin),
            _member(playerId: 'u2', role: TeamRole.admin),
            _member(playerId: 'u3', role: TeamRole.member),
          ]);
      when(mockTeamRepo.leave(teamId: 'team1', playerId: 'u1'))
          .thenAnswer((_) async {});

      await service.leaveTeam(teamId: 'team1', playerId: 'u1');

      verify(mockTeamRepo.leave(teamId: 'team1', playerId: 'u1')).called(1);
    });

    test('마지막 admin + 다른 멤버 있으면 탈퇴 차단', () async {
      when(mockTeamRepo.getMembers('team1')).thenAnswer((_) async => [
            _member(playerId: 'u1', role: TeamRole.admin),
            _member(playerId: 'u2', role: TeamRole.member),
          ]);

      expect(
        () => service.leaveTeam(teamId: 'team1', playerId: 'u1'),
        throwsA(isA<LastAdminException>()),
      );
      verifyNever(mockTeamRepo.leave(
        teamId: anyNamed('teamId'),
        playerId: anyNamed('playerId'),
      ));
    });

    test('혼자 있는 팀의 admin 은 탈퇴 가능 (팀이 빈 상태가 됨)', () async {
      when(mockTeamRepo.getMembers('team1')).thenAnswer((_) async => [
            _member(playerId: 'u1', role: TeamRole.admin),
          ]);
      when(mockTeamRepo.leave(teamId: 'team1', playerId: 'u1'))
          .thenAnswer((_) async {});

      await service.leaveTeam(teamId: 'team1', playerId: 'u1');

      verify(mockTeamRepo.leave(teamId: 'team1', playerId: 'u1')).called(1);
    });

    test('팀 소속이 아니면 예외', () async {
      when(mockTeamRepo.getMembers('team1')).thenAnswer((_) async => [
            _member(playerId: 'u1', role: TeamRole.admin),
          ]);

      expect(
        () => service.leaveTeam(teamId: 'team1', playerId: 'stranger'),
        throwsStateError,
      );
      verifyNever(mockTeamRepo.leave(
        teamId: anyNamed('teamId'),
        playerId: anyNamed('playerId'),
      ));
    });
  });

  group('createTeam', () {
    test('빈 이름은 ArgumentError', () async {
      expect(
        () => service.createTeam(name: '   '),
        throwsArgumentError,
      );
      verifyNever(mockTeamRepo.create(
        name: anyNamed('name'),
        logoUrl: anyNamed('logoUrl'),
        logoColor: anyNamed('logoColor'),
        description: anyNamed('description'),
      ));
    });

    test('공백 trim 후 생성', () async {
      final created = _team(name: 'FC미로');
      when(mockTeamRepo.create(
        name: 'FC미로',
        logoColor: anyNamed('logoColor'),
        description: anyNamed('description'),
      )).thenAnswer((_) async => created);

      final result = await service.createTeam(name: '  FC미로  ');

      expect(result.name, 'FC미로');
      verify(mockTeamRepo.create(
        name: 'FC미로',
        logoColor: null,
        description: null,
      )).called(1);
    });

    test('기존 팀 존재 여부와 무관하게 생성 가능 (추가 팀)', () async {
      final created = _team(id: 'team2', name: 'FC미로');
      when(mockTeamRepo.create(
        name: 'FC미로',
        logoColor: '#22A55B',
        description: anyNamed('description'),
      )).thenAnswer((_) async => created);

      final result = await service.createTeam(
        name: 'FC미로',
        logoColor: '#22A55B',
      );

      expect(result.id, 'team2');
      verify(mockTeamRepo.create(
        name: 'FC미로',
        logoColor: '#22A55B',
        description: null,
      )).called(1);
      verifyNever(mockTeamRepo.getMyTeams(any));
    });

    test('description 을 같이 받아서 저장', () async {
      final created = _team(id: 'team2', name: 'FC미로');
      when(mockTeamRepo.create(
        name: 'FC미로',
        logoColor: anyNamed('logoColor'),
        description: '강동구 토요 모임',
      )).thenAnswer((_) async => created);

      await service.createTeam(
        name: 'FC미로',
        description: '강동구 토요 모임',
      );

      verify(mockTeamRepo.create(
        name: 'FC미로',
        logoColor: null,
        description: '강동구 토요 모임',
      )).called(1);
    });

    test('description 공백만 있으면 null 로 저장', () async {
      final created = _team(id: 'team2', name: 'FC미로');
      when(mockTeamRepo.create(
        name: 'FC미로',
        logoColor: anyNamed('logoColor'),
        description: null,
      )).thenAnswer((_) async => created);

      await service.createTeam(name: 'FC미로', description: '   ');

      verify(mockTeamRepo.create(
        name: 'FC미로',
        logoColor: null,
        description: null,
      )).called(1);
    });
  });

  group('switchTeam', () {
    test('소속된 팀으로 전환 가능', () async {
      when(mockTeamRepo.getMyTeams('u1')).thenAnswer((_) async => [
            _team(id: 'team1'),
            _team(id: 'team2'),
          ]);
      when(mockPlayerRepo.setActiveTeam(
        playerId: 'u1',
        teamId: 'team2',
      )).thenAnswer((_) async {});

      await service.switchTeam(playerId: 'u1', teamId: 'team2');

      verify(mockPlayerRepo.setActiveTeam(
        playerId: 'u1',
        teamId: 'team2',
      )).called(1);
    });

    test('소속되지 않은 팀으로 전환 시도하면 예외', () async {
      when(mockTeamRepo.getMyTeams('u1')).thenAnswer((_) async => [
            _team(id: 'team1'),
          ]);

      expect(
        () => service.switchTeam(playerId: 'u1', teamId: 'team999'),
        throwsA(isA<NotAMemberException>()),
      );
      verifyNever(mockPlayerRepo.setActiveTeam(
        playerId: anyNamed('playerId'),
        teamId: anyNamed('teamId'),
      ));
    });

    test('현재 팀과 동일한 팀으로 전환 요청해도 안전 (no-op 허용)', () async {
      when(mockTeamRepo.getMyTeams('u1')).thenAnswer((_) async => [
            _team(id: 'team1'),
          ]);
      when(mockPlayerRepo.setActiveTeam(
        playerId: 'u1',
        teamId: 'team1',
      )).thenAnswer((_) async {});

      await service.switchTeam(playerId: 'u1', teamId: 'team1');

      verify(mockPlayerRepo.setActiveTeam(
        playerId: 'u1',
        teamId: 'team1',
      )).called(1);
    });
  });
}
