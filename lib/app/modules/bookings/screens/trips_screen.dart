import 'package:appwrite_boilerplate/app/controllers/bookings_controller.dart';
import 'package:appwrite_boilerplate/app/models/booking_model.dart';
import 'package:appwrite_boilerplate/app/modules/bookings/widgets/bookings_list_view.dart';
import 'package:flutter/widgets.dart';

/// Trips: bookings that have (or had) a driver assigned, plus cancelled ones.
class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) => const BookingsListView<TripsController>(
        fromTrips: true,
        statusOptions: [
          BookingStatus.confirmed,
          BookingStatus.driverArriving,
          BookingStatus.inProgress,
          BookingStatus.completed,
          BookingStatus.cancelled,
        ],
        emptyTitleKey: 'no_trips_found',
      );
}
