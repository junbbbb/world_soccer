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

String _$currentTeamIdHash() => r'6fc2e8c39898777d1198aa800c200edafa40f21c';

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
