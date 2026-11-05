import 'dart:developer';

import 'package:appwrite_boilerplate/app/controllers/paged_list_controller.dart';
import 'package:appwrite_boilerplate/app/models/page_result.dart';
import 'package:appwrite_boilerplate/app/models/passenger_model.dart';
import 'package:appwrite_boilerplate/app/modules/passengers/domain/repository/passenger_repo_interface.dart';
import 'package:get/get.dart';

class PassengersController extends PagedListController<PassengerModel> {
  final PassengerRepoInterface passengerRepoInterface;

  PassengersController({required this.passengerRepoInterface});

  String _query = '';
  String get query => _query;

  /// null = all, true = active, false = suspended.
  bool? _isActive;
  bool? get isActiveFilter => _isActive;

  @override
  Future<PageResult<PassengerModel>> fetchPage(int offset, int limit) =>
      passengerRepoInterface.getPassengers(
        query: _query,
        isActive: _isActive,
        offset: offset,
        limit: limit,
      );

  void setQuery(String v) {
    if (v == _query) return;
    _query = v;
    load();
  }

  void setActiveFilter(bool? v) {
    _isActive = v;
    load();
  }

  // ── Detail ──
  PassengerModel? _passenger;
  PassengerModel? get passenger => _passenger;
  bool _detailLoading = false;
  bool get detailLoading => _detailLoading;
  String? _detailError;
  String? get detailError => _detailError;
  bool _isActing = false;
  bool get isActing => _isActing;

  Future<void> loadPassenger(String id) async {
    _detailLoading = true;
    _detailError = null;
    _passenger = null;
    update();
    try {
      _passenger = await passengerRepoInterface.getPassenger(id);
      if (_passenger == null) _detailError = 'passenger_not_found'.tr;
    } catch (e) {
      log('Failed to load passenger: $e');
      _detailError = 'failed_to_load_data'.tr;
    }
    _detailLoading = false;
    update();
  }

  /// Returns null on success, else a translated error. A reason is mandatory.
  Future<String?> setSuspended(bool suspended, String reason) async {
    final p = _passenger;
    if (p == null || _isActing) return 'action_failed'.tr;
    if (reason.trim().isEmpty) return 'reason_required'.tr;
    _isActing = true;
    update();
    String? error;
    try {
      _passenger = await passengerRepoInterface.setPassengerSuspended(p.id,
          suspended: suspended, reason: reason.trim());
      final i = items.indexWhere((x) => x.id == p.id);
      if (i >= 0) items[i] = _passenger!;
    } catch (e) {
      log('Passenger action failed: $e');
      error = 'action_failed'.tr;
    }
    _isActing = false;
    update();
    return error;
  }
}
