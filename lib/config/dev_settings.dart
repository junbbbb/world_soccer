import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dev_settings.g.dart';

/// 개발용 설정: 더미 데이터 표시 여부.
/// true = 더미 데이터 표시, false = 빈 상태 (실제 DB 데이터만).
@Riverpod(keepAlive: true)
class ShowDummyData extends _$ShowDummyData {
  @override
  bool build() => true;

  void toggle(bool value) => state = value;
}
