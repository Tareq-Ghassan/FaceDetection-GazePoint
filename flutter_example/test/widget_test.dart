import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_example/main.dart';

void main() {
  testWidgets('App builds', (tester) async {
    await tester.pumpWidget(const GazePointExampleApp());
    expect(find.text('GazePoint Flutter'), findsOneWidget);
  });
}
