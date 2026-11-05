import 'package:appwrite_boilerplate/app/common/widgets/admin_card.dart';
import 'package:appwrite_boilerplate/app/common/widgets/admin_page.dart';
import 'package:appwrite_boilerplate/app/common/widgets/bookings_table.dart';
import 'package:appwrite_boilerplate/app/common/widgets/state_views.dart';
import 'package:appwrite_boilerplate/app/common/widgets/web_top_nav.dart';
import 'package:appwrite_boilerplate/app/controllers/dashboard_controller.dart';
import 'package:appwrite_boilerplate/app/helper/routes/app_router.dart';
import 'package:appwrite_boilerplate/app/models/admin_stats_model.dart';
import 'package:appwrite_boilerplate/app/modules/dashboard/widgets/bookings_bar_chart.dart';
import 'package:appwrite_boilerplate/app/modules/dashboard/widgets/pending_drivers_card.dart';
import 'package:appwrite_boilerplate/app/common/widgets/stat_card.dart';
import 'package:appwrite_boilerplate/app/resources/colors.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final DashboardController _c = Get.find<DashboardController>();

  @override
  void initState() {
    super.initState();
    _c.load();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (c) {
      final stats = c.stats;
      return AdminPage(children: [
        AsyncStateView(
          isLoading: c.isLoading,
          error: c.errorMessage,
          isEmpty: stats == null,
          onRetry: c.load,
          emptyTitle: 'no_data'.tr,
          skeletonRows: 8,
          child: stats == null ? const SizedBox.shrink() : _content(context, c, stats),
        ),
      ]);
    });
  }

  Widget _content(BuildContext context, DashboardController c, AdminStatsModel s) {
    final wide = MediaQuery.sizeOf(context).width >= WebTopNav.wideBreakpoint;
    final chart = AdminCard(
      title: 'bookings_last_7_days'.tr,
      child: BookingsBarChart(days: s.last7Days),
    );
    final pending =
        PendingDriversCard(drivers: c.pendingDrivers, total: c.pendingTotal);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StatGrid(children: [
          StatCard(icon: Icons.people_alt_rounded, label: 'stat_passengers'.tr, value: '${s.passengers}'),
          StatCard(icon: Icons.badge_rounded, label: 'stat_drivers'.tr, value: '${s.drivers}'),
          StatCard(icon: Icons.wifi_tethering_rounded, label: 'stat_online_drivers'.tr, value: '${s.onlineDrivers}', color: ColorResource.success),
          StatCard(icon: Icons.local_taxi_rounded, label: 'stat_active_bookings'.tr, value: '${s.activeBookings}', color: ColorResource.info),
          StatCard(icon: Icons.check_circle_rounded, label: 'stat_completed_today'.tr, value: '${s.completedToday}', color: ColorResource.accentDark),
        ]),
        const SizedBox(height: Constants.paddingSizeLarge),
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: chart),
              const SizedBox(width: Constants.paddingSizeLarge),
              Expanded(flex: 2, child: pending),
            ],
          )
        else ...[
          chart,
          const SizedBox(height: Constants.paddingSizeLarge),
          pending,
        ],
        const SizedBox(height: Constants.paddingSizeLarge),
        AdminCard(
          title: 'active_bookings'.tr,
          trailing: TextButton(
            onPressed: () => context.go(AppRouter.bookings),
            child: Text('view_all_short'.tr),
          ),
          padding: const EdgeInsets.all(Constants.paddingSizeDefault),
          child: c.activeBookings.isEmpty
              ? StateMessage(
                  icon: Icons.local_taxi_rounded, text: 'no_active_bookings'.tr)
              : BookingsTable(bookings: c.activeBookings),
        ),
      ],
    );
  }
}
