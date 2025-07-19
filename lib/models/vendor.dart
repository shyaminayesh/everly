class Vendor {
  final int? id;
  final String name;
  final String contact;
  final String category;
  final String notes;
  final int weddingEventId;
  final DateTime createdAt;

  Vendor({
    this.id,
    required this.name,
    required this.contact,
    required this.category,
    required this.notes,
    required this.weddingEventId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'category': category,
      'notes': notes,
      'weddingEventId': weddingEventId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Vendor.fromMap(Map<String, dynamic> map) {
    return Vendor(
      id: map['id'],
      name: map['name'],
      contact: map['contact'],
      category: map['category'],
      notes: map['notes'],
      weddingEventId: map['weddingEventId'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Vendor copyWith({
    int? id,
    String? name,
    String? contact,
    String? category,
    String? notes,
    int? weddingEventId,
    DateTime? createdAt,
  }) {
    return Vendor(
      id: id ?? this.id,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      weddingEventId: weddingEventId ?? this.weddingEventId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class VendorCategory {
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
  static const String other = 'Other';

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
    other,
  ];
}