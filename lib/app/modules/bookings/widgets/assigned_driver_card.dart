import 'package:appwrite_boilerplate/app/common/widgets/admin_card.dart';
import 'package:appwrite_boilerplate/app/helper/routes/app_router.dart';
import 'package:appwrite_boilerplate/app/models/booking_model.dart';
import 'package:appwrite_boilerplate/app/resources/colors.dart';
import 'package:appwrite_boilerplate/app/resources/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class AssignedDriverCard extends StatelessWidget {
  final BookingModel booking;

  const AssignedDriverCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final b = booking;
    return AdminCard(
      title: 'assigned_driver'.tr,
      child: b.driverId == null
          ? Text('no_driver_assigned'.tr,
              style: poppinsRegular.copyWith(color: context.textSecondary))
          : Column(
              children: [
                InfoRow(
                  label: 'driver'.tr,
                  valueWidget: TextButton(
                    onPressed: () => context.goNamed(RouteNames.driverDetail,
                        pathParameters: {'id': b.driverId!}),
                    child: Text(b.driverName ?? b.driverId!),
                  ),
                ),
                InfoRow(label: 'plate_number'.tr, value: b.vehiclePlate),
              ],
            ),
    );
  }
}
