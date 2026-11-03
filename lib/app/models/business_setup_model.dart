/// Remote app configuration, one row in the `business_setup` table.
///
/// Owned by the admin side; this app only reads it at startup (see
/// `SettingsController.fetchSettings`). Add a field here + a column in
/// Appwrite whenever you need a new remotely-tunable switch.
class BusinessSetupModel {
  final String? id;
  final String businessName;
  final String currency;
  final String address;
  final double? latitude;
  final double? longitude;

  /// Startup gate: when on, every user is held on the maintenance screen.
  final bool isMaintenanceModeOn;

  /// "Forgot password" emails a 6-digit code (Appwrite `createEmailToken`)
  /// instead of a reset link. False (links) when off or the column is missing.
  final bool isEmailOtpEnabled;

  // Force update — see [requiresForceUpdate].
  final bool isForceUpdateActive;
  final String? appMinVersion;
  final String? androidStoreUrl;
  final String? iosStoreUrl;

  final String? copyrightText;
  final String? cookiesText;

  /// LocationIQ access token; overrides `Constants.locationIqKey`. Empty means
  /// the free OpenStreetMap servers are used for tiles + geocoding.
  final String? locationIqKey;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BusinessSetupModel({
    this.id,
    this.businessName = '',
    this.currency = 'USD',
    this.address = '',
    this.latitude,
    this.longitude,
    this.isMaintenanceModeOn = false,
    this.isEmailOtpEnabled = false,
    this.isForceUpdateActive = false,
    this.appMinVersion,
    this.androidStoreUrl,
    this.iosStoreUrl,
    this.copyrightText,
    this.cookiesText,
    this.locationIqKey,
    this.createdAt,
    this.updatedAt,
  });

  factory BusinessSetupModel.fromJson(Map<String, dynamic> json) {
    return BusinessSetupModel(
      id: json['\$id'],
      businessName: json['business_name'] ?? '',
      currency: json['currency_symbol'] ?? 'USD',
      address: json['store_location'] ?? '',
      latitude: (json['store_latitude'] as num?)?.toDouble(),
      longitude: (json['store_longitude'] as num?)?.toDouble(),
      isMaintenanceModeOn: json['is_maintenance_mode_on'] ?? false,
      isEmailOtpEnabled: json['is_email_otp_enabled'] == true,
      isForceUpdateActive: json['is_force_update_active'] ?? false,
      appMinVersion: json['app_min_version'],
      androidStoreUrl: json['android_store_url'],
      iosStoreUrl: json['ios_store_url'],
      copyrightText: json['copyright_text'] as String?,
      cookiesText: json['cookies_text'] as String?,
      locationIqKey: json['location_iq_key'] as String?,
      createdAt: DateTime.tryParse(json['\$createdAt'] ?? ''),
      updatedAt: DateTime.tryParse(json['\$updatedAt'] ?? ''),
    );
  }

  /// Read-only on the client: [locationIqKey] and [isEmailOtpEnabled] are
  /// deliberately omitted so a client write can never change them.
  Map<String, dynamic> toJson() => {
        'business_name': businessName,
        'currency_symbol': currency,
        'store_location': address,
        'store_latitude': latitude,
        'store_longitude': longitude,
        'is_maintenance_mode_on': isMaintenanceModeOn,
        'is_force_update_active': isForceUpdateActive,
        'app_min_version': appMinVersion,
        'android_store_url': androidStoreUrl,
        'ios_store_url': iosStoreUrl,
        'copyright_text': copyrightText,
        'cookies_text': cookiesText,
      };

  BusinessSetupModel copyWith({
    String? businessName,
    String? currency,
    String? address,
    double? latitude,
    double? longitude,
    bool? isMaintenanceModeOn,
    bool? isEmailOtpEnabled,
    bool? isForceUpdateActive,
    String? appMinVersion,
    String? androidStoreUrl,
    String? iosStoreUrl,
    String? copyrightText,
    String? cookiesText,
    String? locationIqKey,
  }) {
    return BusinessSetupModel(
      id: id,
      businessName: businessName ?? this.businessName,
      currency: currency ?? this.currency,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isMaintenanceModeOn: isMaintenanceModeOn ?? this.isMaintenanceModeOn,
      isEmailOtpEnabled: isEmailOtpEnabled ?? this.isEmailOtpEnabled,
      isForceUpdateActive: isForceUpdateActive ?? this.isForceUpdateActive,
      appMinVersion: appMinVersion ?? this.appMinVersion,
      androidStoreUrl: androidStoreUrl ?? this.androidStoreUrl,
      iosStoreUrl: iosStoreUrl ?? this.iosStoreUrl,
      copyrightText: copyrightText ?? this.copyrightText,
      cookiesText: cookiesText ?? this.cookiesText,
      locationIqKey: locationIqKey ?? this.locationIqKey,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Whether the running build ([currentVersion], e.g. "1.0.0") must be
  /// upgraded. True only when [isForceUpdateActive] AND a valid
  /// [appMinVersion] higher than [currentVersion] is set. Fails open on
  /// missing/unparseable config so a bad setting can't lock everyone out.
  bool requiresForceUpdate(String currentVersion) {
    if (!isForceUpdateActive) return false;
    final min = appMinVersion?.trim();
    if (min == null || min.isEmpty) return false;
    return compareVersions(currentVersion, min) < 0;
  }

  /// Numeric dot-version compare: <0 when [a] < [b]. Missing segments count
  /// as 0 ("1.2" == "1.2.0"); non-numeric segments count as 0.
  static int compareVersions(String a, String b) {
    final aParts = a.split('.');
    final bParts = b.split('.');
    final length = aParts.length > bParts.length ? aParts.length : bParts.length;
    for (int i = 0; i < length; i++) {
      final aVal = i < aParts.length ? (int.tryParse(aParts[i].trim()) ?? 0) : 0;
      final bVal = i < bParts.length ? (int.tryParse(bParts[i].trim()) ?? 0) : 0;
      if (aVal != bVal) return aVal - bVal;
    }
    return 0;
  }
}
