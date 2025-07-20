import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:everly/screens/edit_budget.dart';
import 'package:everly/models/budget.dart';

/// Unit tests for the EditBudgetScreen widget
void main() {
  group('EditBudgetScreen Widget Tests', () {
    late Widget testApp;
    late Budget testBudget;

    setUp(() {
      testBudget = Budget(
        id: 1,
        category: BudgetCategory.venue,
        description: 'Test venue',
        allocatedAmount: 5000.0,
        spentAmount: 2500.0,
        weddingEventId: 1,
      );

      testApp = MaterialApp(
        home: EditBudgetScreen(budget: testBudget),
      );
    });

    group('Widget Structure Tests', () {
      testWidgets('should render basic widget structure', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Main structure
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.byType(Form), findsOneWidget);
        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });

      testWidgets('should have correct app bar', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // AppBar elements - check in app bar specifically
        expect(find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Edit Budget Entry'),
        ), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });

      testWidgets('should have all required form fields', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Form fields
        expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(3)); // Description, Allocated, Spent
        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      testWidgets('should display edit-specific elements', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        expect(find.text('Edit budget entry'), findsOneWidget);
        expect(find.text('Update Budget Entry'), findsOneWidget);
      });
    });

    group('Form Pre-population Tests', () {
      testWidgets('should pre-populate text fields with budget data', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Check text field pre-population
        final descriptionField = tester.widget<TextFormField>(find.byType(TextFormField).first);
        expect(descriptionField.controller!.text, equals(testBudget.description));

        final allocatedField = tester.widget<TextFormField>(find.byType(TextFormField).at(1));
        expect(allocatedField.controller!.text, equals(testBudget.allocatedAmount.toString()));

        final spentField = tester.widget<TextFormField>(find.byType(TextFormField).at(2));
        expect(spentField.controller!.text, equals(testBudget.spentAmount.toString()));
      });

      testWidgets('should have dropdown present', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Check that dropdown is present
        expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      });

      testWidgets('should handle zero spent amount correctly', (WidgetTester tester) async {
        final zeroBudget = Budget(
          id: 1,
          category: BudgetCategory.venue,
          description: 'Test venue',
          allocatedAmount: 5000.0,
          spentAmount: 0.0,
          weddingEventId: 1,
        );

        final zeroApp = MaterialApp(
          home: EditBudgetScreen(budget: zeroBudget),
        );

        await tester.pumpWidget(zeroApp);
        await tester.pumpAndSettle();

        final spentField = tester.widget<TextFormField>(find.byType(TextFormField).at(2));
        expect(spentField.controller!.text, equals('0.0'));
      });
    });

    group('Form Field Interaction Tests', () {
      testWidgets('should allow updating description', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        final descriptionField = find.byType(TextFormField).first;
        
        // Update description
        await tester.enterText(descriptionField, 'Updated venue description');
        expect(tester.widget<TextFormField>(descriptionField).controller!.text, equals('Updated venue description'));
      });

      testWidgets('should allow updating allocated amount', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        final allocatedField = find.byType(TextFormField).at(1);
        
        // Update allocated amount
        await tester.enterText(allocatedField, '7500.00');
        expect(tester.widget<TextFormField>(allocatedField).controller!.text, equals('7500.00'));
      });

      testWidgets('should allow updating spent amount', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        final spentField = find.byType(TextFormField).at(2);
        
        // Update spent amount
        await tester.enterText(spentField, '3500.00');
        expect(tester.widget<TextFormField>(spentField).controller!.text, equals('3500.00'));
      });

      testWidgets('should handle category dropdown interaction', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        final dropdown = find.byType(DropdownButtonFormField<String>);
        
        // Tap dropdown to open it
        await tester.tap(dropdown);
        await tester.pumpAndSettle();

        // Should show category options
        expect(find.text(BudgetCategory.venue), findsWidgets);
        expect(find.text(BudgetCategory.catering), findsWidgets);

        // Select a different category
        await tester.tap(find.text(BudgetCategory.catering));
        await tester.pumpAndSettle();

        // Should close dropdown and allow form interaction
        expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      });
    });

    group('Form Submission Tests', () {
      testWidgets('should handle form submission attempt', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Submit form with existing valid data
        await tester.tap(find.text('Update Budget Entry'));
        await tester.pumpAndSettle();

        // Form should still be present
        expect(find.byType(Form), findsOneWidget);
      });

      testWidgets('should show update button text', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Check that button text is specific to update operation
        expect(find.text('Update Budget Entry'), findsOneWidget);
        expect(find.text('Add Budget Entry'), findsNothing);
      });
    });

    group('UI Styling Tests', () {
      testWidgets('should use correct color scheme', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Check scaffold background color
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, equals(const Color(0xFF0D1B2A)));

        // Check app bar styling
        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.backgroundColor, equals(const Color(0xFF1E293B)));

        // Check button styling
        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.style!.backgroundColor!.resolve({}), equals(Colors.deepPurple));
      });

      testWidgets('should display currency symbols', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Check that currency symbol is displayed
        expect(find.text('\$'), findsWidgets);
      });

      testWidgets('should have proper form layout', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Check that form has proper structure
        expect(find.byType(Column), findsWidgets);
        expect(find.byType(SizedBox), findsWidgets);
      });
    });

    group('Field Labels and Icons Tests', () {
      testWidgets('should display appropriate field labels', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Field labels
        expect(find.text('Category'), findsOneWidget);
        expect(find.text('Description'), findsOneWidget);
        expect(find.text('Allocated Budget'), findsOneWidget);
        expect(find.text('Amount Spent'), findsOneWidget);
      });

      testWidgets('should display appropriate icons', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Check field icons
        expect(find.byIcon(Icons.category), findsOneWidget);
        expect(find.byIcon(Icons.description), findsOneWidget);
      });

      testWidgets('should display hint texts', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Check hint texts
        expect(find.text('Brief description of this budget item'), findsOneWidget);
        expect(find.text('0.00'), findsNWidgets(2)); // For both amount fields
      });
    });

    group('Loading State Tests', () {
      testWidgets('should show button in normal state initially', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Button should be enabled and show text
        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNotNull);
      });

      testWidgets('should handle button press', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Press button
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump(); // Don't settle to see immediate state

        // Should still have button present
        expect(find.byType(ElevatedButton), findsOneWidget);
      });
    });

    group('Data Persistence Tests', () {
      testWidgets('should preserve form data during interaction', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Verify dropdown is present
        expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);

        final descriptionField = tester.widget<TextFormField>(find.byType(TextFormField).first);
        expect(descriptionField.controller!.text, equals(testBudget.description));

        // Interact with fields but don't change values
        await tester.tap(find.byType(TextFormField).first);
        await tester.pumpAndSettle();

        // Data should still be the same
        expect(descriptionField.controller!.text, equals(testBudget.description));
      });

      testWidgets('should maintain field values after valid input', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Enter valid description
        await tester.enterText(find.byType(TextFormField).first, 'Updated description');
        await tester.pumpAndSettle();

        // Verify field value is maintained
        expect(tester.widget<TextFormField>(find.byType(TextFormField).first).controller!.text, equals('Updated description'));
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should have proper semantic labels', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Check that form fields have labels for accessibility
        expect(find.text('Category'), findsOneWidget);
        expect(find.text('Description'), findsOneWidget);
        expect(find.text('Allocated Budget'), findsOneWidget);
        expect(find.text('Amount Spent'), findsOneWidget);
      });

      testWidgets('should support keyboard navigation', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Verify form fields can receive focus
        final descriptionField = find.byType(TextFormField).first;
        await tester.tap(descriptionField);
        await tester.pumpAndSettle();
        
        // Field should be focusable
        expect(tester.binding.focusManager.primaryFocus?.hasFocus, isTrue);
      });
    });

    group('Category Management Tests', () {
      testWidgets('should display budget categories in dropdown', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Tap dropdown to open it
        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();

        // Check that some main categories are present (not all may be visible due to scrolling)
        expect(find.text(BudgetCategory.venue), findsWidgets);
        expect(find.text(BudgetCategory.catering), findsWidgets);
        expect(find.text(BudgetCategory.photography), findsWidgets);
      });

      testWidgets('should handle category selection', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Tap dropdown to open it
        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();

        // Select a category
        await tester.tap(find.text(BudgetCategory.photography));
        await tester.pumpAndSettle();

        // Dropdown should close
        expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      });
    });
  });
}