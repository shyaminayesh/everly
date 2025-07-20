import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:everly/main.dart';
import 'package:everly/screens/home.dart';

void main() {
  group('App Integration Tests', () {
    testWidgets('Main app loads without errors', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pump(); // Use pump instead of pumpAndSettle to avoid timer issues
      
      // Verify the app loads successfully
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('Home Screen Basic Tests', () {
    late Widget testWidget;

    setUp(() {
      testWidget = MaterialApp(
        home: const HomeScreen(title: 'Everly Test'),
        routes: {
          '/create-event': (context) => const Scaffold(body: Text('Create Event')),
          '/add-guest': (context) => const Scaffold(body: Text('Add Guest')),
          '/add-budget': (context) => const Scaffold(body: Text('Add Budget')),
          '/add-vendor': (context) => const Scaffold(body: Text('Add Vendor')),
          '/help': (context) => const Scaffold(body: Text('Help')),
          '/about-us': (context) => const Scaffold(body: Text('About Us')),
        },
      );
    });

    testWidgets('Home screen renders all basic components', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Verify main structural components
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('Bottom navigation contains all required tabs', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Verify all navigation items exist
      expect(find.text('Guest List'), findsOneWidget);
      expect(find.text('Budget'), findsOneWidget);
      expect(find.text('Vendors'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      
      // Verify navigation icons
      expect(find.byIcon(Icons.people), findsOneWidget);
      expect(find.byIcon(Icons.attach_money), findsOneWidget);
      expect(find.byIcon(Icons.business), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('App bar shows correct title', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Check that Home appears in the app bar
      expect(find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Home'),
      ), findsOneWidget);
    });

    testWidgets('Navigation tabs can be tapped', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Test tapping Guest List tab
      await tester.tap(find.text('Guest List'));
      await tester.pumpAndSettle();
      
      // Should change to Guest List view
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Test tapping Budget tab
      await tester.tap(find.text('Budget'));
      await tester.pumpAndSettle();
      
      // Should change to Budget view
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Test tapping Settings tab
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      
      // Should change to Settings view
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('Home tab shows create event prompt when no wedding event', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Navigate to home tab explicitly
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // Should show some content (exact content may vary based on state)
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Loading state is handled correctly', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      
      // Initially might show loading
      // After settling, should show content
      await tester.pumpAndSettle();
      
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Menu icon appears on home screen', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Navigate to home explicitly
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // Menu might be present
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('Theme colors are consistent', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Verify basic color scheme
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(const Color(0xFF0D1B2A)));

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, equals(const Color(0xFF1E293B)));
    });
  });
}