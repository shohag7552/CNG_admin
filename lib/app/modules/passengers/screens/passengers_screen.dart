import 'package:appwrite_boilerplate/app/common/widgets/admin_filters.dart';
import 'package:appwrite_boilerplate/app/common/widgets/admin_page.dart';
import 'package:appwrite_boilerplate/app/common/widgets/admin_table.dart';
import 'package:appwrite_boilerplate/app/common/widgets/state_views.dart';
import 'package:appwrite_boilerplate/app/controllers/passengers_controller.dart';
import 'package:appwrite_boilerplate/app/modules/passengers/widgets/passengers_table.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PassengersScreen extends StatefulWidget {
  const PassengersScreen({super.key});

  @override
  State<PassengersScreen> createState() => _PassengersScreenState();
}

class _PassengersScreenState extends State<PassengersScreen> {
  final PassengersController _c = Get.find<PassengersController>();

  @override
  void initState() {
    super.initState();
    _c.load();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PassengersController>(builder: (c) {
      return AdminPage(children: [
        Wrap(
          spacing: Constants.paddingSizeDefault,
          runSpacing: Constants.paddingSizeDefault,
          children: [
            SearchField(hint: 'search_passengers_hint'.tr, onChanged: c.setQuery),
            FilterDropdown<bool>(
              label: 'status'.tr,
              value: c.isActiveFilter,
              options: [(true, 'status_active'.tr), (false, 'status_suspended'.tr)],
              onChanged: c.setActiveFilter,
            ),
          ],
        ),
        const SizedBox(height: Constants.paddingSizeLarge),
        AsyncStateView(
          isLoading: c.isLoading,
          error: c.errorMessage,
          isEmpty: c.items.isEmpty,
          onRetry: c.load,
          emptyIcon: Icons.people_outline_rounded,
          emptyTitle: 'no_passengers_found'.tr,
          emptySub: 'no_results_desc'.tr,
          child: Column(children: [
            PassengersTable(passengers: c.items),
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
