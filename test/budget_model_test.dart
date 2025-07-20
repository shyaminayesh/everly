import 'package:flutter_test/flutter_test.dart';
import 'package:everly/models/budget.dart';

/// Comprehensive unit tests for the Budget model class and BudgetCategory
/// Tests model creation, validation, calculations, and data serialization
void main() {
  group('Budget Model Tests', () {
    group('Budget Creation Tests', () {
      test('should create budget with required fields', () {
        final budget = Budget(
          category: BudgetCategory.venue,
          description: 'Wedding venue rental',
          allocatedAmount: 5000.0,
          spentAmount: 2500.0,
          weddingEventId: 1,
        );

        expect(budget.category, equals(BudgetCategory.venue));
        expect(budget.description, equals('Wedding venue rental'));
        expect(budget.allocatedAmount, equals(5000.0));
        expect(budget.spentAmount, equals(2500.0));
        expect(budget.weddingEventId, equals(1));
        expect(budget.id, isNull);
        expect(budget.createdAt, isA<DateTime>());
      });

      test('should create budget with optional id', () {
        final budget = Budget(
          id: 123,
          category: BudgetCategory.catering,
          description: 'Wedding catering',
          allocatedAmount: 3000.0,
          spentAmount: 1500.0,
          weddingEventId: 1,
        );

        expect(budget.id, equals(123));
      });

      test('should create budget with custom createdAt', () {
        final customDate = DateTime(2024, 6, 15);
        final budget = Budget(
          category: BudgetCategory.photography,
          description: 'Wedding photography',
          allocatedAmount: 2000.0,
          spentAmount: 0.0,
          weddingEventId: 1,
          createdAt: customDate,
        );

        expect(budget.createdAt, equals(customDate));
      });

      test('should use current time when createdAt is null', () {
        final beforeCreation = DateTime.now();
        final budget = Budget(
          category: BudgetCategory.music,
          description: 'DJ services',
          allocatedAmount: 1500.0,
          spentAmount: 500.0,
          weddingEventId: 1,
        );
        final afterCreation = DateTime.now();

        expect(budget.createdAt.isAfter(beforeCreation) || budget.createdAt.isAtSameMomentAs(beforeCreation), isTrue);
        expect(budget.createdAt.isBefore(afterCreation) || budget.createdAt.isAtSameMomentAs(afterCreation), isTrue);
      });
    });

    group('Budget Calculations Tests', () {
      test('should calculate remaining amount correctly', () {
        final budget = Budget(
          category: BudgetCategory.venue,
          description: 'Test venue',
          allocatedAmount: 5000.0,
          spentAmount: 2000.0,
          weddingEventId: 1,
        );

        expect(budget.remainingAmount, equals(3000.0));
      });

      test('should calculate negative remaining amount when over budget', () {
        final budget = Budget(
          category: BudgetCategory.venue,
          description: 'Test venue',
          allocatedAmount: 5000.0,
          spentAmount: 6000.0,
          weddingEventId: 1,
        );

        expect(budget.remainingAmount, equals(-1000.0));
      });

      test('should calculate progress percentage correctly', () {
        final budget = Budget(
          category: BudgetCategory.venue,
          description: 'Test venue',
          allocatedAmount: 1000.0,
          spentAmount: 250.0,
          weddingEventId: 1,
        );

        expect(budget.progressPercentage, equals(25.0));
      });

      test('should cap progress percentage at 100%', () {
        final budget = Budget(
          category: BudgetCategory.venue,
          description: 'Test venue',
          allocatedAmount: 1000.0,
          spentAmount: 1500.0,
          weddingEventId: 1,
        );

        expect(budget.progressPercentage, equals(100.0));
      });

      test('should return 0% progress when allocated amount is 0', () {
        final budget = Budget(
          category: BudgetCategory.venue,
          description: 'Test venue',
          allocatedAmount: 0.0,
          spentAmount: 100.0,
          weddingEventId: 1,
        );

        expect(budget.progressPercentage, equals(0.0));
      });

      test('should return 0% progress when spent amount is 0', () {
        final budget = Budget(
          category: BudgetCategory.venue,
          description: 'Test venue',
          allocatedAmount: 1000.0,
          spentAmount: 0.0,
          weddingEventId: 1,
        );

        expect(budget.progressPercentage, equals(0.0));
      });

      test('should correctly identify over budget status', () {
        final overBudget = Budget(
          category: BudgetCategory.venue,
          description: 'Test venue',
          allocatedAmount: 1000.0,
          spentAmount: 1500.0,
          weddingEventId: 1,
        );

        final withinBudget = Budget(
          category: BudgetCategory.catering,
          description: 'Test catering',
          allocatedAmount: 2000.0,
          spentAmount: 1500.0,
          weddingEventId: 1,
        );

        final exactBudget = Budget(
          category: BudgetCategory.photography,
          description: 'Test photography',
          allocatedAmount: 1000.0,
          spentAmount: 1000.0,
          weddingEventId: 1,
        );

        expect(overBudget.isOverBudget, isTrue);
        expect(withinBudget.isOverBudget, isFalse);
        expect(exactBudget.isOverBudget, isFalse);
      });
    });

    group('Budget Serialization Tests', () {
      test('should convert to map correctly', () {
        final createdAt = DateTime(2024, 6, 15, 10, 30, 0);
        final budget = Budget(
          id: 123,
          category: BudgetCategory.venue,
          description: 'Wedding venue',
          allocatedAmount: 5000.0,
          spentAmount: 2500.0,
          weddingEventId: 1,
          createdAt: createdAt,
        );

        final map = budget.toMap();

        expect(map['id'], equals(123));
        expect(map['category'], equals(BudgetCategory.venue));
        expect(map['description'], equals('Wedding venue'));
        expect(map['allocatedAmount'], equals(5000.0));
        expect(map['spentAmount'], equals(2500.0));
        expect(map['weddingEventId'], equals(1));
        expect(map['createdAt'], equals(createdAt.toIso8601String()));
      });

      test('should create from map correctly', () {
        final map = {
          'id': 456,
          'category': BudgetCategory.catering,
          'description': 'Wedding catering service',
          'allocatedAmount': 3000.0,
          'spentAmount': 1200.0,
          'weddingEventId': 2,
          'createdAt': '2024-06-15T10:30:00.000Z',
        };

        final budget = Budget.fromMap(map);

        expect(budget.id, equals(456));
        expect(budget.category, equals(BudgetCategory.catering));
        expect(budget.description, equals('Wedding catering service'));
        expect(budget.allocatedAmount, equals(3000.0));
        expect(budget.spentAmount, equals(1200.0));
        expect(budget.weddingEventId, equals(2));
        expect(budget.createdAt, equals(DateTime.parse('2024-06-15T10:30:00.000Z')));
      });

      test('should handle null values in fromMap', () {
        final map = {
          'id': null,
          'category': BudgetCategory.photography,
          'description': 'Wedding photography',
          'allocatedAmount': null,
          'spentAmount': null,
          'weddingEventId': 3,
          'createdAt': '2024-06-15T10:30:00.000Z',
        };

        final budget = Budget.fromMap(map);

        expect(budget.id, isNull);
        expect(budget.allocatedAmount, equals(0.0));
        expect(budget.spentAmount, equals(0.0));
      });

      test('should handle integer amounts in fromMap', () {
        final map = {
          'id': 789,
          'category': BudgetCategory.music,
          'description': 'DJ services',
          'allocatedAmount': 1500, // Integer instead of double
          'spentAmount': 750, // Integer instead of double
          'weddingEventId': 4,
          'createdAt': '2024-06-15T10:30:00.000Z',
        };

        final budget = Budget.fromMap(map);

        expect(budget.allocatedAmount, equals(1500.0));
        expect(budget.spentAmount, equals(750.0));
      });
    });

    group('Budget CopyWith Tests', () {
      test('should create copy with no changes', () {
        final original = Budget(
          id: 100,
          category: BudgetCategory.venue,
          description: 'Original venue',
          allocatedAmount: 5000.0,
          spentAmount: 2500.0,
          weddingEventId: 1,
        );

        final copy = original.copyWith();

        expect(copy.id, equals(original.id));
        expect(copy.category, equals(original.category));
        expect(copy.description, equals(original.description));
        expect(copy.allocatedAmount, equals(original.allocatedAmount));
        expect(copy.spentAmount, equals(original.spentAmount));
        expect(copy.weddingEventId, equals(original.weddingEventId));
        expect(copy.createdAt, equals(original.createdAt));
      });

      test('should create copy with specific field changes', () {
        final original = Budget(
          id: 100,
          category: BudgetCategory.venue,
          description: 'Original venue',
          allocatedAmount: 5000.0,
          spentAmount: 2500.0,
          weddingEventId: 1,
        );

        final copy = original.copyWith(
          description: 'Updated venue',
          spentAmount: 3000.0,
        );

        expect(copy.id, equals(original.id));
        expect(copy.category, equals(original.category));
        expect(copy.description, equals('Updated venue'));
        expect(copy.allocatedAmount, equals(original.allocatedAmount));
        expect(copy.spentAmount, equals(3000.0));
        expect(copy.weddingEventId, equals(original.weddingEventId));
        expect(copy.createdAt, equals(original.createdAt));
      });

      test('should create copy with all field changes', () {
        final original = Budget(
          id: 100,
          category: BudgetCategory.venue,
          description: 'Original venue',
          allocatedAmount: 5000.0,
          spentAmount: 2500.0,
          weddingEventId: 1,
        );

        final newDate = DateTime(2024, 7, 1);
        final copy = original.copyWith(
          id: 200,
          category: BudgetCategory.catering,
          description: 'Updated catering',
          allocatedAmount: 7000.0,
          spentAmount: 3500.0,
          weddingEventId: 2,
          createdAt: newDate,
        );

        expect(copy.id, equals(200));
        expect(copy.category, equals(BudgetCategory.catering));
        expect(copy.description, equals('Updated catering'));
        expect(copy.allocatedAmount, equals(7000.0));
        expect(copy.spentAmount, equals(3500.0));
        expect(copy.weddingEventId, equals(2));
        expect(copy.createdAt, equals(newDate));
      });
    });

    group('Edge Cases Tests', () {
      test('should handle zero amounts correctly', () {
        final budget = Budget(
          category: BudgetCategory.venue,
          description: 'Zero budget test',
          allocatedAmount: 0.0,
          spentAmount: 0.0,
          weddingEventId: 1,
        );

        expect(budget.remainingAmount, equals(0.0));
        expect(budget.progressPercentage, equals(0.0));
        expect(budget.isOverBudget, isFalse);
      });

      test('should handle large amounts correctly', () {
        final budget = Budget(
          category: BudgetCategory.venue,
          description: 'Large budget test',
          allocatedAmount: 999999.99,
          spentAmount: 500000.50,
          weddingEventId: 1,
        );

        expect(budget.remainingAmount, equals(499999.49));
        expect(budget.progressPercentage, closeTo(50.0, 0.1));
        expect(budget.isOverBudget, isFalse);
      });

      test('should handle decimal precision correctly', () {
        final budget = Budget(
          category: BudgetCategory.venue,
          description: 'Precision test',
          allocatedAmount: 100.33,
          spentAmount: 33.11,
          weddingEventId: 1,
        );

        expect(budget.remainingAmount, closeTo(67.22, 0.001));
        expect(budget.progressPercentage, closeTo(33.0, 0.1));
      });
    });
  });

  group('BudgetCategory Tests', () {
    group('Category Constants Tests', () {
      test('should have all expected category constants', () {
        expect(BudgetCategory.venue, equals('Venue'));
        expect(BudgetCategory.catering, equals('Catering'));
        expect(BudgetCategory.photography, equals('Photography'));
        expect(BudgetCategory.videography, equals('Videography'));
        expect(BudgetCategory.music, equals('Music/DJ'));
        expect(BudgetCategory.decoration, equals('Decoration'));
        expect(BudgetCategory.flowers, equals('Flowers'));
        expect(BudgetCategory.transportation, equals('Transportation'));
        expect(BudgetCategory.accommodation, equals('Accommodation'));
        expect(BudgetCategory.beauty, equals('Beauty/Makeup'));
        expect(BudgetCategory.attire, equals('Attire/Clothing'));
        expect(BudgetCategory.entertainment, equals('Entertainment'));
        expect(BudgetCategory.rings, equals('Rings'));
        expect(BudgetCategory.invitations, equals('Invitations'));
        expect(BudgetCategory.gifts, equals('Gifts'));
        expect(BudgetCategory.miscellaneous, equals('Miscellaneous'));
      });

      test('should have correct number of categories', () {
        expect(BudgetCategory.allCategories.length, equals(16));
      });

      test('should contain all categories in allCategories list', () {
        final categories = BudgetCategory.allCategories;
        
        expect(categories.contains(BudgetCategory.venue), isTrue);
        expect(categories.contains(BudgetCategory.catering), isTrue);
        expect(categories.contains(BudgetCategory.photography), isTrue);
        expect(categories.contains(BudgetCategory.videography), isTrue);
        expect(categories.contains(BudgetCategory.music), isTrue);
        expect(categories.contains(BudgetCategory.decoration), isTrue);
        expect(categories.contains(BudgetCategory.flowers), isTrue);
        expect(categories.contains(BudgetCategory.transportation), isTrue);
        expect(categories.contains(BudgetCategory.accommodation), isTrue);
        expect(categories.contains(BudgetCategory.beauty), isTrue);
        expect(categories.contains(BudgetCategory.attire), isTrue);
        expect(categories.contains(BudgetCategory.entertainment), isTrue);
        expect(categories.contains(BudgetCategory.rings), isTrue);
        expect(categories.contains(BudgetCategory.invitations), isTrue);
        expect(categories.contains(BudgetCategory.gifts), isTrue);
        expect(categories.contains(BudgetCategory.miscellaneous), isTrue);
      });

      test('should not have duplicate categories', () {
        final categories = BudgetCategory.allCategories;
        final uniqueCategories = categories.toSet().toList();
        
        expect(categories.length, equals(uniqueCategories.length));
      });

      test('should maintain consistent category ordering', () {
        final expectedOrder = [
          BudgetCategory.venue,
          BudgetCategory.catering,
          BudgetCategory.photography,
          BudgetCategory.videography,
          BudgetCategory.music,
          BudgetCategory.decoration,
          BudgetCategory.flowers,
          BudgetCategory.transportation,
          BudgetCategory.accommodation,
          BudgetCategory.beauty,
          BudgetCategory.attire,
          BudgetCategory.entertainment,
          BudgetCategory.rings,
          BudgetCategory.invitations,
          BudgetCategory.gifts,
          BudgetCategory.miscellaneous,
        ];

        expect(BudgetCategory.allCategories, equals(expectedOrder));
      });
    });

    group('Category Validation Tests', () {
      test('should allow valid categories in Budget creation', () {
        for (String category in BudgetCategory.allCategories) {
          final budget = Budget(
            category: category,
            description: 'Test for $category',
            allocatedAmount: 1000.0,
            spentAmount: 500.0,
            weddingEventId: 1,
          );

          expect(budget.category, equals(category));
        }
      });

      test('should handle category case sensitivity', () {
        // Test that categories are case-sensitive strings
        expect(BudgetCategory.venue, isNot(equals('venue')));
        expect(BudgetCategory.venue, isNot(equals('VENUE')));
        expect(BudgetCategory.venue, equals('Venue'));
      });
    });
  });
}