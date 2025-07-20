import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:everly/screens/add_budget.dart';
import 'package:everly/models/budget.dart';

/// Unit tests for the AddBudgetScreen widget
void main() {
  group('AddBudgetScreen Widget Tests', () {
    late Widget testApp;

    setUp(() {
      testApp = const MaterialApp(
        home: AddBudgetScreen(),
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
          matching: find.text('Add Budget Entry'),
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

      testWidgets('should display field labels', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Field labels
        expect(find.text('Category'), findsOneWidget);
        expect(find.text('Description'), findsOneWidget);
        expect(find.text('Allocated Budget'), findsOneWidget);
        expect(find.text('Amount Spent (Optional)'), findsOneWidget);
      });
    });

    group('Form Field Tests', () {
      testWidgets('should display category dropdown', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
        expect(find.byIcon(Icons.category), findsOneWidget);
      });

      testWidgets('should show budget categories when dropdown is tapped', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Tap dropdown to open it
        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();

        // Check that some categories are present
        expect(find.text(BudgetCategory.venue), findsWidgets);
        expect(find.text(BudgetCategory.catering), findsWidgets);
      });

      testWidgets('should allow text input in description field', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        final descriptionField = find.byType(TextFormField).first;
        
        await tester.enterText(descriptionField, 'Test description');
        expect(tester.widget<TextFormField>(descriptionField).controller!.text, equals('Test description'));
      });

      testWidgets('should allow numeric input in amount fields', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        final allocatedField = find.byType(TextFormField).at(1);
        final spentField = find.byType(TextFormField).at(2);
        
        await tester.enterText(allocatedField, '1500.50');
        await tester.enterText(spentField, '750.25');
        
        expect(tester.widget<TextFormField>(allocatedField).controller!.text, equals('1500.50'));
        expect(tester.widget<TextFormField>(spentField).controller!.text, equals('750.25'));
      });
    });

    group('Form Interaction Tests', () {
      testWidgets('should handle form submission attempt', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Try to submit form
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Form should still be present (validation may prevent submission)
        expect(find.byType(Form), findsOneWidget);
      });

      testWidgets('should allow category selection', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        final dropdown = find.byType(DropdownButtonFormField<String>);
        
        // Tap dropdown to open it
        await tester.tap(dropdown);
        await tester.pumpAndSettle();

        // Select a category
        await tester.tap(find.text(BudgetCategory.catering));
        await tester.pumpAndSettle();

        // Should close dropdown
        expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      });

      testWidgets('should handle field focus changes', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Focus on description field
        await tester.tap(find.byType(TextFormField).first);
        await tester.pumpAndSettle();
        
        // Should be able to enter text
        await tester.enterText(find.byType(TextFormField).first, 'Focused input');
        expect(find.text('Focused input'), findsOneWidget);
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
      });

      testWidgets('should have proper button styling', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

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
    });

    group('Field Icons Tests', () {
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
        expect(find.text('Add Budget Entry'), findsWidgets);
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

    group('Title and Content Tests', () {
      testWidgets('should display page title', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        expect(find.text('Add a new budget entry'), findsOneWidget);
      });

      testWidgets('should have proper form layout', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Check that form has proper structure
        expect(find.byType(Column), findsWidgets);
        expect(find.byType(SizedBox), findsWidgets);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should have semantic labels', (WidgetTester tester) async {
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Check that form fields have labels
        expect(find.text('Category'), findsOneWidget);
        expect(find.text('Description'), findsOneWidget);
        expect(find.text('Allocated Budget'), findsOneWidget);
        expect(find.text('Amount Spent (Optional)'), findsOneWidget);
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
  });
}