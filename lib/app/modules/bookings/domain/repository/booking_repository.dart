import 'package:appwrite_boilerplate/app/helper/mock_admin_store.dart';
import 'package:appwrite_boilerplate/app/models/admin_stats_model.dart';
import 'package:appwrite_boilerplate/app/models/audit_log_model.dart';
import 'package:appwrite_boilerplate/app/models/booking_model.dart';
import 'package:appwrite_boilerplate/app/models/offer_model.dart';
import 'package:appwrite_boilerplate/app/models/page_result.dart';
import 'package:appwrite_boilerplate/app/modules/bookings/domain/repository/booking_repo_interface.dart';

class BookingRepository implements BookingRepoInterface {
  final MockAdminStore store;
  final Duration tick;

  BookingRepository({required this.store, this.tick = const Duration(milliseconds: 500)});

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Future<PageResult<BookingModel>> getBookings({
    String query = '',
    Set<BookingStatus> statuses = const {},
    DateTime? from,
    DateTime? to,
    VehicleType? vehicleType,
    required int offset,
    required int limit,
  }) async {
    await Future<void>.delayed(tick);
    final q = query.trim().toLowerCase();
    final start = from == null ? null : _day(from);
    final end = to == null ? null : _day(to).add(const Duration(days: 1));
    final all = store.bookings.where((b) {
      if (statuses.isNotEmpty && !statuses.contains(b.status)) return false;
      if (vehicleType != null && b.vehicleType != vehicleType) return false;
      if (start != null && b.createdAt.isBefore(start)) return false;
      if (end != null && !b.createdAt.isBefore(end)) return false;
      return q.isEmpty ||
          b.id.toLowerCase().contains(q) ||
          b.passengerName.toLowerCase().contains(q) ||
          (b.driverName ?? '').toLowerCase().contains(q) ||
          b.pickup.name.toLowerCase().contains(q) ||
          b.destination.name.toLowerCase().contains(q);
    }).toList();
    return PageResult(all.skip(offset).take(limit).toList(), all.length);
  }

  @override
  Future<BookingModel?> getBooking(String id) async {
    await Future<void>.delayed(tick);
    return store.bookings.where((b) => b.id == id).firstOrNull;
  }

  @override
  Future<List<OfferModel>> getOffers(String bookingId) async {
    await Future<void>.delayed(tick);
    return List.of(store.offers[bookingId] ?? const []);
  }

  @override
  Future<BookingModel> cancelBooking(String id, String reason) async {
    await Future<void>.delayed(tick);
    final i = store.bookings.indexWhere((b) => b.id == id);
    if (i < 0) throw StateError('not_found');
    final b = store.bookings[i];
    if (!b.status.isActive) throw StateError('invalid_transition');
    store.addAudit(AuditAction.bookingCancelled, 'booking', id, reason: reason);
    return store.bookings[i] = b.copyWith(
      status: BookingStatus.cancelled,
      cancelReason: reason,
      events: [...b.events, BookingEvent(BookingStatus.cancelled, DateTime.now())],
    );
  }

  @override
  Future<List<DailyBookingsModel>> getDailyCounts(int days) async {
    await Future<void>.delayed(tick);
    final today = _day(store.now);
    return [
      for (var i = days - 1; i >= 0; i--)
        () {
          final day = today.subtract(Duration(days: i));
          final of = store.bookings.where((b) => _day(b.createdAt) == day);
          return DailyBookingsModel(
            day: day,
            total: of.length,
            completed: of.where((b) => b.status == BookingStatus.completed).length,
            cancelled: of.where((b) => b.status == BookingStatus.cancelled).length,
          );
        }(),
    ];
  }
}
