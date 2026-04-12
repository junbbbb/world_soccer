// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lineup_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 라인업 빌더의 상태/액션을 모두 보유하는 컨트롤러.
///
/// View(Widget)는 이 컨트롤러의 메서드만 호출하면 되며,
/// 모든 상태 갱신은 immutable copyWith로 처리한다.
///
/// keepAlive=true: 빌더에서 편집한 라인업이 공유 화면/경기 상세에서도
/// 유지되도록 전역에 살아있게 함. 실제 데이터 연동 시 재검토.

@ProviderFor(LineupController)
final lineupControllerProvider = LineupControllerProvider._();

/// 라인업 빌더의 상태/액션을 모두 보유하는 컨트롤러.
///
/// View(Widget)는 이 컨트롤러의 메서드만 호출하면 되며,
/// 모든 상태 갱신은 immutable copyWith로 처리한다.
///
/// keepAlive=true: 빌더에서 편집한 라인업이 공유 화면/경기 상세에서도
/// 유지되도록 전역에 살아있게 함. 실제 데이터 연동 시 재검토.
final class LineupControllerProvider
    extends $NotifierProvider<LineupController, LineupState> {
  /// 라인업 빌더의 상태/액션을 모두 보유하는 컨트롤러.
  ///
  /// View(Widget)는 이 컨트롤러의 메서드만 호출하면 되며,
  /// 모든 상태 갱신은 immutable copyWith로 처리한다.
  ///
  /// keepAlive=true: 빌더에서 편집한 라인업이 공유 화면/경기 상세에서도
  /// 유지되도록 전역에 살아있게 함. 실제 데이터 연동 시 재검토.
  LineupControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lineupControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lineupControllerHash();

  @$internal
  @override
  LineupController create() => LineupController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LineupState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LineupState>(value),
    );
  }
}

String _$lineupControllerHash() => r'f38ec319c539af5bc95fd2b5083d9d2e228e1256';

/// 라인업 빌더의 상태/액션을 모두 보유하는 컨트롤러.
///
/// View(Widget)는 이 컨트롤러의 메서드만 호출하면 되며,
/// 모든 상태 갱신은 immutable copyWith로 처리한다.
///
/// keepAlive=true: 빌더에서 편집한 라인업이 공유 화면/경기 상세에서도
/// 유지되도록 전역에 살아있게 함. 실제 데이터 연동 시 재검토.

abstract class _$LineupController extends $Notifier<LineupState> {
  LineupState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LineupState, LineupState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LineupState, LineupState>,
              LineupState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
