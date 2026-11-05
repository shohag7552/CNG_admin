import 'package:appwrite_boilerplate/app/common/widgets/admin_table.dart';
import 'package:appwrite_boilerplate/app/common/widgets/status_chip.dart';
import 'package:appwrite_boilerplate/app/helper/admin_format.dart';
import 'package:appwrite_boilerplate/app/helper/routes/app_router.dart';
import 'package:appwrite_boilerplate/app/models/passenger_model.dart';
import 'package:appwrite_boilerplate/app/resources/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class PassengersTable extends StatelessWidget {
  final List<PassengerModel> passengers;

  const PassengersTable({super.key, required this.passengers});

  @override
  Widget build(BuildContext context) {
    return AdminTable(
      columns: [
        AdminColumn('name'.tr, 180),
        AdminColumn('phone'.tr, 150),
        AdminColumn('email'.tr, 220),
        AdminColumn('trips'.tr, 70),
        AdminColumn('joined'.tr, 130),
        AdminColumn('account'.tr, 110),
      ],
      rows: [
        for (final p in passengers)
          AdminTableRow(
            onTap: () => context.goNamed(RouteNames.passengerDetail,
                pathParameters: {'id': p.id}),
            cells: [
              CellText(p.name, bold: true),
              CellText(p.phone, color: context.textSecondary),
              CellText(p.email, color: context.textSecondary),
              CellText('${p.tripCount}'),
              CellText(fmtDate(p.joinedAt), color: context.textSecondary),
              StatusChip(label: accountLabel(p.isActive), color: accountColor(p.isActive)),
            ],
          ),
      ],
    );
  }
}
