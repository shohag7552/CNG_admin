import 'package:appwrite_boilerplate/app/common/widgets/admin_page.dart';
import 'package:appwrite_boilerplate/app/common/widgets/state_views.dart';
import 'package:appwrite_boilerplate/app/common/widgets/web_top_nav.dart';
import 'package:appwrite_boilerplate/app/controllers/bookings_controller.dart';
import 'package:appwrite_boilerplate/app/helper/routes/app_router.dart';
import 'package:appwrite_boilerplate/app/modules/bookings/widgets/assigned_driver_card.dart';
import 'package:appwrite_boilerplate/app/modules/bookings/widgets/booking_actions_card.dart';
import 'package:appwrite_boilerplate/app/modules/bookings/widgets/booking_summary_card.dart';
import 'package:appwrite_boilerplate/app/modules/bookings/widgets/offers_card.dart';
import 'package:appwrite_boilerplate/app/modules/bookings/widgets/status_timeline.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Booking detail; the Trips pages reuse it ([fromTrips] only changes the
/// back link).
class BookingDetailScreen extends StatefulWidget {
  final String id;
  final bool fromTrips;

  const BookingDetailScreen({super.key, required this.id, this.fromTrips = false});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final BookingsController _c = Get.find<BookingsController>();

  @override
  void initState() {
    super.initState();
    _c.loadBooking(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= WebTopNav.wideBreakpoint;
    const gap = SizedBox(height: Constants.paddingSizeLarge);
    return GetBuilder<BookingsController>(builder: (c) {
      final b = c.booking;
      return AdminPage(children: [
        BackLink(
          path: widget.fromTrips ? AppRouter.trips : AppRouter.bookings,
          labelKey: widget.fromTrips ? 'back_to_trips' : 'back_to_bookings',
        ),
        AsyncStateView(
          isLoading: c.detailLoading,
          error: c.detailError,
          isEmpty: b == null,
          onRetry: () => c.loadBooking(widget.id),
          emptyIcon: Icons.receipt_long_rounded,
          emptyTitle: 'booking_not_found'.tr,
          skeletonRows: 8,
          child: b == null
              ? const SizedBox.shrink()
              : () {
                  final main = Column(children: [
                    BookingSummaryCard(booking: b),
                    gap,
                    OffersCard(offers: c.offers),
                  ]);
                  final side = Column(children: [
                    BookingActionsCard(booking: b, busy: c.isActing),
                    gap,
                    AssignedDriverCard(booking: b),
                    gap,
                    StatusTimeline(events: b.events),
                  ]);
                  return wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: main),
                            const SizedBox(width: Constants.paddingSizeLarge),
                            SizedBox(width: Constants.sidePanelWidth, child: side),
                          ],
                        )
                      : Column(children: [side, gap, main]);
                }(),
        ),
      ]);
    });
  }
}
