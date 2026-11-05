/// Bookings created / finished on one calendar day.
class DailyBookingsModel {
  final DateTime day;
  final int total;
  final int completed;
  final int cancelled;

  const DailyBookingsModel({
    required this.day,
    required this.total,
    required this.completed,
    required this.cancelled,
  });
}

class AdminStatsModel {
  final int passengers;
  final int drivers;
  final int onlineDrivers;
  final int activeBookings;
  final int completedToday;
  final List<DailyBookingsModel> last7Days;

  const AdminStatsModel({
    required this.passengers,
    required this.drivers,
    required this.onlineDrivers,
    required this.activeBookings,
    required this.completedToday,
    required this.last7Days,
  });
}
