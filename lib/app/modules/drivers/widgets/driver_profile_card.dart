import 'package:appwrite_boilerplate/app/common/widgets/admin_card.dart';
import 'package:appwrite_boilerplate/app/common/widgets/status_chip.dart';
import 'package:appwrite_boilerplate/app/helper/admin_format.dart';
import 'package:appwrite_boilerplate/app/models/driver_profile_model.dart';
import 'package:appwrite_boilerplate/app/resources/colors.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:appwrite_boilerplate/app/resources/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DriverProfileCard extends StatelessWidget {
  final DriverProfileModel driver;

  const DriverProfileCard({super.key, required this.driver});

  @override
  Widget build(BuildContext context) {
    final d = driver;
    return Column(
      children: [
        AdminCard(
          child: Row(
            children: [
              CircleAvatar(
                radius: Constants.avatarSize / 2,
                backgroundColor: ColorResource.primaryDark,
                child: Text(d.name.characters.first,
                    style: poppinsBold.copyWith(
                        fontSize: Constants.fontSizeExtraLarge,
                        color: ColorResource.textWhite)),
              ),
              const SizedBox(width: Constants.paddingSizeDefault),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.name,
                        style: poppinsBold.copyWith(
                            fontSize: Constants.fontSizeExtraLarge,
                            color: context.textPrimary)),
                    Text(d.phone,
                        style: poppinsRegular.copyWith(color: context.textSecondary)),
                  ],
                ),
              ),
              StatusChip(label: accountLabel(d.isActive), color: accountColor(d.isActive)),
            ],
          ),
        ),
        const SizedBox(height: Constants.paddingSizeLarge),
        AdminCard(
          title: 'vehicle_info'.tr,
          child: Column(
            children: [
              InfoRow(label: 'vehicle_type'.tr, value: vehicleLabel(d.vehicleType)),
              InfoRow(label: 'vehicle_model'.tr, value: d.vehicleModel),
              InfoRow(label: 'registration'.tr, value: d.registration),
              InfoRow(label: 'rating'.tr, value: d.rating.toStringAsFixed(1)),
              InfoRow(label: 'trips'.tr, value: '${d.tripCount}'),
              InfoRow(label: 'joined'.tr, value: fmtDate(d.joinedAt)),
              InfoRow(
                label: 'availability'.tr,
                valueWidget: StatusChip(
                    label: availabilityLabel(d.availabilityStatus),
                    color: availabilityColor(d.availabilityStatus)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
