import 'package:appwrite_boilerplate/app/common/widgets/admin_card.dart';
import 'package:appwrite_boilerplate/app/common/widgets/admin_dialogs.dart';
import 'package:appwrite_boilerplate/app/common/widgets/custom_toster.dart';
import 'package:appwrite_boilerplate/app/controllers/bookings_controller.dart';
import 'package:appwrite_boilerplate/app/models/booking_model.dart';
import 'package:appwrite_boilerplate/app/resources/colors.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:appwrite_boilerplate/app/resources/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Admin override for a stuck or disputed booking: cancel with a reason.
class BookingActionsCard extends StatelessWidget {
  final BookingModel booking;
  final bool busy;

  const BookingActionsCard({super.key, required this.booking, required this.busy});

  Future<void> _cancel(BuildContext context) async {
    final reason = await showReasonDialog(context,
        title: 'cancel_booking_title'.tr,
        message: 'cancel_booking_desc'.tr,
        confirmLabel: 'cancel_booking'.tr);
    if (reason == null) return;
    final error = await Get.find<BookingsController>().cancelBooking(reason);
    customToster(error ?? 'booking_cancelled_toast'.tr, isSuccess: error == null);
  }

  @override
  Widget build(BuildContext context) {
    final cancellable = booking.status.isActive;
    return AdminCard(
      title: 'admin_actions'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (cancellable)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: ColorResource.error),
              onPressed: busy ? null : () => _cancel(context),
              icon: const Icon(Icons.cancel_outlined),
              label: Text('cancel_resolve_booking'.tr),
            )
          else
            Text('booking_closed_hint'.tr,
                style: poppinsRegular.copyWith(color: context.textSecondary)),
          const SizedBox(height: Constants.paddingSizeSmall),
          Text('actions_audited_hint'.tr,
              style: poppinsRegular.copyWith(
                  fontSize: Constants.fontSizeSmall, color: context.textLight)),
        ],
      ),
    );
  }
}
