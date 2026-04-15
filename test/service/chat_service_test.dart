import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:world_soccer/repo/chat_repo.dart';
import 'package:world_soccer/service/chat_service.dart';
import 'package:world_soccer/types/chat.dart';

@GenerateMocks([ChatRepo])
import 'chat_service_test.mocks.dart';

// ── 헬퍼 ──

ChatRoom _room({
  String id = 'room1',
  ChatRoomType type = ChatRoomType.team,
  String? teamId = 'team1',
  String name = '칼로FC',
}) =>
    ChatRoom(id: id, type: type, teamId: teamId, name: name);

ChatMessage _msg({
  String id = 'm1',
  String roomId = 'room1',
  String senderId = 'u1',
  String text = '안녕',
}) =>
    ChatMessage(
      id: id,
      roomId: roomId,
      senderId: senderId,
      senderName: 'A',
      text: text,
      timestamp: DateTime(2026, 4, 14),
      isMe: false,
    );

void main() {
  late MockChatRepo repo;
  late ChatService service;

  setUp(() {
    repo = MockChatRepo();
    service = ChatService(chatRepo: repo);
  });

  // ── sendMessage ──

  group('sendMessage', () {
    test('참여자면 trim 후 전송', () async {
      when(repo.isMember(roomId: 'r1', playerId: 'u1'))
          .thenAnswer((_) async => true);
      when(repo.sendMessage(
        roomId: 'r1',
        senderId: 'u1',
        text: '안녕',
      )).thenAnswer((_) async => _msg(roomId: 'r1', text: '안녕'));

      final result = await service.sendMessage(
        roomId: 'r1',
        senderId: 'u1',
        text: '  안녕  ',
      );

      expect(result.text, '안녕');
      verify(repo.sendMessage(
        roomId: 'r1',
        senderId: 'u1',
        text: '안녕',
      )).called(1);
    });

    test('빈 텍스트는 ArgumentError', () async {
      expect(
        () => service.sendMessage(roomId: 'r1', senderId: 'u1', text: '   '),
        throwsArgumentError,
      );
      verifyNever(repo.sendMessage(
        roomId: anyNamed('roomId'),
        senderId: anyNamed('senderId'),
        text: anyNamed('text'),
      ));
    });

    test('참여자 아니면 NotRoomMemberException', () async {
      when(repo.isMember(roomId: 'r1', playerId: 'intruder'))
          .thenAnswer((_) async => false);

      expect(
        () => service.sendMessage(
          roomId: 'r1',
          senderId: 'intruder',
          text: '안녕',
        ),
        throwsA(isA<NotRoomMemberException>()),
      );
      verifyNever(repo.sendMessage(
        roomId: anyNamed('roomId'),
        senderId: anyNamed('senderId'),
        text: anyNamed('text'),
      ));
    });
  });

  // ── getOrCreateDirectRoom ──

  group('getOrCreateDirectRoom', () {
    test('서비스는 self-check 후 repo 에 위임', () async {
      final created = _room(id: 'dm2', type: ChatRoomType.direct, teamId: null);
      when(repo.getOrCreateDirectRoom(meId: 'u1', otherId: 'u2'))
          .thenAnswer((_) async => created);

      final result = await service.getOrCreateDirectRoom(
        meId: 'u1',
        otherId: 'u2',
      );

      expect(result.id, 'dm2');
      verify(repo.getOrCreateDirectRoom(meId: 'u1', otherId: 'u2')).called(1);
    });

    test('팀원 아니면 repo가 던진 NotTeammateException 전달', () async {
      when(repo.getOrCreateDirectRoom(meId: 'u1', otherId: 'stranger'))
          .thenThrow(const NotTeammateException());

      expect(
        () => service.getOrCreateDirectRoom(meId: 'u1', otherId: 'stranger'),
        throwsA(isA<NotTeammateException>()),
      );
    });

    test('자기 자신과 DM 은 ArgumentError (서버 호출 안 함)', () async {
      expect(
        () => service.getOrCreateDirectRoom(meId: 'u1', otherId: 'u1'),
        throwsArgumentError,
      );
      verifyNever(repo.getOrCreateDirectRoom(
        meId: anyNamed('meId'),
        otherId: anyNamed('otherId'),
      ));
    });
  });

  // ── getMessages ──

  group('getMessages', () {
    test('참여자면 메시지 반환', () async {
      when(repo.isMember(roomId: 'r1', playerId: 'u1'))
          .thenAnswer((_) async => true);
      when(repo.getMessages(
        'r1',
        limit: anyNamed('limit'),
        before: anyNamed('before'),
      )).thenAnswer((_) async => [_msg(id: 'a'), _msg(id: 'b')]);

      final result = await service.getMessages(roomId: 'r1', viewerId: 'u1');

      expect(result.length, 2);
    });

    test('참여자 아니면 NotRoomMemberException', () async {
      when(repo.isMember(roomId: 'r1', playerId: 'x'))
          .thenAnswer((_) async => false);

      expect(
        () => service.getMessages(roomId: 'r1', viewerId: 'x'),
        throwsA(isA<NotRoomMemberException>()),
      );
    });

    test('before 커서가 repo 로 전달됨', () async {
      final cursor = DateTime(2026, 4, 1);
      when(repo.isMember(roomId: 'r1', playerId: 'u1'))
          .thenAnswer((_) async => true);
      when(repo.getMessages(
        'r1',
        limit: anyNamed('limit'),
        before: cursor,
      )).thenAnswer((_) async => []);

      await service.getMessages(
        roomId: 'r1',
        viewerId: 'u1',
        before: cursor,
      );

      verify(repo.getMessages('r1', limit: 50, before: cursor)).called(1);
    });
  });

  // ── markAsRead ──

  group('markAsRead', () {
    test('참여자면 마킹', () async {
      when(repo.isMember(roomId: 'r1', playerId: 'u1'))
          .thenAnswer((_) async => true);
      when(repo.markAsRead(roomId: 'r1', playerId: 'u1'))
          .thenAnswer((_) async {});

      await service.markAsRead(roomId: 'r1', playerId: 'u1');

      verify(repo.markAsRead(roomId: 'r1', playerId: 'u1')).called(1);
    });

    test('참여자 아니면 조용히 무시 (no-op, 권한만 없음)', () async {
      when(repo.isMember(roomId: 'r1', playerId: 'x'))
          .thenAnswer((_) async => false);

      await service.markAsRead(roomId: 'r1', playerId: 'x');

      verifyNever(repo.markAsRead(
        roomId: anyNamed('roomId'),
        playerId: anyNamed('playerId'),
      ));
    });
  });

  // ── getMyRooms ──

  group('getMyRooms', () {
    test('리포지토리 결과 그대로 전달', () async {
      final rooms = [
        _room(id: 'a', type: ChatRoomType.team),
        _room(id: 'b', type: ChatRoomType.direct, teamId: null),
      ];
      when(repo.getMyRooms('u1')).thenAnswer((_) async => rooms);

      final result = await service.getMyRooms('u1');

      expect(result.length, 2);
      expect(result.first.id, 'a');
    });
  });
}
