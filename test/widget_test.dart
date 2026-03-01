import 'package:flutter_test/flutter_test.dart';
import 'package:world_soccer/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const WorldSoccerApp());
    await tester.pump();
  });
}
