import 'package:appwrite_boilerplate/app/common/widgets/admin_card.dart';
import 'package:appwrite_boilerplate/app/helper/admin_format.dart';
import 'package:appwrite_boilerplate/app/helper/routes/app_router.dart';
import 'package:appwrite_boilerplate/app/models/booking_model.dart';
import 'package:appwrite_boilerplate/app/models/driver_profile_model.dart';
import 'package:appwrite_boilerplate/app/resources/colors.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:appwrite_boilerplate/app/resources/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

/// Drivers waiting for document verification, with a link to review each.
class PendingDriversCard extends StatelessWidget {
  final List<DriverProfileModel> drivers;
  final int total;

  const PendingDriversCard({super.key, required this.drivers, required this.total});

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      title: 'pending_verifications'.tr,
      trailing: TextButton(
        onPressed: () => context.go(AppRouter.drivers),
        child: Text('view_all'.trParams({'count': '$total'})),
      ),
      child: drivers.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(Constants.paddingSizeDefault),
              child: Text('no_pending_verifications'.tr,
                  style: poppinsRegular.copyWith(color: context.textSecondary)),
            )
          : Column(
              children: [
                for (final d in drivers)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor:
                          ColorResource.primaryDark.withValues(alpha: 0.1),
                      child: Icon(
                          d.vehicleType == VehicleType.cng
                              ? Icons.electric_rickshaw_rounded
                              : Icons.directions_car_rounded,
                          color: ColorResource.primaryDark),
                    ),
                    title: Text(d.name,
                        style: poppinsMedium.copyWith(color: context.textPrimary)),
                    subtitle: Text('${vehicleLabel(d.vehicleType)} · ${d.registration}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: poppinsRegular.copyWith(
                            fontSize: Constants.fontSizeSmall,
                            color: context.textSecondary)),
                    trailing: TextButton(
                      onPressed: () => context.goNamed(RouteNames.driverDetail,
                          pathParameters: {'id': d.id}),
                      child: Text('review'.tr),
                    ),
                  ),
              ],
            ),
    );
  }
}
