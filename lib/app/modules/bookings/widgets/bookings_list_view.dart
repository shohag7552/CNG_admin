import 'package:appwrite_boilerplate/app/common/widgets/admin_page.dart';
import 'package:appwrite_boilerplate/app/common/widgets/admin_table.dart';
import 'package:appwrite_boilerplate/app/common/widgets/bookings_table.dart';
import 'package:appwrite_boilerplate/app/common/widgets/state_views.dart';
import 'package:appwrite_boilerplate/app/controllers/bookings_controller.dart';
import 'package:appwrite_boilerplate/app/models/booking_model.dart';
import 'package:appwrite_boilerplate/app/modules/bookings/widgets/booking_filters.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Filterable, paged bookings table. Bookings and Trips are this view bound to
/// [BookingsController] and [TripsController] respectively.
class BookingsListView<T extends BookingsController> extends StatefulWidget {
  final bool fromTrips;
  final List<BookingStatus> statusOptions;
  final String emptyTitleKey;

  const BookingsListView({
    super.key,
    required this.fromTrips,
    required this.statusOptions,
    required this.emptyTitleKey,
  });

  @override
  State<BookingsListView<T>> createState() => _BookingsListViewState<T>();
}

class _BookingsListViewState<T extends BookingsController>
    extends State<BookingsListView<T>> {
  final T _c = Get.find<T>();

  @override
  void initState() {
    super.initState();
    _c.load();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<T>(builder: (c) {
      return AdminPage(children: [
        BookingFilters(controller: c, statusOptions: widget.statusOptions),
        const SizedBox(height: Constants.paddingSizeLarge),
        AsyncStateView(
          isLoading: c.isLoading,
          error: c.errorMessage,
          isEmpty: c.items.isEmpty,
          onRetry: c.load,
          emptyIcon: Icons.receipt_long_rounded,
          emptyTitle: widget.emptyTitleKey.tr,
          emptySub: 'no_results_desc'.tr,
          child: Column(children: [
            BookingsTable(bookings: c.items, fromTrips: widget.fromTrips),
            LoadMoreBar(
              shown: c.items.length,
              total: c.total,
              hasMore: c.hasMore,
              isLoadingMore: c.isLoadingMore,
              onLoadMore: c.loadMore,
            ),
          ]),
        ),
      ]);
    });
  }
}
