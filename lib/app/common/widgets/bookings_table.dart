import 'package:appwrite_boilerplate/app/common/widgets/admin_table.dart';
import 'package:appwrite_boilerplate/app/common/widgets/status_chip.dart';
import 'package:appwrite_boilerplate/app/helper/admin_format.dart';
import 'package:appwrite_boilerplate/app/helper/routes/app_router.dart';
import 'package:appwrite_boilerplate/app/models/booking_model.dart';
import 'package:appwrite_boilerplate/app/resources/colors.dart';
import 'package:appwrite_boilerplate/app/resources/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

/// Bookings/trips table shared by the dashboard, Bookings and Trips pages.
/// A row opens the booking detail under [fromTrips]'s URL space.
class BookingsTable extends StatelessWidget {
  final List<BookingModel> bookings;
  final bool fromTrips;

  const BookingsTable({super.key, required this.bookings, this.fromTrips = false});

  @override
  Widget build(BuildContext context) {
    return AdminTable(
      columns: [
        AdminColumn('booking_id'.tr, 120),
        AdminColumn('passenger'.tr, 160),
        AdminColumn('route'.tr, 240),
        AdminColumn('vehicle'.tr, 80),
        AdminColumn('fare'.tr, 90),
        AdminColumn('status'.tr, 140),
        AdminColumn('created'.tr, 170),
      ],
      rows: [
        for (final b in bookings)
          AdminTableRow(
            onTap: () => context.goNamed(
              fromTrips ? RouteNames.tripDetail : RouteNames.bookingDetail,
              pathParameters: {'id': b.id},
            ),
            cells: [
              CellText(b.id, bold: true),
              CellText(b.passengerName),
              CellText('${b.pickup.name} → ${b.destination.name}'),
              CellText(vehicleLabel(b.vehicleType)),
              Text(bdt(b.displayFare),
                  style: poppinsBold.copyWith(color: ColorResource.accentDark)),
              StatusChip(
                  label: bookingStatusLabel(b.status),
                  color: bookingStatusColor(b.status)),
              CellText(fmtDateTime(b.createdAt), color: context.textSecondary),
            ],
          ),
      ],
    );
  }
}
