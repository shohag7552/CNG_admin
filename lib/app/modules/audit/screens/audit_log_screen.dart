import 'package:appwrite_boilerplate/app/common/widgets/admin_filters.dart';
import 'package:appwrite_boilerplate/app/common/widgets/admin_page.dart';
import 'package:appwrite_boilerplate/app/common/widgets/admin_table.dart';
import 'package:appwrite_boilerplate/app/common/widgets/state_views.dart';
import 'package:appwrite_boilerplate/app/controllers/audit_controller.dart';
import 'package:appwrite_boilerplate/app/helper/admin_format.dart';
import 'package:appwrite_boilerplate/app/models/audit_log_model.dart';
import 'package:appwrite_boilerplate/app/resources/colors.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  final AuditController _c = Get.find<AuditController>();

  @override
  void initState() {
    super.initState();
    _c.load();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuditController>(builder: (c) {
      return AdminPage(children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: FilterDropdown<AuditAction>(
            label: 'action_type'.tr,
            value: c.action,
            options: [for (final a in AuditAction.values) (a, 'audit_action_${a.name}'.tr)],
            onChanged: c.setAction,
          ),
        ),
        const SizedBox(height: Constants.paddingSizeLarge),
        AsyncStateView(
          isLoading: c.isLoading,
          error: c.errorMessage,
          isEmpty: c.items.isEmpty,
          onRetry: c.load,
          emptyIcon: Icons.history_rounded,
          emptyTitle: 'no_audit_entries'.tr,
          emptySub: 'no_results_desc'.tr,
          child: Column(children: [
            AdminTable(
              columns: [
                AdminColumn('time'.tr, 170),
                AdminColumn('admin'.tr, 140),
                AdminColumn('action'.tr, 180),
                AdminColumn('target'.tr, 170),
                AdminColumn('reason'.tr, 280),
              ],
              rows: [
                for (final a in c.items)
                  AdminTableRow(cells: [
                    CellText(fmtDateTime(a.createdAt), color: context.textSecondary),
                    CellText(a.adminName),
                    CellText('audit_action_${a.action.name}'.tr, bold: true),
                    CellText('${'target_${a.targetType}'.tr} · ${a.targetId}'),
                    CellText(a.reason ?? '—', color: context.textSecondary),
                  ]),
              ],
            ),
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
