import 'package:flutter_test/flutter_test.dart';
import 'package:musk_mover/main.dart';
import 'package:musk_mover/screens/splash_screen.dart';
import 'package:musk_mover/screens/login_screen.dart';

void main() {
  testWidgets('MuskMover app flow test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MuskMoverApp());

    // Verify Splash Screen
    expect(find.byType(SplashScreen), findsOneWidget);

    // Skip Splash Screen
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Verify Login Screen
    expect(find.byType(LoginScreen), findsOneWidget);

    // Tap Login
    await tester.tap(find.text('LOG IN'));
    await tester.pumpAndSettle();

    // Verify HomePage Content
    expect(find.text('MARINE MARKETPLACE'), findsOneWidget);
    
    // Tap Marketplace Tab
    await tester.tap(find.text('Marketplace'));
    await tester.pumpAndSettle();
    
    // Verify Marketplace Title
    expect(find.text('MARKETPLACE'), findsWidgets);
  });
}
