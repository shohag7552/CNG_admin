import 'package:appwrite_boilerplate/app/common/widgets/admin_dialogs.dart';
import 'package:appwrite_boilerplate/app/controllers/admin_session_controller.dart';
import 'package:appwrite_boilerplate/app/controllers/localization_controller.dart';
import 'package:appwrite_boilerplate/app/helper/routes/app_router.dart';
import 'package:appwrite_boilerplate/app/resources/colors.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:appwrite_boilerplate/app/resources/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

/// Page title + language menu + theme toggle + admin avatar menu.
class AdminTopBar extends StatelessWidget {
  final String title;

  /// Non-null on narrow screens: shows the menu button that opens the drawer.
  final VoidCallback? onMenuTap;

  const AdminTopBar({super.key, required this.title, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Constants.topBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: Constants.paddingSizeDefault),
      decoration: BoxDecoration(
        color: context.cardBackground,
        border: Border(
          bottom: BorderSide(color: context.textLight.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        children: [
          if (onMenuTap != null)
            IconButton(
              tooltip: 'menu'.tr,
              icon: const Icon(Icons.menu_rounded),
              onPressed: onMenuTap,
            ),
          Expanded(
            child: Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: poppinsBold.copyWith(
                    fontSize: Constants.fontSizeExtraLarge,
                    color: context.textPrimary)),
          ),
          const _LanguageMenu(),
          GetBuilder<LocalizationController>(
            builder: (lc) => IconButton(
              tooltip: lc.darkTheme ? 'light_mode'.tr : 'dark_mode'.tr,
              icon: Icon(lc.darkTheme
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded),
              onPressed: lc.toggleTheme,
            ),
          ),
          const _AdminMenu(),
        ],
      ),
    );
  }
}

class _LanguageMenu extends StatelessWidget {
  const _LanguageMenu();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocalizationController>(builder: (lc) {
      final code = lc.locale.languageCode;
      return PopupMenuButton<int>(
        tooltip: 'select_language'.tr,
        icon: const Icon(Icons.language_rounded),
        onSelected: (i) {
          final l = Constants.languages[i];
          lc.setSelectLanguageIndex(i);
          lc.setLanguage(Locale(l.languageCode, l.countryCode));
        },
        itemBuilder: (_) => [
          for (var i = 0; i < Constants.languages.length; i++)
            PopupMenuItem<int>(
              value: i,
              child: Row(
                children: [
                  Expanded(child: Text(Constants.languages[i].languageName)),
                  if (Constants.languages[i].languageCode == code)
                    const Icon(Icons.check_rounded,
                        size: 18, color: ColorResource.primaryDark),
                ],
              ),
            ),
        ],
      );
    });
  }
}

class _AdminMenu extends StatelessWidget {
  const _AdminMenu();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdminSessionController>(builder: (s) {
      return PopupMenuButton<String>(
        tooltip: s.name,
        offset: const Offset(0, Constants.topBarHeight - 16),
        onSelected: (v) async {
          if (v == 'profile') {
            await showConfirmDialog(
              context,
              title: s.name,
              message: '${s.email}\n${'role'.tr}: ${'role_${s.role.name}'.tr}',
              confirmLabel: 'ok'.tr,
            );
          } else if (v == 'demo') {
            s.toggleDemoRole();
          } else if (v == 'logout') {
            s.logout();
            if (context.mounted) context.go(AppRouter.login);
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            enabled: false,
            child: Text('${s.name}\n${s.email}',
                style: poppinsMedium.copyWith(color: context.textPrimary)),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'profile',
            child: ListTile(
                dense: true,
                leading: const Icon(Icons.person_outline),
                title: Text('my_profile'.tr)),
          ),
          // Demo only: shows the AdminGuard "not authorized" screen.
          PopupMenuItem(
            value: 'demo',
            child: ListTile(
                dense: true,
                leading: const Icon(Icons.swap_horiz_rounded),
                title: Text('demo_switch_role'.tr)),
          ),
          PopupMenuItem(
            value: 'logout',
            child: ListTile(
                dense: true,
                leading: const Icon(Icons.logout),
                title: Text('logout'.tr)),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Constants.paddingSizeSmall),
          child: CircleAvatar(
            radius: Constants.avatarSize / 3,
            backgroundColor: ColorResource.primaryDark,
            child: Text(s.name.characters.first,
                style: poppinsBold.copyWith(color: ColorResource.textWhite)),
          ),
        ),
      );
    });
  }
}
