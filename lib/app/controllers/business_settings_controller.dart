import 'dart:developer';

import 'package:appwrite_boilerplate/app/models/booking_model.dart';
import 'package:appwrite_boilerplate/app/models/business_settings_model.dart';
import 'package:appwrite_boilerplate/app/modules/business_settings/domain/repository/business_settings_repo_interface.dart';
import 'package:get/get.dart';

/// Holds the saved settings and the admin's unsaved draft.
class BusinessSettingsController extends GetxController implements GetxService {
  final BusinessSettingsRepoInterface settingsRepoInterface;

  BusinessSettingsController({required this.settingsRepoInterface});

  BusinessSettingsModel? _saved;
  BusinessSettingsModel? get saved => _saved;
  BusinessSettingsModel? _draft;
  BusinessSettingsModel? get draft => _draft;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isSaving = false;
  bool get isSaving => _isSaving;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get hasUnsavedChanges => _draft != null && _draft != _saved;

  /// Field -> translation key of the problem with the current draft.
  Map<String, String> get errors => _draft?.validate() ?? const {};
  bool get isValid => errors.isEmpty;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    update();
    try {
      _saved = await settingsRepoInterface.getSettings();
      _draft = _saved;
    } catch (e) {
      log('Failed to load settings: $e');
      _errorMessage = 'failed_to_load_data'.tr;
    }
    _isLoading = false;
    update();
  }

  void edit(BusinessSettingsModel Function(BusinessSettingsModel d) change) {
    final d = _draft;
    if (d == null) return;
    _draft = change(d);
    update();
  }

  /// Vehicle types: the last enabled one cannot be switched off (the model's
  /// validation also rejects an empty set, for drafts built any other way).
  void toggleVehicle(VehicleType type, bool enabled) => edit((d) {
        final next = {...d.enabledVehicleTypes};
        if (enabled) {
          next.add(type);
        } else if (next.length > 1) {
          next.remove(type);
        }
        return d.copyWith(enabledVehicleTypes: next);
      });

  void discard() {
    _draft = _saved;
    update();
  }

  /// Returns null on success, else a translated error. Invalid drafts never
  /// reach the repository.
  Future<String?> save() async {
    final d = _draft;
    if (d == null || _isSaving) return 'action_failed'.tr;
    if (!isValid) return 'fix_errors_first'.tr;
    _isSaving = true;
    update();
    String? error;
    try {
      _saved = await settingsRepoInterface.saveSettings(d);
      _draft = _saved;
    } catch (e) {
      log('Failed to save settings: $e');
      error = 'action_failed'.tr;
    }
    _isSaving = false;
    update();
    return error;
  }
}
