import 'package:appwrite_boilerplate/app/common/widgets/admin_page.dart';
import 'package:appwrite_boilerplate/app/common/widgets/state_views.dart';
import 'package:appwrite_boilerplate/app/common/widgets/web_top_nav.dart';
import 'package:appwrite_boilerplate/app/controllers/drivers_controller.dart';
import 'package:appwrite_boilerplate/app/helper/routes/app_router.dart';
import 'package:appwrite_boilerplate/app/modules/drivers/widgets/document_placeholders.dart';
import 'package:appwrite_boilerplate/app/modules/drivers/widgets/driver_actions_card.dart';
import 'package:appwrite_boilerplate/app/modules/drivers/widgets/driver_profile_card.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DriverDetailScreen extends StatefulWidget {
  final String id;

  const DriverDetailScreen({super.key, required this.id});

  @override
  State<DriverDetailScreen> createState() => _DriverDetailScreenState();
}

class _DriverDetailScreenState extends State<DriverDetailScreen> {
  final DriversController _c = Get.find<DriversController>();

  @override
  void initState() {
    super.initState();
    _c.loadDriver(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= WebTopNav.wideBreakpoint;
    return GetBuilder<DriversController>(builder: (c) {
      final d = c.driver;
      return AdminPage(children: [
        const BackLink(path: AppRouter.drivers, labelKey: 'back_to_drivers'),
        AsyncStateView(
          isLoading: c.detailLoading,
          error: c.detailError,
          isEmpty: d == null,
          onRetry: () => c.loadDriver(widget.id),
          emptyIcon: Icons.badge_outlined,
          emptyTitle: 'driver_not_found'.tr,
          child: d == null
              ? const SizedBox.shrink()
              : () {
                  final main = Column(children: [
                    DriverProfileCard(driver: d),
                    const SizedBox(height: Constants.paddingSizeLarge),
                    const DocumentPlaceholders(),
                  ]);
                  final actions = DriverActionsCard(driver: d, busy: c.isActing);
                  return wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: main),
                            const SizedBox(width: Constants.paddingSizeLarge),
                            SizedBox(width: Constants.sidePanelWidth, child: actions),
                          ],
                        )
                      : Column(children: [
                          actions,
                          const SizedBox(height: Constants.paddingSizeLarge),
                          main,
                        ]);
                }(),
        ),
      ]);
    });
  }
}
