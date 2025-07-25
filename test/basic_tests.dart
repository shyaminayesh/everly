import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:everly/screens/home.dart';
import 'package:everly/screens/add_budget.dart';
import 'package:everly/models/budget.dart';

/// Basic unit tests that focus on core functionality without complex validation
void main() {
  group('Basic Widget Tests', () {
    testWidgets('HomeScreen renders without crashing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: HomeScreen(title: 'Test')),
      );
      await tester.pumpAndSettle();

      // Verify basic structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('AddBudgetScreen renders without crashing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AddBudgetScreen()));
      await tester.pumpAndSettle();

      // Verify basic structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Form), findsOneWidget);
      expect(find.text('Add Budget Entry'), findsWidgets);
    });

    testWidgets('Bottom navigation has correct items', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: HomeScreen(title: 'Test')),
      );
      await tester.pumpAndSettle();

      // Check navigation items exist
      expect(find.text('Guest List'), findsOneWidget);
      expect(find.text('Budget'), findsOneWidget);
      expect(find.text('Vendors'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('AddBudgetScreen has form fields', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddBudgetScreen()));
      await tester.pumpAndSettle();

      // Check form elements exist
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('Budget categories are available', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddBudgetScreen()));
      await tester.pumpAndSettle();

      // Tap dropdown to see categories
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Check some categories exist (may have duplicates in dropdown)
      expect(find.text(BudgetCategory.venue), findsWidgets);
      expect(find.text(BudgetCategory.catering), findsWidgets);
    });
  });

  group('Budget Model Tests', () {
    test('Budget model creates correctly', () {
      final budget = Budget(
        category: BudgetCategory.venue,
        description: 'Test venue',
        allocatedAmount: 1000.0,
        spentAmount: 500.0,
        weddingEventId: 1,
      );

      expect(budget.category, equals(BudgetCategory.venue));
      expect(budget.description, equals('Test venue'));
      expect(budget.allocatedAmount, equals(1000.0));
      expect(budget.spentAmount, equals(500.0));
    });

    test('Budget calculations work correctly', () {
      final budget = Budget(
        category: BudgetCategory.venue,
        description: 'Test venue',
        allocatedAmount: 1000.0,
        spentAmount: 300.0,
        weddingEventId: 1,
      );

      expect(budget.remainingAmount, equals(700.0));
      expect(budget.progressPercentage, equals(30.0));
      expect(budget.isOverBudget, isFalse);
    });

    test('Budget over budget detection works', () {
      final budget = Budget(
        category: BudgetCategory.venue,
        description: 'Test venue',
        allocatedAmount: 1000.0,
        spentAmount: 1200.0,
        weddingEventId: 1,
      );

      expect(budget.isOverBudget, isTrue);
      expect(budget.remainingAmount, equals(-200.0));
    });

    test('Budget serialization works', () {
      final budget = Budget(
        id: 1,
        category: BudgetCategory.venue,
        description: 'Test venue',
        allocatedAmount: 1000.0,
        spentAmount: 500.0,
        weddingEventId: 1,
      );

      final map = budget.toMap();
      final recreated = Budget.fromMap(map);

      expect(recreated.id, equals(budget.id));
      expect(recreated.category, equals(budget.category));
      expect(recreated.description, equals(budget.description));
      expect(recreated.allocatedAmount, equals(budget.allocatedAmount));
      expect(recreated.spentAmount, equals(budget.spentAmount));
    });
  });

  group('BudgetCategory Tests', () {
    test('All categories are defined', () {
      expect(BudgetCategory.allCategories.length, greaterThan(10));
      expect(
        BudgetCategory.allCategories.contains(BudgetCategory.venue),
        isTrue,
      );
      expect(
        BudgetCategory.allCategories.contains(BudgetCategory.catering),
        isTrue,
      );
      expect(
        BudgetCategory.allCategories.contains(BudgetCategory.photography),
        isTrue,
      );
    });

    test('Categories have proper values', () {
      expect(BudgetCategory.venue, equals('Venue'));
      expect(BudgetCategory.catering, equals('Catering'));
      expect(BudgetCategory.photography, equals('Photography'));
    });
  });
}
