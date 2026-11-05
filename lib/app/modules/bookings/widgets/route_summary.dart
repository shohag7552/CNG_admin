import 'package:appwrite_boilerplate/app/models/booking_model.dart';
import 'package:appwrite_boilerplate/app/resources/colors.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:appwrite_boilerplate/app/resources/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Pickup → destination, joined by a vertical line.
class RouteSummary extends StatelessWidget {
  final PlaceModel pickup;
  final PlaceModel destination;

  const RouteSummary({
    super.key,
    required this.pickup,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              const SizedBox(height: Constants.paddingSizeSmall),
              Container(
                width: Constants.routeDotSize,
                height: Constants.routeDotSize,
                decoration: const BoxDecoration(
                  color: ColorResource.primaryDark,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: context.textLight.withValues(alpha: 0.4),
                ),
              ),
              Container(
                width: Constants.routeDotSize,
                height: Constants.routeDotSize,
                decoration: BoxDecoration(
                  color: ColorResource.accent,
                  borderRadius: BorderRadius.circular(
                    Constants.radiusSmall / 2,
                  ),
                ),
              ),
              const SizedBox(height: Constants.paddingSizeSmall),
            ],
          ),
          const SizedBox(width: Constants.paddingSizeDefault),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _row(context, 'pickup'.tr, pickup),
                Divider(
                  height: 1,
                  color: context.textLight.withValues(alpha: 0.2),
                ),
                _row(context, 'destination'.tr, destination),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, PlaceModel p) => Padding(
    padding: const EdgeInsets.symmetric(vertical: Constants.paddingSizeSmall),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: poppinsRegular.copyWith(
            fontSize: Constants.fontSizeExtraSmall,
            color: context.textSecondary,
          ),
        ),
        Text(p.name, style: poppinsMedium.copyWith(color: context.textPrimary)),
        Text(
          p.address,
          style: poppinsRegular.copyWith(
            fontSize: Constants.fontSizeSmall,
            color: context.textSecondary,
          ),
        ),
      ],
    ),
  );
}
