import 'package:appwrite_boilerplate/app/common/widgets/admin_table.dart';
import 'package:appwrite_boilerplate/app/common/widgets/status_chip.dart';
import 'package:appwrite_boilerplate/app/helper/admin_format.dart';
import 'package:appwrite_boilerplate/app/helper/routes/app_router.dart';
import 'package:appwrite_boilerplate/app/models/driver_profile_model.dart';
import 'package:appwrite_boilerplate/app/resources/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class DriversTable extends StatelessWidget {
  final List<DriverProfileModel> drivers;

  const DriversTable({super.key, required this.drivers});

  @override
  Widget build(BuildContext context) {
    return AdminTable(
      columns: [
        AdminColumn('name'.tr, 170),
        AdminColumn('phone'.tr, 150),
        AdminColumn('vehicle'.tr, 200),
        AdminColumn('verification'.tr, 130),
        AdminColumn('availability'.tr, 120),
        AdminColumn('account'.tr, 110),
        AdminColumn('trips'.tr, 70),
      ],
      rows: [
        for (final d in drivers)
          AdminTableRow(
            onTap: () => context.goNamed(RouteNames.driverDetail,
                pathParameters: {'id': d.id}),
            cells: [
              CellText(d.name, bold: true),
              CellText(d.phone, color: context.textSecondary),
              CellText('${vehicleLabel(d.vehicleType)} · ${d.registration}'),
              StatusChip(
                  label: verificationLabel(d.verificationStatus),
                  color: verificationColor(d.verificationStatus)),
              StatusChip(
                  label: availabilityLabel(d.availabilityStatus),
                  color: availabilityColor(d.availabilityStatus)),
              StatusChip(label: accountLabel(d.isActive), color: accountColor(d.isActive)),
              CellText('${d.tripCount}'),
            ],
          ),
      ],
    );
  }
}
