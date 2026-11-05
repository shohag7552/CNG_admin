import 'dart:developer';

import 'package:appwrite_boilerplate/app/models/admin_stats_model.dart';
import 'package:appwrite_boilerplate/app/models/booking_model.dart';
import 'package:appwrite_boilerplate/app/models/driver_profile_model.dart';
import 'package:appwrite_boilerplate/app/modules/bookings/domain/repository/booking_repo_interface.dart';
import 'package:appwrite_boilerplate/app/modules/dashboard/domain/repository/dashboard_repo_interface.dart';
import 'package:appwrite_boilerplate/app/modules/drivers/domain/repository/driver_repo_interface.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController implements GetxService {
  final DashboardRepoInterface dashboardRepoInterface;
  final DriverRepoInterface driverRepoInterface;
  final BookingRepoInterface bookingRepoInterface;

  DashboardController({
    required this.dashboardRepoInterface,
    required this.driverRepoInterface,
    required this.bookingRepoInterface,
  });

  static const int _previewCount = 5;

  AdminStatsModel? _stats;
  AdminStatsModel? get stats => _stats;
  List<DriverProfileModel> _pendingDrivers = [];
  List<DriverProfileModel> get pendingDrivers => _pendingDrivers;
  int _pendingTotal = 0;
  int get pendingTotal => _pendingTotal;
  List<BookingModel> _activeBookings = [];
  List<BookingModel> get activeBookings => _activeBookings;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    update();
    try {
      _stats = await dashboardRepoInterface.getStats();
      final pending = await driverRepoInterface.getDrivers(
          verification: VerificationStatus.pending, offset: 0, limit: _previewCount);
      _pendingDrivers = pending.items;
      _pendingTotal = pending.total;
      final active = await bookingRepoInterface.getBookings(
          statuses: BookingStatus.values.where((s) => s.isActive).toSet(),
          offset: 0,
          limit: _previewCount);
      _activeBookings = active.items;
    } catch (e) {
      log('Failed to load dashboard: $e');
      _errorMessage = 'failed_to_load_data'.tr;
    }
    _isLoading = false;
    update();
  }
}
