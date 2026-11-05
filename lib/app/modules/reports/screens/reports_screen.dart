import 'package:appwrite_boilerplate/app/common/widgets/admin_card.dart';
import 'package:appwrite_boilerplate/app/common/widgets/admin_page.dart';
import 'package:appwrite_boilerplate/app/common/widgets/admin_table.dart';
import 'package:appwrite_boilerplate/app/common/widgets/state_views.dart';
import 'package:appwrite_boilerplate/app/common/widgets/stat_card.dart';
import 'package:appwrite_boilerplate/app/controllers/reports_controller.dart';
import 'package:appwrite_boilerplate/app/helper/admin_format.dart';
import 'package:appwrite_boilerplate/app/resources/colors.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ReportsController _c = Get.find<ReportsController>();

  @override
  void initState() {
    super.initState();
    _c.load();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReportsController>(builder: (c) {
      return AdminPage(children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: SegmentedButton<int>(
            segments: [
              ButtonSegment(value: 7, label: Text('last_7_days'.tr)),
              ButtonSegment(value: 30, label: Text('last_30_days'.tr)),
            ],
            selected: {c.days},
            onSelectionChanged: (s) => c.load(s.first),
          ),
        ),
        const SizedBox(height: Constants.paddingSizeLarge),
        AsyncStateView(
          isLoading: c.isLoading,
          error: c.errorMessage,
          isEmpty: c.totalBookings == 0,
          onRetry: c.load,
          emptyIcon: Icons.bar_chart_rounded,
          emptyTitle: 'no_data'.tr,
          emptySub: 'no_report_data_desc'.tr,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatGrid(children: [
                StatCard(icon: Icons.receipt_long_rounded, label: 'total_bookings'.tr, value: '${c.totalBookings}'),
                StatCard(icon: Icons.check_circle_rounded, label: 'completed'.tr, value: '${c.totalCompleted}', color: ColorResource.success),
                StatCard(icon: Icons.cancel_rounded, label: 'cancelled'.tr, value: '${c.totalCancelled}', color: ColorResource.error),
                StatCard(icon: Icons.task_alt_rounded, label: 'completion_rate'.tr, value: percent(c.completionRate), color: ColorResource.success),
                StatCard(icon: Icons.highlight_off_rounded, label: 'cancellation_rate'.tr, value: percent(c.cancellationRate), color: ColorResource.error),
              ]),
              const SizedBox(height: Constants.paddingSizeLarge),
              AdminCard(
                title: 'bookings_per_day'.tr,
                padding: const EdgeInsets.all(Constants.paddingSizeDefault),
                child: AdminTable(
                  columns: [
                    AdminColumn('date'.tr, 160),
                    AdminColumn('total_bookings'.tr, 120),
                    AdminColumn('completed'.tr, 110),
                    AdminColumn('cancelled'.tr, 110),
                    AdminColumn('completion_rate'.tr, 140),
                  ],
                  rows: [
                    // Newest first.
                    for (final d in c.daily.reversed)
                      AdminTableRow(cells: [
                        CellText(DateFormat.yMMMEd().format(d.day), bold: true),
                        CellText('${d.total}'),
                        CellText('${d.completed}'),
                        CellText('${d.cancelled}'),
                        CellText(percent(d.total == 0 ? 0 : d.completed / d.total)),
                      ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]);
    });
  }
}
