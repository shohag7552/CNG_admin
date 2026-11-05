import 'package:appwrite_boilerplate/app/common/widgets/admin_card.dart';
import 'package:appwrite_boilerplate/app/common/widgets/admin_dialogs.dart';
import 'package:appwrite_boilerplate/app/common/widgets/custom_toster.dart';
import 'package:appwrite_boilerplate/app/common/widgets/status_chip.dart';
import 'package:appwrite_boilerplate/app/controllers/drivers_controller.dart';
import 'package:appwrite_boilerplate/app/models/driver_profile_model.dart';
import 'package:appwrite_boilerplate/app/resources/colors.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:appwrite_boilerplate/app/resources/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Verification (approve / reject) and account (suspend / reactivate) actions.
/// These are the only things an admin can change on a driver; each goes
/// through [DriversController] and is audited.
class DriverActionsCard extends StatelessWidget {
  final DriverProfileModel driver;
  final bool busy;

  const DriverActionsCard({super.key, required this.driver, required this.busy});

  Future<void> _report(Future<String?> action, String successKey) async {
    final error = await action;
    customToster(error ?? successKey.tr, isSuccess: error == null);
  }

  Future<void> _approve(BuildContext context, DriversController c) async {
    final ok = await showConfirmDialog(context,
        title: 'approve_driver_title'.tr,
        message: 'approve_driver_desc'.tr,
        confirmLabel: 'approve'.tr);
    if (ok) await _report(c.approve(), 'driver_approved_toast');
  }

  Future<void> _reject(BuildContext context, DriversController c) async {
    final reason = await showReasonDialog(context,
        title: 'reject_driver_title'.tr,
        message: 'reject_driver_desc'.tr,
        confirmLabel: 'reject'.tr);
    if (reason != null) await _report(c.reject(reason), 'driver_rejected_toast');
  }

  Future<void> _suspend(BuildContext context, DriversController c, bool suspend) async {
    final reason = await showReasonDialog(context,
        title: (suspend ? 'suspend_driver_title' : 'reactivate_driver_title').tr,
        message: (suspend ? 'suspend_driver_desc' : 'reactivate_driver_desc').tr,
        confirmLabel: (suspend ? 'suspend' : 'reactivate').tr,
        destructive: suspend);
    if (reason != null) {
      await _report(c.setSuspended(suspend, reason),
          suspend ? 'driver_suspended_toast' : 'driver_reactivated_toast');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DriversController>();
    final d = driver;
    final verification = d.verificationStatus;
    return AdminCard(
      title: 'admin_actions'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(context, 'verification'.tr),
          StatusChip(label: verificationLabel(verification), color: verificationColor(verification)),
          if (d.rejectionReason != null && verification == VerificationStatus.rejected)
            _note(context, '${'reason'.tr}: ${d.rejectionReason}'),
          const SizedBox(height: Constants.paddingSizeSmall),
          if (verification != VerificationStatus.approved)
            Wrap(
              spacing: Constants.paddingSizeSmall,
              runSpacing: Constants.paddingSizeSmall,
              children: [
                FilledButton.icon(
                  onPressed: busy ? null : () => _approve(context, c),
                  icon: const Icon(Icons.check_rounded),
                  label: Text('approve'.tr),
                ),
                if (verification == VerificationStatus.pending)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(foregroundColor: ColorResource.error),
                    onPressed: busy ? null : () => _reject(context, c),
                    icon: const Icon(Icons.close_rounded),
                    label: Text('reject'.tr),
                  ),
              ],
            ),
          const Divider(height: Constants.spaceSection),
          _label(context, 'account'.tr),
          StatusChip(label: accountLabel(d.isActive), color: accountColor(d.isActive)),
          if (!d.isActive && d.suspensionReason != null)
            _note(context, '${'reason'.tr}: ${d.suspensionReason}'),
          const SizedBox(height: Constants.paddingSizeSmall),
          if (d.isActive)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: ColorResource.error),
              onPressed: busy ? null : () => _suspend(context, c, true),
              icon: const Icon(Icons.block_rounded),
              label: Text('suspend'.tr),
            )
          else
            FilledButton.icon(
              onPressed: busy ? null : () => _suspend(context, c, false),
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

  Widget _label(BuildContext context, String t) => Padding(
        padding: const EdgeInsets.only(bottom: Constants.paddingSizeExtraSmall),
        child: Text(t,
            style: poppinsMedium.copyWith(color: context.textSecondary)),
      );

  Widget _note(BuildContext context, String t) => Padding(
        padding: const EdgeInsets.only(top: Constants.paddingSizeExtraSmall),
        child: Text(t, style: poppinsRegular.copyWith(color: context.textSecondary)),
      );
}
