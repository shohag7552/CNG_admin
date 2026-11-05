import 'package:appwrite_boilerplate/app/common/widgets/admin_card.dart';
import 'package:appwrite_boilerplate/app/common/widgets/status_chip.dart';
import 'package:appwrite_boilerplate/app/helper/admin_format.dart';
import 'package:appwrite_boilerplate/app/helper/routes/app_router.dart';
import 'package:appwrite_boilerplate/app/models/booking_model.dart';
import 'package:appwrite_boilerplate/app/modules/bookings/widgets/booking_route_map.dart';
import 'package:appwrite_boilerplate/app/modules/bookings/widgets/route_summary.dart';
import 'package:appwrite_boilerplate/app/resources/colors.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:appwrite_boilerplate/app/resources/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

/// Route, map and the proposed-vs-agreed fare.
class BookingSummaryCard extends StatelessWidget {
  final BookingModel booking;

  const BookingSummaryCard({super.key, required this.booking});

  Widget _fare(BuildContext context, String label, int? amount) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: poppinsRegular.copyWith(
                    fontSize: Constants.fontSizeSmall, color: context.textSecondary)),
            Text(amount == null ? '—' : bdt(amount),
                style: poppinsBold.copyWith(
                    fontSize: Constants.fontSizeOverLarge,
                    color: ColorResource.accentDark)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final b = booking;
    return AdminCard(
      title: b.id,
      trailing: StatusChip(
          label: bookingStatusLabel(b.status), color: bookingStatusColor(b.status)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            _fare(context, 'proposed_fare'.tr, b.proposedFare),
            _fare(context, 'agreed_fare'.tr, b.agreedFare),
          ]),
          const SizedBox(height: Constants.paddingSizeDefault),
          RouteSummary(pickup: b.pickup, destination: b.destination),
          const SizedBox(height: Constants.paddingSizeDefault),
          BookingRouteMap(pickup: b.pickup, destination: b.destination),
          const SizedBox(height: Constants.paddingSizeDefault),
          InfoRow(
            label: 'passenger'.tr,
            valueWidget: TextButton(
              onPressed: () => context.goNamed(RouteNames.passengerDetail,
                  pathParameters: {'id': b.passengerId}),
              child: Text(b.passengerName),
            ),
          ),
          InfoRow(label: 'vehicle'.tr, value: vehicleLabel(b.vehicleType)),
          InfoRow(label: 'created'.tr, value: fmtDateTime(b.createdAt)),
          if (b.cancelReason != null && b.status == BookingStatus.cancelled)
            InfoRow(label: 'cancel_reason'.tr, value: b.cancelReason),
        ],
      ),
    );
  }
}
