import 'package:appwrite_boilerplate/app/models/booking_model.dart';
import 'package:appwrite_boilerplate/app/models/driver_profile_model.dart';
import 'package:appwrite_boilerplate/app/models/offer_model.dart';
import 'package:appwrite_boilerplate/app/resources/colors.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:appwrite_boilerplate/app/resources/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Status colours: green done/approved, amber pending, red cancelled/rejected/
// suspended, blue in progress, grey expired.
const Color _green = ColorResource.success;
const Color _red = ColorResource.error;
const Color _blue = ColorResource.info;
const Color _amber = ColorResource.accentDark;
Color get _grey => ColorResource.textLight;

String bookingStatusLabel(BookingStatus s) => 'booking_status_${s.name}'.tr;

Color bookingStatusColor(BookingStatus s) => switch (s) {
      BookingStatus.completed || BookingStatus.confirmed => _green,
      BookingStatus.cancelled => _red,
      BookingStatus.expired => _grey,
      BookingStatus.inProgress || BookingStatus.driverArriving => _blue,
      _ => _amber,
    };

String verificationLabel(VerificationStatus s) => 'verification_${s.name}'.tr;

Color verificationColor(VerificationStatus s) => switch (s) {
      VerificationStatus.approved => _green,
      VerificationStatus.rejected => _red,
      VerificationStatus.pending => _amber,
    };

String availabilityLabel(AvailabilityStatus s) => 'availability_${s.name}'.tr;

Color availabilityColor(AvailabilityStatus s) => switch (s) {
      AvailabilityStatus.online => _green,
      AvailabilityStatus.onTrip => _blue,
      AvailabilityStatus.offline => _grey,
    };

String offerStatusLabel(OfferStatus s) => 'offer_status_${s.name}'.tr;

Color offerStatusColor(OfferStatus s) => switch (s) {
      OfferStatus.accepted => _green,
      OfferStatus.rejected => _red,
      OfferStatus.pending => _amber,
      OfferStatus.expired => _grey,
    };

/// Account state shared by drivers and passengers.
String accountLabel(bool isActive) =>
    isActive ? 'status_active'.tr : 'status_suspended'.tr;
Color accountColor(bool isActive) => isActive ? _green : _red;

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const StatusChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Constants.paddingSizeSmall,
          vertical: Constants.chipVerticalPadding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Constants.radiusExtraLarge),
      ),
      child: Text(label,
          style: poppinsMedium.copyWith(
              fontSize: Constants.fontSizeSmall, color: color)),
    );
  }
}
