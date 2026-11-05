import 'package:appwrite_boilerplate/app/helper/mock_admin_store.dart';
import 'package:appwrite_boilerplate/app/models/audit_log_model.dart';
import 'package:appwrite_boilerplate/app/models/business_settings_model.dart';
import 'package:appwrite_boilerplate/app/modules/business_settings/domain/repository/business_settings_repo_interface.dart';

class BusinessSettingsRepository implements BusinessSettingsRepoInterface {
  final MockAdminStore store;
  final Duration tick;

  BusinessSettingsRepository({required this.store, this.tick = const Duration(milliseconds: 500)});

  @override
  Future<BusinessSettingsModel> getSettings() async {
    await Future<void>.delayed(tick);
    return store.settings;
  }

  @override
  Future<BusinessSettingsModel> saveSettings(BusinessSettingsModel settings) async {
    await Future<void>.delayed(tick);
    if (settings.validate().isNotEmpty) throw StateError('invalid_settings');
    store.settings = settings;
    store.addAudit(AuditAction.settingsUpdated, 'settings', 'business_settings');
    return settings;
  }
}
