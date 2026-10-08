import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:musk_mover/main.dart';
import 'package:musk_mover/screens/splash_screen.dart';
import 'package:musk_mover/screens/login_screen.dart';
import 'package:musk_mover/screens/saved_screen.dart';
import 'package:musk_mover/screens/product_detail_screen.dart';
import 'package:musk_mover/models/product_model.dart';
import 'package:musk_mover/providers/auth_provider.dart';
import 'package:musk_mover/providers/product_provider.dart';
import 'package:musk_mover/providers/cart_provider.dart';
import 'package:musk_mover/providers/saved_provider.dart';
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
          ChangeNotifierProvider(create: (_) => SavedProvider()),
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
          ChangeNotifierProvider(create: (_) => SavedProvider()),
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

    // Tap Saved Tab
    await tester.tap(find.byIcon(Icons.favorite_border_rounded));
    await tester.pumpAndSettle();

    // Verify SavedScreen is displayed
    expect(find.byType(SavedScreen), findsOneWidget);
    expect(find.text('Saved Items'), findsOneWidget);
    expect(find.text('No Saved Items Yet'), findsOneWidget);
  });

  testWidgets('Save item on product detail screen adds to SavedScreen', (WidgetTester tester) async {
    final vessel = Vessel(
      id: 'vessel-test-1',
      name: 'Atlantic Supporter',
      type: 'AHTS',
      status: 'AVAILABLE',
      condition: 'Excellent',
      dailyRate: '1,500,000',
      images: [],
    );

    final savedProvider = SavedProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SavedProvider>.value(value: savedProvider),
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: MaterialApp(
          home: ProductDetailScreen(vessel: vessel),
        ),
      ),
    );

    // Initially heart icon is favorite_border_rounded
    expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
    expect(savedProvider.isSaved(vessel.id), isFalse);

    // Tap the bottom heart icon
    await tester.tap(find.byIcon(Icons.favorite_border_rounded));
    await tester.pumpAndSettle();

    // Verify item is saved
    expect(savedProvider.isSaved(vessel.id), isTrue);
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    expect(find.text('Moved "Atlantic Supporter" to Saved Items!'), findsOneWidget);
    expect(find.text('VIEW SAVED'), findsOneWidget);

    // Now test pump of SavedScreen with this provider
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SavedProvider>.value(value: savedProvider),
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: const MaterialApp(
          home: SavedScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify saved item is visible on SavedScreen
    expect(find.text('Atlantic Supporter'), findsOneWidget);
    expect(find.text('My Bookmarks (1)'), findsOneWidget);
    expect(find.text('₦1,500,000 / day'), findsOneWidget);
  });
}
