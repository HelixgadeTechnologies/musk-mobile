import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:musk_mover/main.dart';
import 'package:musk_mover/screens/splash_screen.dart';
import 'package:musk_mover/screens/login_screen.dart';
import 'package:musk_mover/providers/auth_provider.dart';
import 'package:musk_mover/providers/product_provider.dart';
import 'package:musk_mover/providers/cart_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('MuskMover app flow test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ProductProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: const MuskMoverApp(),
      ),
    );

    // Verify Splash Screen
    expect(find.byType(SplashScreen), findsOneWidget);

    // Allow splash timer to complete and transition to Login
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Login Screen
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('LOG IN'), findsOneWidget);

    // Pump MainScreen directly to verify home and marketplace UI without network auth
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ProductProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: const MaterialApp(
          home: MainScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify HomePage Content
    expect(find.text('MUSKMOVER'), findsOneWidget);
    
    // Tap Categories Tab
    await tester.tap(find.byIcon(Icons.grid_view_rounded));
    await tester.pumpAndSettle();
    
    // Verify Categories/Marketplace Title
    expect(find.text('CATEGORIES'), findsWidgets);
  });
}
