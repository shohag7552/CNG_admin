import 'package:appwrite_boilerplate/app/common/widgets/state_views.dart';
import 'package:appwrite_boilerplate/app/controllers/admin_session_controller.dart';
import 'package:appwrite_boilerplate/app/helper/routes/app_router.dart';
import 'package:appwrite_boilerplate/app/resources/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

/// Shown by AdminGuard to a signed-in user who is not an admin.
class NotAuthorizedScreen extends StatelessWidget {
  const NotAuthorizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Get.find<AdminSessionController>();
    return Scaffold(
      backgroundColor: context.scaffoldBackground,
      body: StateMessage(
        icon: Icons.gpp_bad_rounded,
        text: 'not_authorized'.tr,
        sub: 'not_authorized_desc'.tr,
        actionLabel: 'sign_out'.tr,
        onAction: () {
          session.logout();
          context.go(AppRouter.login);
        },
      ),
    );
  }
}
