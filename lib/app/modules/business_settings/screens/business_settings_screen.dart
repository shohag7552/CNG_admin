import 'package:appwrite_boilerplate/app/common/widgets/admin_page.dart';
import 'package:appwrite_boilerplate/app/common/widgets/state_views.dart';
import 'package:appwrite_boilerplate/app/controllers/business_settings_controller.dart';
import 'package:appwrite_boilerplate/app/modules/business_settings/widgets/settings_form.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BusinessSettingsScreen extends StatefulWidget {
  const BusinessSettingsScreen({super.key});

  @override
  State<BusinessSettingsScreen> createState() => _BusinessSettingsScreenState();
}

class _BusinessSettingsScreenState extends State<BusinessSettingsScreen> {
  final BusinessSettingsController _c = Get.find<BusinessSettingsController>();

  @override
  void initState() {
    super.initState();
    _c.load();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessSettingsController>(builder: (c) {
      return AdminPage(children: [
        Align(
          alignment: AlignmentDirectional.topStart,
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: Constants.settingsFormMaxWidth),
            child: AsyncStateView(
              isLoading: c.isLoading,
              error: c.errorMessage,
              isEmpty: c.draft == null,
              onRetry: c.load,
              emptyTitle: 'no_data'.tr,
              skeletonRows: 8,
              // A fresh State per load so the text fields re-seed.
              child: const SettingsForm(),
            ),
          ),
        ),
      ]);
    });
  }
}
