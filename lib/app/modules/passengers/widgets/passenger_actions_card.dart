import 'package:appwrite_boilerplate/app/common/widgets/admin_card.dart';
import 'package:appwrite_boilerplate/app/common/widgets/admin_dialogs.dart';
import 'package:appwrite_boilerplate/app/common/widgets/custom_toster.dart';
import 'package:appwrite_boilerplate/app/controllers/passengers_controller.dart';
import 'package:appwrite_boilerplate/app/models/passenger_model.dart';
import 'package:appwrite_boilerplate/app/resources/colors.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:appwrite_boilerplate/app/resources/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Suspend / reactivate with a mandatory, audited reason.
class PassengerActionsCard extends StatelessWidget {
  final PassengerModel passenger;
  final bool busy;

  const PassengerActionsCard({super.key, required this.passenger, required this.busy});

  Future<void> _toggle(BuildContext context, bool suspend) async {
    final reason = await showReasonDialog(context,
        title: (suspend ? 'suspend_passenger_title' : 'reactivate_passenger_title').tr,
        message: (suspend ? 'suspend_passenger_desc' : 'reactivate_passenger_desc').tr,
        confirmLabel: (suspend ? 'suspend' : 'reactivate').tr,
        destructive: suspend);
    if (reason == null) return;
    final error = await Get.find<PassengersController>().setSuspended(suspend, reason);
    customToster(
        error ?? (suspend ? 'passenger_suspended_toast' : 'passenger_reactivated_toast').tr,
        isSuccess: error == null);
  }

  @override
  Widget build(BuildContext context) {
    final active = passenger.isActive;
    return AdminCard(
      title: 'admin_actions'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (active)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: ColorResource.error),
              onPressed: busy ? null : () => _toggle(context, true),
              icon: const Icon(Icons.block_rounded),
              label: Text('suspend'.tr),
            )
          else
            FilledButton.icon(
              onPressed: busy ? null : () => _toggle(context, false),
              icon: const Icon(Icons.restart_alt_rounded),
              label: Text('reactivate'.tr),
            ),
          const SizedBox(height: Constants.paddingSizeSmall),
          Text('actions_audited_hint'.tr,
              style: poppinsRegular.copyWith(
                  fontSize: Constants.fontSizeSmall, color: context.textLight)),
        ],
      ),
    );
  }
}
