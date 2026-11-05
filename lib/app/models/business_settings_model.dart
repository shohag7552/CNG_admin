import 'package:appwrite_boilerplate/app/models/booking_model.dart';

/// Admin-editable business rules. Currency is fixed to BDT.
class BusinessSettingsModel {
  static const String currency = 'BDT';

  // Allowed ranges; the server re-validates them.
  static const int minRadiusKm = 1;
  static const int maxRadiusKm = 50;
  static const int minExpirySeconds = 30;
  static const int maxExpirySeconds = 300;
  static const int minFreshnessSeconds = 10;
  static const int maxFreshnessSeconds = 600;

  final String businessName;
  final String supportPhone;
  final String supportEmail;
  final Set<VehicleType> enabledVehicleTypes;
  final int defaultSearchRadiusKm;
  final int maxSearchRadiusKm;
  final int bookingExpirySeconds;
  final int driverLocationFreshnessSeconds;

  const BusinessSettingsModel({
    required this.businessName,
    required this.supportPhone,
    required this.supportEmail,
    required this.enabledVehicleTypes,
    required this.defaultSearchRadiusKm,
    required this.maxSearchRadiusKm,
    required this.bookingExpirySeconds,
    required this.driverLocationFreshnessSeconds,
  });

  BusinessSettingsModel copyWith({
    String? businessName,
    String? supportPhone,
    String? supportEmail,
    Set<VehicleType>? enabledVehicleTypes,
    int? defaultSearchRadiusKm,
    int? maxSearchRadiusKm,
    int? bookingExpirySeconds,
    int? driverLocationFreshnessSeconds,
  }) =>
      BusinessSettingsModel(
        businessName: businessName ?? this.businessName,
        supportPhone: supportPhone ?? this.supportPhone,
        supportEmail: supportEmail ?? this.supportEmail,
        enabledVehicleTypes: enabledVehicleTypes ?? this.enabledVehicleTypes,
        defaultSearchRadiusKm:
            defaultSearchRadiusKm ?? this.defaultSearchRadiusKm,
        maxSearchRadiusKm: maxSearchRadiusKm ?? this.maxSearchRadiusKm,
        bookingExpirySeconds: bookingExpirySeconds ?? this.bookingExpirySeconds,
        driverLocationFreshnessSeconds: driverLocationFreshnessSeconds ??
            this.driverLocationFreshnessSeconds,
      );

  /// Field name -> translation key of the problem. Empty = valid.
  Map<String, String> validate() {
    final e = <String, String>{};
    if (businessName.trim().isEmpty) e['businessName'] = 'field_required';
    if (supportPhone.trim().length < 6) e['supportPhone'] = 'invalid_phone';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(supportEmail.trim())) {
      e['supportEmail'] = 'invalid_email';
    }
    if (enabledVehicleTypes.isEmpty) {
      e['enabledVehicleTypes'] = 'one_vehicle_required';
    }
    if (maxSearchRadiusKm < minRadiusKm || maxSearchRadiusKm > maxRadiusKm) {
      e['maxSearchRadiusKm'] = 'out_of_range';
    }
    if (defaultSearchRadiusKm < minRadiusKm ||
        defaultSearchRadiusKm > maxRadiusKm) {
      e['defaultSearchRadiusKm'] = 'out_of_range';
    } else if (defaultSearchRadiusKm > maxSearchRadiusKm) {
      e['defaultSearchRadiusKm'] = 'default_radius_exceeds_max';
    }
    if (bookingExpirySeconds < minExpirySeconds ||
        bookingExpirySeconds > maxExpirySeconds) {
      e['bookingExpirySeconds'] = 'out_of_range';
    }
    if (driverLocationFreshnessSeconds < minFreshnessSeconds ||
        driverLocationFreshnessSeconds > maxFreshnessSeconds) {
      e['driverLocationFreshnessSeconds'] = 'out_of_range';
    }
    return e;
  }

  @override
  bool operator ==(Object other) =>
      other is BusinessSettingsModel &&
      other.businessName == businessName &&
      other.supportPhone == supportPhone &&
      other.supportEmail == supportEmail &&
      other.enabledVehicleTypes.length == enabledVehicleTypes.length &&
      other.enabledVehicleTypes.containsAll(enabledVehicleTypes) &&
      other.defaultSearchRadiusKm == defaultSearchRadiusKm &&
      other.maxSearchRadiusKm == maxSearchRadiusKm &&
      other.bookingExpirySeconds == bookingExpirySeconds &&
      other.driverLocationFreshnessSeconds == driverLocationFreshnessSeconds;

  @override
  int get hashCode => Object.hash(businessName, supportPhone, supportEmail,
      enabledVehicleTypes.length, defaultSearchRadiusKm, maxSearchRadiusKm,
      bookingExpirySeconds, driverLocationFreshnessSeconds);
}
