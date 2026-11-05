import 'package:appwrite_boilerplate/app/controllers/bookings_controller.dart';
import 'package:appwrite_boilerplate/app/models/booking_model.dart';
import 'package:appwrite_boilerplate/app/modules/bookings/widgets/bookings_list_view.dart';
import 'package:flutter/widgets.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) => const BookingsListView<BookingsController>(
        fromTrips: false,
        statusOptions: BookingStatus.values,
        emptyTitleKey: 'no_bookings_found',
      );
}
