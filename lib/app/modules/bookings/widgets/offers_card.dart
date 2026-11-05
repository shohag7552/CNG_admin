import 'package:appwrite_boilerplate/app/common/widgets/admin_card.dart';
import 'package:appwrite_boilerplate/app/common/widgets/admin_table.dart';
import 'package:appwrite_boilerplate/app/common/widgets/status_chip.dart';
import 'package:appwrite_boilerplate/app/helper/admin_format.dart';
import 'package:appwrite_boilerplate/app/models/offer_model.dart';
import 'package:appwrite_boilerplate/app/resources/colors.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:appwrite_boilerplate/app/resources/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Every driver response to the booking.
class OffersCard extends StatelessWidget {
  final List<OfferModel> offers;

  const OffersCard({super.key, required this.offers});

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      title: 'driver_offers'.tr,
      padding: const EdgeInsets.all(Constants.paddingSizeDefault),
      child: offers.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(Constants.paddingSizeDefault),
              child: Text('no_offers'.tr,
                  style: poppinsRegular.copyWith(color: context.textSecondary)),
            )
          : AdminTable(
              columns: [
                AdminColumn('driver'.tr, 150),
                AdminColumn('plate_number'.tr, 190),
                AdminColumn('offer_type'.tr, 130),
                AdminColumn('fare'.tr, 80),
                AdminColumn('status'.tr, 110),
              ],
              rows: [
                for (final o in offers)
                  AdminTableRow(cells: [
                    CellText(o.driverName, bold: true),
                    CellText(o.vehiclePlate, color: context.textSecondary),
                    CellText((o.isCounteroffer ? 'counteroffer' : 'accepted_proposed_fare').tr),
                    Text(bdt(o.offeredFare),
                        style: poppinsBold.copyWith(color: ColorResource.accentDark)),
                    StatusChip(
                        label: offerStatusLabel(o.status),
                        color: offerStatusColor(o.status)),
                  ]),
              ],
            ),
    );
  }
}
