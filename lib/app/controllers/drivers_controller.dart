import 'dart:developer';

import 'package:appwrite_boilerplate/app/controllers/paged_list_controller.dart';
import 'package:appwrite_boilerplate/app/models/driver_profile_model.dart';
import 'package:appwrite_boilerplate/app/models/page_result.dart';
import 'package:appwrite_boilerplate/app/modules/drivers/domain/repository/driver_repo_interface.dart';
import 'package:get/get.dart';

class DriversController extends PagedListController<DriverProfileModel> {
  final DriverRepoInterface driverRepoInterface;

  DriversController({required this.driverRepoInterface});

  // ── List filters ──
  String _query = '';
  String get query => _query;
  VerificationStatus? _verification;
  VerificationStatus? get verification => _verification;
  AvailabilityStatus? _availability;
  AvailabilityStatus? get availability => _availability;

  @override
  Future<PageResult<DriverProfileModel>> fetchPage(int offset, int limit) =>
      driverRepoInterface.getDrivers(
        query: _query,
        verification: _verification,
        availability: _availability,
        offset: offset,
        limit: limit,
      );

  void setQuery(String v) {
    if (v == _query) return;
    _query = v;
    load();
  }

  void setVerification(VerificationStatus? v) {
    _verification = v;
    load();
  }

  void setAvailability(AvailabilityStatus? v) {
    _availability = v;
    load();
  }

  // ── Detail ──
  DriverProfileModel? _driver;
  DriverProfileModel? get driver => _driver;
  bool _detailLoading = false;
  bool get detailLoading => _detailLoading;
  String? _detailError;
  String? get detailError => _detailError;
  bool _isActing = false;
  bool get isActing => _isActing;

  Future<void> loadDriver(String id) async {
    _detailLoading = true;
    _detailError = null;
    _driver = null;
    update();
    try {
      _driver = await driverRepoInterface.getDriver(id);
      if (_driver == null) _detailError = 'driver_not_found'.tr;
    } catch (e) {
      log('Failed to load driver: $e');
      _detailError = 'failed_to_load_data'.tr;
    }
    _detailLoading = false;
    update();
  }

  // ── Actions: each returns null on success, else a translated error. ──

  Future<String?> approve() => _act((id) => driverRepoInterface.approveDriver(id));

  Future<String?> reject(String reason) =>
      _act((id) => driverRepoInterface.rejectDriver(id, reason.trim()), reason: reason);

  Future<String?> setSuspended(bool suspended, String reason) => _act(
        (id) => driverRepoInterface.setDriverSuspended(id,
            suspended: suspended, reason: reason.trim()),
        reason: reason,
      );

  /// [reason] non-null means the action requires one (checked here, not just
  /// in the dialog, so no caller can skip it).
  Future<String?> _act(
    Future<DriverProfileModel> Function(String id) run, {
    String? reason,
  }) async {
    final d = _driver;
    if (d == null || _isActing) return 'action_failed'.tr;
    if (reason != null && reason.trim().isEmpty) return 'reason_required'.tr;
    _isActing = true;
    update();
    String? error;
    try {
      _driver = await run(d.id);
      final i = items.indexWhere((x) => x.id == d.id);
      if (i >= 0) items[i] = _driver!;
    } catch (e) {
      log('Driver action failed: $e');
      error = 'action_failed'.tr;
    }
    _isActing = false;
    update();
    return error;
  }
}
