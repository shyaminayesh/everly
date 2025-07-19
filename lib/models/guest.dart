class Guest {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String rsvpStatus;
  final String side;
  final String dietaryRestrictions;
  final int weddingEventId;
  final DateTime createdAt;

  Guest({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.rsvpStatus,
    required this.side,
    required this.dietaryRestrictions,
    required this.weddingEventId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'rsvpStatus': rsvpStatus,
      'side': side,
      'dietaryRestrictions': dietaryRestrictions,
      'weddingEventId': weddingEventId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Guest.fromMap(Map<String, dynamic> map) {
    return Guest(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      rsvpStatus: map['rsvpStatus'],
      side: map['side'],
      dietaryRestrictions: map['dietaryRestrictions'],
      weddingEventId: map['weddingEventId'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Guest copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? rsvpStatus,
    String? side,
    String? dietaryRestrictions,
    int? weddingEventId,
    DateTime? createdAt,
  }) {
    return Guest(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      rsvpStatus: rsvpStatus ?? this.rsvpStatus,
      side: side ?? this.side,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      weddingEventId: weddingEventId ?? this.weddingEventId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class RSVPStatus {
  static const String pending = 'Pending';
  static const String attending = 'Attending';
  static const String notAttending = 'Not Attending';

  static List<String> get allStatuses => [
    pending,
    attending,
    notAttending,
  ];
}

class GuestSide {
  static const String bride = "Bride's Side";
  static const String groom = "Groom's Side";

  static List<String> get allSides => [
    bride,
    groom,
  ];
}