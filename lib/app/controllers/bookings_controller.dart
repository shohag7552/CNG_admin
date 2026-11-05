import 'dart:developer';

import 'package:appwrite_boilerplate/app/controllers/paged_list_controller.dart';
import 'package:appwrite_boilerplate/app/models/booking_model.dart';
import 'package:appwrite_boilerplate/app/models/offer_model.dart';
import 'package:appwrite_boilerplate/app/models/page_result.dart';
import 'package:appwrite_boilerplate/app/modules/bookings/domain/repository/booking_repo_interface.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:get/get.dart';

/// All bookings (filterable). Trips use [TripsController], which only narrows
/// the status set; both share the detail/cancel logic via this class.
class BookingsController extends PagedListController<BookingModel> {
  final BookingRepoInterface bookingRepoInterface;

  BookingsController({required this.bookingRepoInterface});

  /// Statuses the list is restricted to when the user has picked none.
  Set<BookingStatus> get baseStatuses => const {};

  String _query = '';
  String get query => _query;
  Set<BookingStatus> _statuses = {};
  Set<BookingStatus> get statuses => _statuses;
  DateTimeRange? _range;
  DateTimeRange? get range => _range;
  VehicleType? _vehicleType;
  VehicleType? get vehicleType => _vehicleType;

  @override
  Future<PageResult<BookingModel>> fetchPage(int offset, int limit) =>
      bookingRepoInterface.getBookings(
        query: _query,
        statuses: _statuses.isEmpty ? baseStatuses : _statuses,
        from: _range?.start,
        to: _range?.end,
        vehicleType: _vehicleType,
        offset: offset,
        limit: limit,
      );

  void setQuery(String v) {
    if (v == _query) return;
    _query = v;
    load();
  }

  /// Chips are single-select; null clears the filter.
  void setStatus(BookingStatus? s) {
    _statuses = s == null ? {} : {s};
    load();
  }

  void setRange(DateTimeRange? r) {
    _range = r;
    load();
  }

  void setVehicleType(VehicleType? v) {
    _vehicleType = v;
    load();
  }

  // ── Detail ──
  BookingModel? _booking;
  BookingModel? get booking => _booking;
  List<OfferModel> _offers = [];
  List<OfferModel> get offers => _offers;
  bool _detailLoading = false;
  bool get detailLoading => _detailLoading;
  String? _detailError;
  String? get detailError => _detailError;
  bool _isActing = false;
  bool get isActing => _isActing;

  Future<void> loadBooking(String id) async {
    _detailLoading = true;
    _detailError = null;
    _booking = null;
    _offers = [];
    update();
    try {
      _booking = await bookingRepoInterface.getBooking(id);
      if (_booking == null) {
        _detailError = 'booking_not_found'.tr;
      } else {
        _offers = await bookingRepoInterface.getOffers(id);
      }
    } catch (e) {
      log('Failed to load booking: $e');
      _detailError = 'failed_to_load_data'.tr;
    }
    _detailLoading = false;
    update();
  }

  /// Returns null on success, else a translated error. A reason is mandatory.
  Future<String?> cancelBooking(String reason) async {
    final b = _booking;
    if (b == null || _isActing) return 'action_failed'.tr;
    if (reason.trim().isEmpty) return 'reason_required'.tr;
    if (!b.status.isActive) return 'action_failed'.tr;
    _isActing = true;
    update();
    String? error;
    try {
      _booking = await bookingRepoInterface.cancelBooking(b.id, reason.trim());
      final i = items.indexWhere((x) => x.id == b.id);
      if (i >= 0) items[i] = _booking!;
    } catch (e) {
      log('Cancel booking failed: $e');
      error = 'action_failed'.tr;
    }
    _isActing = false;
    update();
    return error;
  }
}

/// Bookings that reached a driver assignment, plus cancelled ones.
class TripsController extends BookingsController {
  TripsController({required super.bookingRepoInterface});

  @override
  Set<BookingStatus> get baseStatuses => const {
        BookingStatus.confirmed,
        BookingStatus.driverArriving,
        BookingStatus.inProgress,
        BookingStatus.completed,
        BookingStatus.cancelled,
      };
}
