import 'package:appwrite_boilerplate/app/common/widgets/admin_filters.dart';
import 'package:appwrite_boilerplate/app/common/widgets/status_chip.dart';
import 'package:appwrite_boilerplate/app/controllers/bookings_controller.dart';
import 'package:appwrite_boilerplate/app/helper/admin_format.dart';
import 'package:appwrite_boilerplate/app/models/booking_model.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Search, status chips, date range and vehicle filters for bookings/trips.
class BookingFilters extends StatelessWidget {
  final BookingsController controller;
  final List<BookingStatus> statusOptions;

  const BookingFilters({super.key, required this.controller, required this.statusOptions});

  Future<void> _pickRange(BuildContext context) async {
    final now = DateTime.now();
    final r = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
      initialDateRange: controller.range,
    );
    if (r != null) controller.setRange(r);
  }

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final range = c.range;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: Constants.paddingSizeDefault,
          runSpacing: Constants.paddingSizeDefault,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SearchField(hint: 'search_bookings_hint'.tr, onChanged: c.setQuery),
            FilterDropdown<VehicleType>(
              label: 'vehicle'.tr,
              value: c.vehicleType,
              options: [for (final v in VehicleType.values) (v, vehicleLabel(v))],
              onChanged: c.setVehicleType,
            ),
            OutlinedButton.icon(
              onPressed: () => _pickRange(context),
              icon: const Icon(Icons.date_range_rounded),
              label: Text(range == null
                  ? 'date_range'.tr
                  : '${fmtDate(range.start)} – ${fmtDate(range.end)}'),
            ),
            if (range != null)
              IconButton(
                tooltip: 'clear'.tr,
                icon: const Icon(Icons.close_rounded),
                onPressed: () => c.setRange(null),
              ),
          ],
        ),
        const SizedBox(height: Constants.paddingSizeDefault),
        FilterChips<BookingStatus>(
          value: c.statuses.firstOrNull,
          options: [for (final s in statusOptions) (s, bookingStatusLabel(s))],
          onChanged: c.setStatus,
        ),
      ],
    );
  }
}
