class WeddingEvent {
  final int? id;
  final String brideName;
  final String groomName;
  final DateTime weddingDate;
  final DateTime createdAt;

  WeddingEvent({
    this.id,
    required this.brideName,
    required this.groomName,
    required this.weddingDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brideName': brideName,
      'groomName': groomName,
      'weddingDate': weddingDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WeddingEvent.fromMap(Map<String, dynamic> map) {
    return WeddingEvent(
      id: map['id'],
      brideName: map['brideName'],
      groomName: map['groomName'],
      weddingDate: DateTime.parse(map['weddingDate']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  WeddingEvent copyWith({
    int? id,
    String? brideName,
    String? groomName,
    DateTime? weddingDate,
    DateTime? createdAt,
  }) {
    return WeddingEvent(
      id: id ?? this.id,
      brideName: brideName ?? this.brideName,
      groomName: groomName ?? this.groomName,
      weddingDate: weddingDate ?? this.weddingDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get coupleNames => '$brideName & $groomName';
}