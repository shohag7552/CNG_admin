import 'package:appwrite_boilerplate/app/common/widgets/admin_filters.dart';
import 'package:appwrite_boilerplate/app/common/widgets/admin_page.dart';
import 'package:appwrite_boilerplate/app/common/widgets/admin_table.dart';
import 'package:appwrite_boilerplate/app/common/widgets/state_views.dart';
import 'package:appwrite_boilerplate/app/common/widgets/status_chip.dart';
import 'package:appwrite_boilerplate/app/controllers/drivers_controller.dart';
import 'package:appwrite_boilerplate/app/models/driver_profile_model.dart';
import 'package:appwrite_boilerplate/app/modules/drivers/widgets/drivers_table.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DriversScreen extends StatefulWidget {
  const DriversScreen({super.key});

  @override
  State<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  final DriversController _c = Get.find<DriversController>();

  @override
  void initState() {
    super.initState();
    _c.load();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DriversController>(builder: (c) {
      return AdminPage(children: [
        Wrap(
          spacing: Constants.paddingSizeDefault,
          runSpacing: Constants.paddingSizeDefault,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SearchField(hint: 'search_drivers_hint'.tr, onChanged: c.setQuery),
            FilterDropdown<VerificationStatus>(
              label: 'verification'.tr,
              value: c.verification,
              options: [for (final v in VerificationStatus.values) (v, verificationLabel(v))],
              onChanged: c.setVerification,
            ),
            FilterDropdown<AvailabilityStatus>(
              label: 'availability'.tr,
              value: c.availability,
              options: [for (final v in AvailabilityStatus.values) (v, availabilityLabel(v))],
              onChanged: c.setAvailability,
            ),
          ],
        ),
        const SizedBox(height: Constants.paddingSizeLarge),
        AsyncStateView(
          isLoading: c.isLoading,
          error: c.errorMessage,
          isEmpty: c.items.isEmpty,
          onRetry: c.load,
          emptyIcon: Icons.badge_outlined,
          emptyTitle: 'no_drivers_found'.tr,
          emptySub: 'no_results_desc'.tr,
          child: Column(children: [
            DriversTable(drivers: c.items),
            LoadMoreBar(
              shown: c.items.length,
              total: c.total,
              hasMore: c.hasMore,
              isLoadingMore: c.isLoadingMore,
              onLoadMore: c.loadMore,
            ),
          ]),
        ),
      ]);
    });
  }
}
