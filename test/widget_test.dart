import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:musk_mover/main.dart';
import 'package:musk_mover/screens/splash_screen.dart';
import 'package:musk_mover/screens/login_screen.dart';
import 'package:musk_mover/screens/signup_screen.dart';
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

  testWidgets('LoginScreen validates inputs and handles remember me checkbox', (WidgetTester tester) async {
    final authProvider = AuthProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify UI Elements
    expect(find.text('Welcome to MuskMover'), findsOneWidget);
    expect(find.text('LOG IN'), findsOneWidget);
    expect(find.text('Remember me for 30 days'), findsOneWidget);

    // Scroll and tap Log In with empty fields to trigger validation
    final loginButtonFinder = find.text('LOG IN');
    await tester.ensureVisible(loginButtonFinder);
    await tester.tap(loginButtonFinder);
    await tester.pumpAndSettle();

    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);

    // Fill in valid email and password
    await tester.enterText(find.byType(TextFormField).first, 'ops@musklogistics.ng');
    await tester.enterText(find.byType(TextFormField).last, 'SecretPass123');
    await tester.pumpAndSettle();

    // Toggle remember me checkbox
    final checkboxFinder = find.byType(Checkbox);
    expect(checkboxFinder, findsOneWidget);
    await tester.ensureVisible(checkboxFinder);
    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();

    // Tap again to enable
    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();
  });

  testWidgets('SignupScreen validates required company and contact fields', (WidgetTester tester) async {
    final authProvider = AuthProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ],
        child: const MaterialApp(
          home: SignupScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Check title
    expect(find.text('Create Company Account'), findsOneWidget);
    final createAccountFinder = find.text('CREATE ACCOUNT');
    expect(createAccountFinder, findsOneWidget);

    // Scroll to submit button and tap while empty to verify strict validation
    await tester.ensureVisible(createAccountFinder);
    await tester.tap(createAccountFinder);
    await tester.pumpAndSettle();

    expect(find.text('This field is required'), findsWidgets);
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
  });

  test('AuthProvider manages 30-day saved credentials correctly', () async {
    SharedPreferences.setMockInitialValues({});
    final authProvider = AuthProvider();

    // Initially no credentials
    var creds = await authProvider.getSavedCredentials();
    expect(creds['email'], isNull);
    expect(creds['rememberMe'], 'false');

    // Simulate saving credentials
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me_enabled', true);
    await prefs.setInt('session_expiry_timestamp', DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch);
    await prefs.setString('saved_login_email', 'captain@muskmover.ng');
    await prefs.setString('saved_login_password', 'VesselPass2026');

    creds = await authProvider.getSavedCredentials();
    expect(creds['email'], 'captain@muskmover.ng');
    expect(creds['password'], 'VesselPass2026');
    expect(creds['rememberMe'], 'true');

    // Test clear saved credentials
    await authProvider.clearSavedCredentials();
    creds = await authProvider.getSavedCredentials();
    expect(creds['email'], isNull);
    expect(creds['password'], isNull);
  });
}
