import 'package:appwrite_boilerplate/app/models/admin_stats_model.dart';
import 'package:appwrite_boilerplate/app/models/booking_model.dart';
import 'package:appwrite_boilerplate/app/models/offer_model.dart';
import 'package:appwrite_boilerplate/app/models/page_result.dart';

abstract class BookingRepoInterface {
  /// [statuses] empty = any status. [from]/[to] are inclusive calendar days.
  Future<PageResult<BookingModel>> getBookings({
    String query = '',
    Set<BookingStatus> statuses = const {},
    DateTime? from,
    DateTime? to,
    VehicleType? vehicleType,
    required int offset,
    required int limit,
  });

  Future<BookingModel?> getBooking(String id);

  Future<List<OfferModel>> getOffers(String bookingId);

  /// Admin override of an active booking; audited server-side.
  Future<BookingModel> cancelBooking(String id, String reason);

  /// Bookings per day for the last [days] days, oldest first.
  Future<List<DailyBookingsModel>> getDailyCounts(int days);
}
