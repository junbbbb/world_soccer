import 'package:flutter/material.dart';

/// 인라인 로딩 스피너. 버튼·헤더 아이콘 교체 용도.
///
/// `SizedBox(width/height:20, child: CircularProgressIndicator(strokeWidth: 2))`
/// 반복 패턴 공용화.
class InlineSpinner extends StatelessWidget {
  const InlineSpinner({
    super.key,
    this.size = 20,
    this.color = Colors.white,
    this.strokeWidth = 2,
  });

  final double size;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}
