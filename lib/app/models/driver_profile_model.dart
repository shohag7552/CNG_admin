import 'package:appwrite_boilerplate/app/models/booking_model.dart';

enum VerificationStatus {
  pending,
  approved,
  rejected;

  static VerificationStatus parse(String? v) => VerificationStatus.values
      .firstWhere((e) => e.name == v, orElse: () => VerificationStatus.pending);
}

enum AvailabilityStatus { online, offline, onTrip }

class DriverProfileModel {
  final String id;
  final String name;
  final String phone;
  final VehicleType vehicleType;
  final String registration;
  final String vehicleModel;
  final VerificationStatus verificationStatus;
  final AvailabilityStatus availabilityStatus;

  /// False = suspended by an admin.
  final bool isActive;
  final double rating;
  final int tripCount;
  final DateTime joinedAt;
  final String? rejectionReason;
  final String? suspensionReason;

  const DriverProfileModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.vehicleType,
    required this.registration,
    required this.vehicleModel,
    required this.verificationStatus,
    required this.availabilityStatus,
    required this.isActive,
    required this.rating,
    required this.tripCount,
    required this.joinedAt,
    this.rejectionReason,
    this.suspensionReason,
  });

  /// Only the fields an admin action may change are copyable.
  DriverProfileModel copyWith({
    VerificationStatus? verificationStatus,
    AvailabilityStatus? availabilityStatus,
    bool? isActive,
    String? rejectionReason,
    String? suspensionReason,
  }) =>
      DriverProfileModel(
        id: id,
        name: name,
        phone: phone,
        vehicleType: vehicleType,
        registration: registration,
        vehicleModel: vehicleModel,
        verificationStatus: verificationStatus ?? this.verificationStatus,
        availabilityStatus: availabilityStatus ?? this.availabilityStatus,
        isActive: isActive ?? this.isActive,
        rating: rating,
        tripCount: tripCount,
        joinedAt: joinedAt,
        rejectionReason: rejectionReason ?? this.rejectionReason,
        suspensionReason: suspensionReason ?? this.suspensionReason,
      );
}
