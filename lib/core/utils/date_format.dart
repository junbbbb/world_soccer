/// 한국어 요일 짧은 형태. `weekday - 1` 인덱스.
const kWeekdaysShort = ['월', '화', '수', '목', '금', '토', '일'];

/// `3/14 토` 형태. local timezone 기준.
String formatMdWeekday(DateTime d) {
  final l = d.toLocal();
  return '${l.month}/${l.day} ${kWeekdaysShort[l.weekday - 1]}';
}
