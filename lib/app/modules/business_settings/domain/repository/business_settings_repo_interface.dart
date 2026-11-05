import 'package:appwrite_boilerplate/app/models/business_settings_model.dart';

abstract class BusinessSettingsRepoInterface {
  Future<BusinessSettingsModel> getSettings();

  /// Re-validated server-side; audited.
  Future<BusinessSettingsModel> saveSettings(BusinessSettingsModel settings);
}
