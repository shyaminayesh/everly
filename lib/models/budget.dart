class Budget {
  final int? id;
  final String category;
  final String description;
  final double allocatedAmount;
  final double spentAmount;
  final int weddingEventId;
  final DateTime createdAt;

  Budget({
    this.id,
    required this.category,
    required this.description,
    required this.allocatedAmount,
    required this.spentAmount,
    required this.weddingEventId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get remainingAmount => allocatedAmount - spentAmount;
  double get progressPercentage => allocatedAmount > 0 ? (spentAmount / allocatedAmount * 100).clamp(0, 100) : 0;
  bool get isOverBudget => spentAmount > allocatedAmount;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'description': description,
      'allocatedAmount': allocatedAmount,
      'spentAmount': spentAmount,
      'weddingEventId': weddingEventId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      category: map['category'],
      description: map['description'],
      allocatedAmount: map['allocatedAmount']?.toDouble() ?? 0.0,
      spentAmount: map['spentAmount']?.toDouble() ?? 0.0,
      weddingEventId: map['weddingEventId'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Budget copyWith({
    int? id,
    String? category,
    String? description,
    double? allocatedAmount,
    double? spentAmount,
    int? weddingEventId,
    DateTime? createdAt,
  }) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      description: description ?? this.description,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      weddingEventId: weddingEventId ?? this.weddingEventId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class BudgetCategory {
  static const String venue = 'Venue';
  static const String catering = 'Catering';
  static const String photography = 'Photography';
  static const String videography = 'Videography';
  static const String music = 'Music/DJ';
  static const String decoration = 'Decoration';
  static const String flowers = 'Flowers';
  static const String transportation = 'Transportation';
  static const String accommodation = 'Accommodation';
  static const String beauty = 'Beauty/Makeup';
  static const String attire = 'Attire/Clothing';
  static const String entertainment = 'Entertainment';
  static const String rings = 'Rings';
  static const String invitations = 'Invitations';
  static const String gifts = 'Gifts';
  static const String miscellaneous = 'Miscellaneous';

  static List<String> get allCategories => [
    venue,
    catering,
    photography,
    videography,
    music,
    decoration,
    flowers,
    transportation,
    accommodation,
    beauty,
    attire,
    entertainment,
    rings,
    invitations,
    gifts,
    miscellaneous,
  ];
}