import 'package:appwrite_boilerplate/app/helper/mock_admin_store.dart';
import 'package:appwrite_boilerplate/app/models/admin_stats_model.dart';
import 'package:appwrite_boilerplate/app/models/booking_model.dart';
import 'package:appwrite_boilerplate/app/models/driver_profile_model.dart';
import 'package:appwrite_boilerplate/app/modules/bookings/domain/repository/booking_repository.dart';
import 'package:appwrite_boilerplate/app/modules/dashboard/domain/repository/dashboard_repo_interface.dart';

class DashboardRepository implements DashboardRepoInterface {
  final MockAdminStore store;
  final Duration tick;

  DashboardRepository({required this.store, this.tick = const Duration(milliseconds: 500)});

  @override
  Future<AdminStatsModel> getStats() async {
    await Future<void>.delayed(tick);
    final today = DateTime(store.now.year, store.now.month, store.now.day);
    return AdminStatsModel(
      passengers: store.passengers.length,
      drivers: store.drivers.length,
      onlineDrivers: store.drivers
          .where((d) =>
              d.isActive &&
              d.verificationStatus == VerificationStatus.approved &&
              d.availabilityStatus == AvailabilityStatus.online)
          .length,
      activeBookings: store.bookings.where((b) => b.status.isActive).length,
      completedToday: store.bookings
          .where((b) =>
              b.status == BookingStatus.completed &&
              !b.createdAt.isBefore(today))
          .length,
      last7Days: await BookingRepository(store: store, tick: Duration.zero)
          .getDailyCounts(7),
    );
  }
}
