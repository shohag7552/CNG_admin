import 'package:appwrite_boilerplate/app/common/widgets/admin_card.dart';
import 'package:appwrite_boilerplate/app/common/widgets/status_chip.dart';
import 'package:appwrite_boilerplate/app/helper/admin_format.dart';
import 'package:appwrite_boilerplate/app/models/booking_model.dart';
import 'package:appwrite_boilerplate/app/resources/colors.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:appwrite_boilerplate/app/resources/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StatusTimeline extends StatelessWidget {
  final List<BookingEvent> events;

  const StatusTimeline({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      title: 'status_timeline'.tr,
      child: Column(
        children: [
          for (var i = 0; i < events.length; i++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                      Container(
                        width: Constants.timelineDotSize,
                        height: Constants.timelineDotSize,
                        margin: const EdgeInsets.only(top: Constants.paddingSizeExtraSmall),
                        decoration: BoxDecoration(
                          color: bookingStatusColor(events[i].status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (i < events.length - 1)
                        Expanded(
                            child: Container(
                                width: 2, color: context.textLight.withValues(alpha: 0.3))),
                    ],
                  ),
                  const SizedBox(width: Constants.paddingSizeDefault),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: Constants.paddingSizeDefault),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(bookingStatusLabel(events[i].status),
                              style: poppinsMedium.copyWith(color: context.textPrimary)),
                          Text(fmtDateTime(events[i].at),
                              style: poppinsRegular.copyWith(
                                  fontSize: Constants.fontSizeSmall,
                                  color: context.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
