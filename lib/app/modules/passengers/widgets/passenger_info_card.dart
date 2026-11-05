import 'package:appwrite_boilerplate/app/common/widgets/admin_card.dart';
import 'package:appwrite_boilerplate/app/common/widgets/status_chip.dart';
import 'package:appwrite_boilerplate/app/helper/admin_format.dart';
import 'package:appwrite_boilerplate/app/models/passenger_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PassengerInfoCard extends StatelessWidget {
  final PassengerModel passenger;

  const PassengerInfoCard({super.key, required this.passenger});

  @override
  Widget build(BuildContext context) {
    final p = passenger;
    return AdminCard(
      title: p.name,
      trailing: StatusChip(label: accountLabel(p.isActive), color: accountColor(p.isActive)),
      child: Column(
        children: [
          InfoRow(label: 'phone'.tr, value: p.phone),
          InfoRow(label: 'email'.tr, value: p.email),
          InfoRow(label: 'trip_count'.tr, value: '${p.tripCount}'),
          InfoRow(label: 'joined'.tr, value: fmtDate(p.joinedAt)),
          if (!p.isActive) InfoRow(label: 'reason'.tr, value: p.suspensionReason),
        ],
      ),
    );
  }
}
