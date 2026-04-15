import 'package:supabase_flutter/supabase_flutter.dart';

import '../types/chat.dart';
import '../types/enums.dart';
import 'chat_repo.dart';

/// ChatRepo의 Supabase 구현체.
class SupabaseChatRepo implements ChatRepo {
  final SupabaseClient _client;

  /// sender_id → {name, avatar_url} 캐시.
  /// subscribeMessages 가 새 메시지마다 players 를 재조회하지 않도록 한다.
  /// 방별로 독립시킬 필요까진 없어서 repo 단일 캐시로 유지.
  final Map<String, Map<String, String?>> _senderCache = {};

  SupabaseChatRepo(this._client);

  String? get _currentUserId => _client.auth.currentUser?.id;

  @override
  Future<List<ChatRoom>> getMyRooms(String playerId) async {
    final data = await _client.rpc('get_my_chat_rooms');
    final rows = (data as List).cast<Map<String, dynamic>>();

    return rows.map((row) {
      final type = (row['room_type'] as String) == 'direct'
          ? ChatRoomType.direct
          : ChatRoomType.team;
      final displayName = type == ChatRoomType.direct
          ? (row['peer_name'] as String? ?? '개인 메시지')
          : (row['team_name'] as String? ?? '팀 채팅');
      final logoUrl = type == ChatRoomType.direct
          ? (row['peer_avatar_url'] as String?)
          : (row['team_logo_url'] as String?);
      final logoColor = type == ChatRoomType.team
          ? (row['team_logo_color'] as String?)
          : null;
      final lastAtRaw = row['last_message_at'] as String?;

      return ChatRoom(
        id: row['room_id'] as String,
        type: type,
        teamId: row['team_id'] as String?,
        name: displayName,
        logoUrl: logoUrl,
        logoColor: logoColor,
        lastMessage: (row['last_message'] as String?) ?? '',
        lastMessageSender: (row['last_message_sender'] as String?) ?? '',
        lastMessageTime: lastAtRaw != null ? DateTime.parse(lastAtRaw) : null,
        memberCount: (row['member_count'] as int?) ?? 0,
        unreadCount: (row['unread_count'] as int?) ?? 0,
      );
    }).toList();
  }

  @override
  Future<ChatRoom> getRoom(String roomId) async {
    final row = await _client
        .from('chat_rooms')
        .select('''
          id, type, team_id, name,
          chat_room_members(player_id, players(name, avatar_url))
        ''')
        .eq('id', roomId)
        .single();

    final members = (row['chat_room_members'] as List).cast<Map<String, dynamic>>();
    final type = (row['type'] as String) == 'direct'
        ? ChatRoomType.direct
        : ChatRoomType.team;

    var name = (row['name'] as String?) ?? '채팅';
    if (type == ChatRoomType.direct) {
      final me = _currentUserId;
      final peer = members.where((m) => m['player_id'] != me).firstOrNull;
      final peerName =
          ((peer?['players'] as Map?)?['name'] as String?) ?? '개인 메시지';
      name = peerName;
    }

    return ChatRoom(
      id: row['id'] as String,
      type: type,
      teamId: row['team_id'] as String?,
      name: name,
      memberCount: members.length,
    );
  }

  @override
  Future<bool> isMember({
    required String roomId,
    required String playerId,
  }) async {
    final row = await _client
        .from('chat_room_members')
        .select('player_id')
        .eq('room_id', roomId)
        .eq('player_id', playerId)
        .maybeSingle();
    return row != null;
  }

  @override
  Future<ChatRoom> getOrCreateDirectRoom({
    required String meId,
    required String otherId,
  }) async {
    final me = _currentUserId;
    if (me == null) throw StateError('로그인이 필요합니다');
    final other = (me == meId) ? otherId : meId;
    try {
      final response = await _client.rpc(
        'get_or_create_direct_room',
        params: {'p_other': other},
      ) as Map<String, dynamic>;
      final roomId = response['room_id'] as String;
      return getRoom(roomId);
    } on PostgrestException catch (e) {
      if (e.message.contains('Not a teammate')) {
        throw const NotTeammateException();
      }
      rethrow;
    }
  }

  @override
  Future<List<ChatMessage>> getMessages(
    String roomId, {
    int limit = 50,
    DateTime? before,
  }) async {
    var query = _client
        .from('chat_messages')
        .select('id, room_id, sender_id, content, type, created_at, '
            'players!chat_messages_sender_id_fkey(name, avatar_url)')
        .eq('room_id', roomId);

    if (before != null) {
      query = query.lt('created_at', before.toIso8601String());
    }

    final rows = await query
        .order('created_at', ascending: false) // 최신부터
        .limit(limit);

    final me = _currentUserId;
    // 캐시에 sender 정보 적재
    for (final row in rows) {
      final p = row['players'] as Map<String, dynamic>?;
      if (p != null) {
        _senderCache[row['sender_id'] as String] = {
          'name': p['name'] as String?,
          'avatar_url': p['avatar_url'] as String?,
        };
      }
    }
    // 시간 오름차순(화면 표시용)으로 뒤집어 반환
    return rows.reversed.map((row) => _messageFromRow(row, me)).toList();
  }

  @override
  Future<ChatMessage> sendMessage({
    required String roomId,
    required String senderId,
    required String text,
  }) async {
    final row = await _client
        .from('chat_messages')
        .insert({
          'room_id': roomId,
          'sender_id': senderId,
          'content': text,
        })
        .select('id, room_id, sender_id, content, type, created_at, '
            'players!chat_messages_sender_id_fkey(name, avatar_url)')
        .single();
    final p = row['players'] as Map<String, dynamic>?;
    if (p != null) {
      _senderCache[senderId] = {
        'name': p['name'] as String?,
        'avatar_url': p['avatar_url'] as String?,
      };
    }
    return _messageFromRow(row, _currentUserId);
  }

  @override
  Future<void> markAsRead({
    required String roomId,
    required String playerId,
  }) async {
    await _client
        .from('chat_room_members')
        .update({'last_read_at': DateTime.now().toIso8601String()})
        .eq('room_id', roomId)
        .eq('player_id', playerId);
  }

  @override
  Stream<ChatMessage> subscribeMessages(String roomId) {
    final me = _currentUserId;
    // 최신 1개만 관찰. 과거 메시지는 getMessages 가 초기 로드,
    // 신규 메시지는 insert 마다 최신 row 가 1개 들어옴.
    // dedup 은 화면에서 _messageIds 로 처리.
    return _client
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at', ascending: false)
        .limit(1)
        .asyncExpand<ChatMessage>((rows) async* {
          if (rows.isEmpty) return;
          final latest = rows.first;
          final senderId = latest['sender_id'] as String;
          var cached = _senderCache[senderId];
          if (cached == null) {
            final sender = await _client
                .from('players')
                .select('name, avatar_url')
                .eq('id', senderId)
                .maybeSingle();
            cached = {
              'name': sender?['name'] as String?,
              'avatar_url': sender?['avatar_url'] as String?,
            };
            _senderCache[senderId] = cached;
          }
          yield _messageFromRow({
            ...latest,
            'players': cached,
          }, me);
        });
  }

  ChatMessage _messageFromRow(Map<String, dynamic> row, String? meId) {
    final player = row['players'] as Map<String, dynamic>?;
    final senderId = row['sender_id'] as String;
    return ChatMessage(
      id: row['id'] as String,
      roomId: row['room_id'] as String,
      senderId: senderId,
      senderName: (player?['name'] as String?) ?? '알 수 없음',
      avatarPath: player?['avatar_url'] as String?,
      text: row['content'] as String,
      timestamp: DateTime.parse(row['created_at'] as String),
      isMe: meId != null && meId == senderId,
      type: (row['type'] as String?) == 'event'
          ? MessageType.event
          : MessageType.text,
    );
  }
}
