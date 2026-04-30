import 'package:flutter_test/flutter_test.dart';
import 'package:musk_mover/main.dart';

void main() {
  testWidgets('MuskMover landing page test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MuskMoverApp());

    // Verify that the title is present.
    expect(find.text('MUSKMOVER'), findsOneWidget);
    expect(find.text('GET A QUOTE'), findsOneWidget);
  });
}
