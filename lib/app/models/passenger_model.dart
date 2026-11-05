class PassengerModel {
  final String id;
  final String name;
  final String phone;
  final String email;

  /// False = suspended by an admin.
  final bool isActive;
  final int tripCount;
  final DateTime joinedAt;
  final String? suspensionReason;

  const PassengerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.isActive,
    required this.tripCount,
    required this.joinedAt,
    this.suspensionReason,
  });

  PassengerModel copyWith({bool? isActive, String? suspensionReason}) =>
      PassengerModel(
        id: id,
        name: name,
        phone: phone,
        email: email,
        isActive: isActive ?? this.isActive,
        tripCount: tripCount,
        joinedAt: joinedAt,
        suspensionReason: suspensionReason ?? this.suspensionReason,
      );
}
