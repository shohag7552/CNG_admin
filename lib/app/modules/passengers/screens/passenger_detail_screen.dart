import 'package:appwrite_boilerplate/app/common/widgets/admin_page.dart';
import 'package:appwrite_boilerplate/app/common/widgets/state_views.dart';
import 'package:appwrite_boilerplate/app/common/widgets/web_top_nav.dart';
import 'package:appwrite_boilerplate/app/controllers/passengers_controller.dart';
import 'package:appwrite_boilerplate/app/helper/routes/app_router.dart';
import 'package:appwrite_boilerplate/app/modules/passengers/widgets/passenger_actions_card.dart';
import 'package:appwrite_boilerplate/app/modules/passengers/widgets/passenger_info_card.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PassengerDetailScreen extends StatefulWidget {
  final String id;

  const PassengerDetailScreen({super.key, required this.id});

  @override
  State<PassengerDetailScreen> createState() => _PassengerDetailScreenState();
}

class _PassengerDetailScreenState extends State<PassengerDetailScreen> {
  final PassengersController _c = Get.find<PassengersController>();

  @override
  void initState() {
    super.initState();
    _c.loadPassenger(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= WebTopNav.wideBreakpoint;
    return GetBuilder<PassengersController>(builder: (c) {
      final p = c.passenger;
      return AdminPage(children: [
        const BackLink(path: AppRouter.passengers, labelKey: 'back_to_passengers'),
        AsyncStateView(
          isLoading: c.detailLoading,
          error: c.detailError,
          isEmpty: p == null,
          onRetry: () => c.loadPassenger(widget.id),
          emptyIcon: Icons.people_outline_rounded,
          emptyTitle: 'passenger_not_found'.tr,
          skeletonRows: 4,
          child: p == null
              ? const SizedBox.shrink()
              : () {
                  final info = PassengerInfoCard(passenger: p);
                  final actions = PassengerActionsCard(passenger: p, busy: c.isActing);
                  return wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: info),
                            const SizedBox(width: Constants.paddingSizeLarge),
                            SizedBox(width: Constants.sidePanelWidth, child: actions),
                          ],
                        )
                      : Column(children: [
                          info,
                          const SizedBox(height: Constants.paddingSizeLarge),
                          actions,
                        ]);
                }(),
        ),
      ]);
    });
  }
}
