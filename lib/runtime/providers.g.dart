// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(supabaseClient)
final supabaseClientProvider = SupabaseClientProvider._();

final class SupabaseClientProvider
    extends $FunctionalProvider<SupabaseClient, SupabaseClient, SupabaseClient>
    with $Provider<SupabaseClient> {
  SupabaseClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supabaseClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supabaseClientHash();

  @$internal
  @override
  $ProviderElement<SupabaseClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SupabaseClient create(Ref ref) {
    return supabaseClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupabaseClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupabaseClient>(value),
    );
  }
}

String _$supabaseClientHash() => r'2df5a38617329a3bb0a7e149189bea875722d7b8';

@ProviderFor(authRepo)
final authRepoProvider = AuthRepoProvider._();

final class AuthRepoProvider
    extends $FunctionalProvider<AuthRepo, AuthRepo, AuthRepo>
    with $Provider<AuthRepo> {
  AuthRepoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepoHash();

  @$internal
  @override
  $ProviderElement<AuthRepo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepo create(Ref ref) {
    return authRepo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepo>(value),
    );
  }
}

String _$authRepoHash() => r'9f4d80936e0e593c83605f91e260bdb68f026ddc';

@ProviderFor(matchRepo)
final matchRepoProvider = MatchRepoProvider._();

final class MatchRepoProvider
    extends $FunctionalProvider<MatchRepo, MatchRepo, MatchRepo>
    with $Provider<MatchRepo> {
  MatchRepoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'matchRepoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$matchRepoHash();

  @$internal
  @override
  $ProviderElement<MatchRepo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MatchRepo create(Ref ref) {
    return matchRepo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MatchRepo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MatchRepo>(value),
    );
  }
}

String _$matchRepoHash() => r'4136d157a64345288f8dfbeec94cf979e2846276';

@ProviderFor(playerRepo)
final playerRepoProvider = PlayerRepoProvider._();

final class PlayerRepoProvider
    extends $FunctionalProvider<PlayerRepo, PlayerRepo, PlayerRepo>
    with $Provider<PlayerRepo> {
  PlayerRepoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerRepoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerRepoHash();

  @$internal
  @override
  $ProviderElement<PlayerRepo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PlayerRepo create(Ref ref) {
    return playerRepo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlayerRepo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlayerRepo>(value),
    );
  }
}

String _$playerRepoHash() => r'493113fd2066b429a99f48353a4d00fc4c99246e';

@ProviderFor(lineupRepo)
final lineupRepoProvider = LineupRepoProvider._();

final class LineupRepoProvider
    extends $FunctionalProvider<LineupRepo, LineupRepo, LineupRepo>
    with $Provider<LineupRepo> {
  LineupRepoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lineupRepoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lineupRepoHash();

  @$internal
  @override
  $ProviderElement<LineupRepo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LineupRepo create(Ref ref) {
    return lineupRepo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LineupRepo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LineupRepo>(value),
    );
  }
}

String _$lineupRepoHash() => r'f766164ffaee1538ae80bf801280d9d56b3ebc76';

@ProviderFor(teamRepo)
final teamRepoProvider = TeamRepoProvider._();

final class TeamRepoProvider
    extends $FunctionalProvider<TeamRepo, TeamRepo, TeamRepo>
    with $Provider<TeamRepo> {
  TeamRepoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teamRepoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teamRepoHash();

  @$internal
  @override
  $ProviderElement<TeamRepo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TeamRepo create(Ref ref) {
    return teamRepo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TeamRepo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TeamRepo>(value),
    );
  }
}

String _$teamRepoHash() => r'9a5a882020c0a37347464512bed631a895d652aa';

@ProviderFor(statsRepo)
final statsRepoProvider = StatsRepoProvider._();

final class StatsRepoProvider
    extends $FunctionalProvider<StatsRepo, StatsRepo, StatsRepo>
    with $Provider<StatsRepo> {
  StatsRepoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statsRepoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statsRepoHash();

  @$internal
  @override
  $ProviderElement<StatsRepo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StatsRepo create(Ref ref) {
    return statsRepo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StatsRepo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StatsRepo>(value),
    );
  }
}

String _$statsRepoHash() => r'9e41863ab05105a03c701f25d7cf37fab447100d';

@ProviderFor(profileRepo)
final profileRepoProvider = ProfileRepoProvider._();

final class ProfileRepoProvider
    extends $FunctionalProvider<ProfileRepo, ProfileRepo, ProfileRepo>
    with $Provider<ProfileRepo> {
  ProfileRepoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRepoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRepoHash();

  @$internal
  @override
  $ProviderElement<ProfileRepo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProfileRepo create(Ref ref) {
    return profileRepo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileRepo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileRepo>(value),
    );
  }
}

String _$profileRepoHash() => r'00c290c485ac51ded25c4733dfb2e2e5e77b7c39';

@ProviderFor(chatRepo)
final chatRepoProvider = ChatRepoProvider._();

final class ChatRepoProvider
    extends $FunctionalProvider<ChatRepo, ChatRepo, ChatRepo>
    with $Provider<ChatRepo> {
  ChatRepoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatRepoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatRepoHash();

  @$internal
  @override
  $ProviderElement<ChatRepo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ChatRepo create(Ref ref) {
    return chatRepo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatRepo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatRepo>(value),
    );
  }
}

String _$chatRepoHash() => r'83d15083733074f00082dddcbf82309bb226a7e9';

@ProviderFor(matchService)
final matchServiceProvider = MatchServiceProvider._();

final class MatchServiceProvider
    extends $FunctionalProvider<MatchService, MatchService, MatchService>
    with $Provider<MatchService> {
  MatchServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'matchServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$matchServiceHash();

  @$internal
  @override
  $ProviderElement<MatchService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MatchService create(Ref ref) {
    return matchService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MatchService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MatchService>(value),
    );
  }
}

String _$matchServiceHash() => r'a9693fa34bcd894127c1a01a4a54cea0cca25401';

@ProviderFor(lineupService)
final lineupServiceProvider = LineupServiceProvider._();

final class LineupServiceProvider
    extends $FunctionalProvider<LineupService, LineupService, LineupService>
    with $Provider<LineupService> {
  LineupServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lineupServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lineupServiceHash();

  @$internal
  @override
  $ProviderElement<LineupService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LineupService create(Ref ref) {
    return lineupService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LineupService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LineupService>(value),
    );
  }
}

String _$lineupServiceHash() => r'd64bb8e32493ee15ade4c0be6e1571725b04670d';

@ProviderFor(teamService)
final teamServiceProvider = TeamServiceProvider._();

final class TeamServiceProvider
    extends $FunctionalProvider<TeamService, TeamService, TeamService>
    with $Provider<TeamService> {
  TeamServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teamServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teamServiceHash();

  @$internal
  @override
  $ProviderElement<TeamService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TeamService create(Ref ref) {
    return teamService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TeamService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TeamService>(value),
    );
  }
}

String _$teamServiceHash() => r'e85d3611867f6fef0689b68d23d421516b7f0de4';

@ProviderFor(chatService)
final chatServiceProvider = ChatServiceProvider._();

final class ChatServiceProvider
    extends $FunctionalProvider<ChatService, ChatService, ChatService>
    with $Provider<ChatService> {
  ChatServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatServiceHash();

  @$internal
  @override
  $ProviderElement<ChatService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ChatService create(Ref ref) {
    return chatService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatService>(value),
    );
  }
}

String _$chatServiceHash() => r'dacc28081dac9a372dad38a6ecfb81f53a3a499c';

/// 내가 참여한 채팅방 목록.

@ProviderFor(myChatRooms)
final myChatRoomsProvider = MyChatRoomsProvider._();

/// 내가 참여한 채팅방 목록.

final class MyChatRoomsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ChatRoom>>,
          List<ChatRoom>,
          FutureOr<List<ChatRoom>>
        >
    with $FutureModifier<List<ChatRoom>>, $FutureProvider<List<ChatRoom>> {
  /// 내가 참여한 채팅방 목록.
  MyChatRoomsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myChatRoomsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myChatRoomsHash();

  @$internal
  @override
  $FutureProviderElement<List<ChatRoom>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ChatRoom>> create(Ref ref) {
    return myChatRooms(ref);
  }
}

String _$myChatRoomsHash() => r'52c6e01b0457e50827528512811d493ba898c72f';

/// 특정 방의 메시지.

@ProviderFor(roomMessages)
final roomMessagesProvider = RoomMessagesFamily._();

/// 특정 방의 메시지.

final class RoomMessagesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ChatMessage>>,
          List<ChatMessage>,
          FutureOr<List<ChatMessage>>
        >
    with
        $FutureModifier<List<ChatMessage>>,
        $FutureProvider<List<ChatMessage>> {
  /// 특정 방의 메시지.
  RoomMessagesProvider._({
    required RoomMessagesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'roomMessagesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$roomMessagesHash();

  @override
  String toString() {
    return r'roomMessagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ChatMessage>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ChatMessage>> create(Ref ref) {
    final argument = this.argument as String;
    return roomMessages(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RoomMessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$roomMessagesHash() => r'e26aa3d6ac2e7c76e4cae55242ac97c5a2f5e067';

/// 특정 방의 메시지.

final class RoomMessagesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ChatMessage>>, String> {
  RoomMessagesFamily._()
    : super(
        retry: null,
        name: r'roomMessagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 특정 방의 메시지.

  RoomMessagesProvider call(String roomId) =>
      RoomMessagesProvider._(argument: roomId, from: this);

  @override
  String toString() => r'roomMessagesProvider';
}

/// 특정 방의 실시간 메시지 스트림.

@ProviderFor(roomMessageStream)
final roomMessageStreamProvider = RoomMessageStreamFamily._();

/// 특정 방의 실시간 메시지 스트림.

final class RoomMessageStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<ChatMessage>,
          ChatMessage,
          Stream<ChatMessage>
        >
    with $FutureModifier<ChatMessage>, $StreamProvider<ChatMessage> {
  /// 특정 방의 실시간 메시지 스트림.
  RoomMessageStreamProvider._({
    required RoomMessageStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'roomMessageStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$roomMessageStreamHash();

  @override
  String toString() {
    return r'roomMessageStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<ChatMessage> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ChatMessage> create(Ref ref) {
    final argument = this.argument as String;
    return roomMessageStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RoomMessageStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$roomMessageStreamHash() => r'7589bd4d812ddd9ac5debac1386a138088e2b0bf';

/// 특정 방의 실시간 메시지 스트림.

final class RoomMessageStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<ChatMessage>, String> {
  RoomMessageStreamFamily._()
    : super(
        retry: null,
        name: r'roomMessageStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 특정 방의 실시간 메시지 스트림.

  RoomMessageStreamProvider call(String roomId) =>
      RoomMessageStreamProvider._(argument: roomId, from: this);

  @override
  String toString() => r'roomMessageStreamProvider';
}

/// 특정 팀의 멤버 목록.

@ProviderFor(teamMembersByTeam)
final teamMembersByTeamProvider = TeamMembersByTeamFamily._();

/// 특정 팀의 멤버 목록.

final class TeamMembersByTeamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TeamMember>>,
          List<TeamMember>,
          FutureOr<List<TeamMember>>
        >
    with $FutureModifier<List<TeamMember>>, $FutureProvider<List<TeamMember>> {
  /// 특정 팀의 멤버 목록.
  TeamMembersByTeamProvider._({
    required TeamMembersByTeamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'teamMembersByTeamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$teamMembersByTeamHash();

  @override
  String toString() {
    return r'teamMembersByTeamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<TeamMember>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TeamMember>> create(Ref ref) {
    final argument = this.argument as String;
    return teamMembersByTeam(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TeamMembersByTeamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$teamMembersByTeamHash() => r'c06bfd10173b5f68dcbe3dc557b54ed8535035e2';

/// 특정 팀의 멤버 목록.

final class TeamMembersByTeamFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<TeamMember>>, String> {
  TeamMembersByTeamFamily._()
    : super(
        retry: null,
        name: r'teamMembersByTeamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 특정 팀의 멤버 목록.

  TeamMembersByTeamProvider call(String teamId) =>
      TeamMembersByTeamProvider._(argument: teamId, from: this);

  @override
  String toString() => r'teamMembersByTeamProvider';
}

/// 특정 팀의 전적/스탯 요약.

@ProviderFor(teamStatsByTeam)
final teamStatsByTeamProvider = TeamStatsByTeamFamily._();

/// 특정 팀의 전적/스탯 요약.

final class TeamStatsByTeamProvider
    extends
        $FunctionalProvider<
          AsyncValue<TeamStats>,
          TeamStats,
          FutureOr<TeamStats>
        >
    with $FutureModifier<TeamStats>, $FutureProvider<TeamStats> {
  /// 특정 팀의 전적/스탯 요약.
  TeamStatsByTeamProvider._({
    required TeamStatsByTeamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'teamStatsByTeamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$teamStatsByTeamHash();

  @override
  String toString() {
    return r'teamStatsByTeamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<TeamStats> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<TeamStats> create(Ref ref) {
    final argument = this.argument as String;
    return teamStatsByTeam(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TeamStatsByTeamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$teamStatsByTeamHash() => r'f94b8bdd4e03a79cf0dcb4f111d6b11a2f382d2c';

/// 특정 팀의 전적/스탯 요약.

final class TeamStatsByTeamFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<TeamStats>, String> {
  TeamStatsByTeamFamily._()
    : super(
        retry: null,
        name: r'teamStatsByTeamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 특정 팀의 전적/스탯 요약.

  TeamStatsByTeamProvider call(String teamId) =>
      TeamStatsByTeamProvider._(argument: teamId, from: this);

  @override
  String toString() => r'teamStatsByTeamProvider';
}

/// 특정 팀의 득점 랭킹.

@ProviderFor(teamGoalRanking)
final teamGoalRankingProvider = TeamGoalRankingFamily._();

/// 특정 팀의 득점 랭킹.

final class TeamGoalRankingProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PlayerRank>>,
          List<PlayerRank>,
          FutureOr<List<PlayerRank>>
        >
    with $FutureModifier<List<PlayerRank>>, $FutureProvider<List<PlayerRank>> {
  /// 특정 팀의 득점 랭킹.
  TeamGoalRankingProvider._({
    required TeamGoalRankingFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'teamGoalRankingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$teamGoalRankingHash();

  @override
  String toString() {
    return r'teamGoalRankingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PlayerRank>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PlayerRank>> create(Ref ref) {
    final argument = this.argument as String;
    return teamGoalRanking(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TeamGoalRankingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$teamGoalRankingHash() => r'ac1d470d1416b6558e46fd3772926b4dc7f57085';

/// 특정 팀의 득점 랭킹.

final class TeamGoalRankingFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PlayerRank>>, String> {
  TeamGoalRankingFamily._()
    : super(
        retry: null,
        name: r'teamGoalRankingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 특정 팀의 득점 랭킹.

  TeamGoalRankingProvider call(String teamId) =>
      TeamGoalRankingProvider._(argument: teamId, from: this);

  @override
  String toString() => r'teamGoalRankingProvider';
}

/// 특정 팀의 어시스트 랭킹.

@ProviderFor(teamAssistRanking)
final teamAssistRankingProvider = TeamAssistRankingFamily._();

/// 특정 팀의 어시스트 랭킹.

final class TeamAssistRankingProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PlayerRank>>,
          List<PlayerRank>,
          FutureOr<List<PlayerRank>>
        >
    with $FutureModifier<List<PlayerRank>>, $FutureProvider<List<PlayerRank>> {
  /// 특정 팀의 어시스트 랭킹.
  TeamAssistRankingProvider._({
    required TeamAssistRankingFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'teamAssistRankingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$teamAssistRankingHash();

  @override
  String toString() {
    return r'teamAssistRankingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PlayerRank>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PlayerRank>> create(Ref ref) {
    final argument = this.argument as String;
    return teamAssistRanking(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TeamAssistRankingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$teamAssistRankingHash() => r'9bad4defe402cdae4f9d0c4a17d32b73f684305b';

/// 특정 팀의 어시스트 랭킹.

final class TeamAssistRankingFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PlayerRank>>, String> {
  TeamAssistRankingFamily._()
    : super(
        retry: null,
        name: r'teamAssistRankingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 특정 팀의 어시스트 랭킹.

  TeamAssistRankingProvider call(String teamId) =>
      TeamAssistRankingProvider._(argument: teamId, from: this);

  @override
  String toString() => r'teamAssistRankingProvider';
}

/// 현재 유저의 팀 목록.

@ProviderFor(myTeams)
final myTeamsProvider = MyTeamsProvider._();

/// 현재 유저의 팀 목록.

final class MyTeamsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Team>>,
          List<Team>,
          FutureOr<List<Team>>
        >
    with $FutureModifier<List<Team>>, $FutureProvider<List<Team>> {
  /// 현재 유저의 팀 목록.
  MyTeamsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myTeamsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myTeamsHash();

  @$internal
  @override
  $FutureProviderElement<List<Team>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Team>> create(Ref ref) {
    return myTeams(ref);
  }
}

String _$myTeamsHash() => r'5efc42250e6b12e766f85688536774c7ea8f3ce7';

/// 현재 선택된 팀.
///
/// `players.active_team_id` 를 우선 조회. 없거나 해당 팀이 더 이상 내 팀 목록에
/// 없으면 가입한 첫 팀으로 폴백.

@ProviderFor(currentTeam)
final currentTeamProvider = CurrentTeamProvider._();

/// 현재 선택된 팀.
///
/// `players.active_team_id` 를 우선 조회. 없거나 해당 팀이 더 이상 내 팀 목록에
/// 없으면 가입한 첫 팀으로 폴백.

final class CurrentTeamProvider
    extends $FunctionalProvider<AsyncValue<Team?>, Team?, FutureOr<Team?>>
    with $FutureModifier<Team?>, $FutureProvider<Team?> {
  /// 현재 선택된 팀.
  ///
  /// `players.active_team_id` 를 우선 조회. 없거나 해당 팀이 더 이상 내 팀 목록에
  /// 없으면 가입한 첫 팀으로 폴백.
  CurrentTeamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentTeamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentTeamHash();

  @$internal
  @override
  $FutureProviderElement<Team?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Team?> create(Ref ref) {
    return currentTeam(ref);
  }
}

String _$currentTeamHash() => r'203f1c0086d06aa1e2a56d19e780f5a9bfea11b8';

/// 현재 유저의 첫 번째 팀 ID.

@ProviderFor(currentTeamId)
final currentTeamIdProvider = CurrentTeamIdProvider._();

/// 현재 유저의 첫 번째 팀 ID.

final class CurrentTeamIdProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// 현재 유저의 첫 번째 팀 ID.
  CurrentTeamIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentTeamIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentTeamIdHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return currentTeamId(ref);
  }
}

String _$currentTeamIdHash() => r'a5f329414e8ebf1d1da4ecd22b8158bc0202635e';

/// 팀의 전체 경기 목록 (최신순).

@ProviderFor(teamMatches)
final teamMatchesProvider = TeamMatchesProvider._();

/// 팀의 전체 경기 목록 (최신순).

final class TeamMatchesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<types.Match>>,
          List<types.Match>,
          FutureOr<List<types.Match>>
        >
    with
        $FutureModifier<List<types.Match>>,
        $FutureProvider<List<types.Match>> {
  /// 팀의 전체 경기 목록 (최신순).
  TeamMatchesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teamMatchesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teamMatchesHash();

  @$internal
  @override
  $FutureProviderElement<List<types.Match>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<types.Match>> create(Ref ref) {
    return teamMatches(ref);
  }
}

String _$teamMatchesHash() => r'22ab1eebd5ffe44738a4ec92148c3af8103f89a4';
