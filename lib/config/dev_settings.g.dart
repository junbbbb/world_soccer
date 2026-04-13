// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dev_settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 개발용 설정: 더미 데이터 표시 여부.
/// true = 더미 데이터 표시, false = 빈 상태 (실제 DB 데이터만).

@ProviderFor(ShowDummyData)
final showDummyDataProvider = ShowDummyDataProvider._();

/// 개발용 설정: 더미 데이터 표시 여부.
/// true = 더미 데이터 표시, false = 빈 상태 (실제 DB 데이터만).
final class ShowDummyDataProvider
    extends $NotifierProvider<ShowDummyData, bool> {
  /// 개발용 설정: 더미 데이터 표시 여부.
  /// true = 더미 데이터 표시, false = 빈 상태 (실제 DB 데이터만).
  ShowDummyDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'showDummyDataProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$showDummyDataHash();

  @$internal
  @override
  ShowDummyData create() => ShowDummyData();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$showDummyDataHash() => r'8d31cf82f69ee8af1ad6c9ccab0d0b0ffbc2b8db';

/// 개발용 설정: 더미 데이터 표시 여부.
/// true = 더미 데이터 표시, false = 빈 상태 (실제 DB 데이터만).

abstract class _$ShowDummyData extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
