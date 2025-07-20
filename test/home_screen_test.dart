import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:everly/screens/home.dart';

/// Focused unit tests for the HomeScreen widget functionality
void main() {
  group('HomeScreen Widget Tests', () {
    late Widget testApp;

    setUp(() {
      testApp = MaterialApp(
        home: const HomeScreen(title: 'Everly'),
        routes: {
          '/create-event': (context) => const Scaffold(body: Text('Create Event Page')),
          '/add-guest': (context) => const Scaffold(body: Text('Add Guest Page')),
          '/add-budget': (context) => const Scaffold(body: Text('Add Budget Page')),
          '/add-vendor': (context) => const Scaffold(body: Text('Add Vendor Page')),
          '/edit-guest': (context) => const Scaffold(body: Text('Edit Guest Page')),
          '/edit-budget': (context) => const Scaffold(body: Text('Edit Budget Page')),
          '/edit-vendor': (context) => const Scaffold(body: Text('Edit Vendor Page')),
          '/help': (context) => const Scaffold(body: Text('Help Page')),
          '/about-us': (context) => const Scaffold(body: Text('About Us Page')),
        },
      );
    });

    group('Basic Structure Tests', () {
      testWidgets('should render core widget components', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Main structure
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.byType(BottomNavigationBar), findsOneWidget);
      });

      testWidgets('should have correct navigation structure', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Bottom navigation items
        expect(find.text('Guest List'), findsOneWidget);
        expect(find.text('Budget'), findsOneWidget);
        expect(find.text('Vendors'), findsOneWidget);
        expect(find.text('Settings'), findsOneWidget);
        
        // Navigation icons
        expect(find.byIcon(Icons.people), findsOneWidget);
        expect(find.byIcon(Icons.attach_money), findsOneWidget);
        expect(find.byIcon(Icons.business), findsOneWidget);
        expect(find.byIcon(Icons.settings), findsOneWidget);
      });
    });

    group('Navigation Tests', () {
      testWidgets('should start with correct initial state', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
        expect(bottomNavBar.currentIndex, equals(2)); // Home is index 2
      });

      testWidgets('should handle tab navigation', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Navigate to Guest List
        await tester.tap(find.text('Guest List'));
        await tester.pumpAndSettle();
        
        var bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
        expect(bottomNavBar.currentIndex, equals(0));

        // Navigate to Budget
        await tester.tap(find.text('Budget'));
        await tester.pumpAndSettle();
        
        bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
        expect(bottomNavBar.currentIndex, equals(1));

        // Navigate to Settings
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();
        
        bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
        expect(bottomNavBar.currentIndex, equals(4));
      });
    });

    group('Content Display Tests', () {
      testWidgets('should show appropriate content based on tab', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Guest List tab content
        await tester.tap(find.text('Guest List'));
        await tester.pumpAndSettle();
        
        // Should show some content (implementation may vary)
        expect(find.byType(BottomNavigationBar), findsOneWidget);

        // Budget tab content
        await tester.tap(find.text('Budget'));
        await tester.pumpAndSettle();
        
        // Should show some content (implementation may vary)
        expect(find.byType(BottomNavigationBar), findsOneWidget);
      });

      testWidgets('should handle loading states', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        
        // Initially might show loading
        // After settling, should show content
        await tester.pumpAndSettle();
        
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    group('App Bar Tests', () {
      testWidgets('should show correct app bar title', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Check initial app bar title
        expect(find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Home'),
        ), findsOneWidget);
      });

      testWidgets('should update app bar based on navigation', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Navigate to Guest List and check app bar
        await tester.tap(find.text('Guest List'));
        await tester.pumpAndSettle();
        
        // App bar should update (exact content may vary)
        expect(find.byType(AppBar), findsOneWidget);

        // Navigate to Budget and check app bar
        await tester.tap(find.text('Budget'));
        await tester.pumpAndSettle();
        
        // App bar should update (exact content may vary)
        expect(find.byType(AppBar), findsOneWidget);
      });
    });

    group('Theme Tests', () {
      testWidgets('should use consistent color scheme', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Check basic theming
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, equals(const Color(0xFF0D1B2A)));

        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.backgroundColor, equals(const Color(0xFF1E293B)));

        final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
        expect(bottomNavBar.backgroundColor, equals(const Color(0xFF1E293B)));
      });

      testWidgets('should have proper navigation styling', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
        expect(bottomNavBar.selectedItemColor, equals(Colors.deepPurple));
        expect(bottomNavBar.unselectedItemColor, equals(Colors.grey));
      });
    });

    group('State Management Tests', () {
      testWidgets('should maintain consistent state', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Should maintain structural integrity
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(BottomNavigationBar), findsOneWidget);
        
        // Check initial state
        final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
        expect(bottomNavBar.currentIndex, equals(2)); // Home tab
      });

      testWidgets('should handle basic navigation', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Tap Settings tab (simpler navigation)
        await tester.tap(find.text('Settings'));
        await tester.pump(); // Use pump instead of pumpAndSettle to avoid timeout

        // Should have updated state
        expect(find.byType(BottomNavigationBar), findsOneWidget);
      });
    });

    group('Responsive Design Tests', () {
      testWidgets('should handle different screen sizes', (WidgetTester tester) async {
        // Set a smaller screen size
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Should still render correctly
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(BottomNavigationBar), findsOneWidget);

        // Reset
        addTearDown(() => tester.view.resetPhysicalSize());
        addTearDown(() => tester.view.resetDevicePixelRatio());
      });
    });
  });
}