import 'dart:developer';

import 'package:appwrite_boilerplate/app/models/admin_stats_model.dart';
import 'package:appwrite_boilerplate/app/modules/bookings/domain/repository/booking_repo_interface.dart';
import 'package:get/get.dart';

class ReportsController extends GetxController implements GetxService {
  final BookingRepoInterface bookingRepoInterface;

  ReportsController({required this.bookingRepoInterface});

  int _days = 7;
  int get days => _days;
  List<DailyBookingsModel> _daily = [];
  List<DailyBookingsModel> get daily => _daily;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int get totalBookings => _daily.fold(0, (a, d) => a + d.total);
  int get totalCompleted => _daily.fold(0, (a, d) => a + d.completed);
  int get totalCancelled => _daily.fold(0, (a, d) => a + d.cancelled);

  /// 0..1; 0 when there were no bookings.
  double get completionRate => totalBookings == 0 ? 0 : totalCompleted / totalBookings;
  double get cancellationRate => totalBookings == 0 ? 0 : totalCancelled / totalBookings;

  Future<void> load([int? days]) async {
    if (days != null) _days = days;
    _isLoading = true;
    _errorMessage = null;
    update();
    try {
      _daily = await bookingRepoInterface.getDailyCounts(_days);
    } catch (e) {
      log('Failed to load reports: $e');
      _daily = [];
      _errorMessage = 'failed_to_load_data'.tr;
    }
    _isLoading = false;
    update();
  }
}
