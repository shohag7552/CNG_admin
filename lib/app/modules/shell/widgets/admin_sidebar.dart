import 'package:appwrite_boilerplate/app/helper/routes/app_router.dart';
import 'package:appwrite_boilerplate/app/resources/colors.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:appwrite_boilerplate/app/resources/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class AdminNavItem {
  final IconData icon;
  final String labelKey;
  final String path;

  const AdminNavItem(this.icon, this.labelKey, this.path);

  bool matches(String location) =>
      path == AppRouter.dashboard ? location == path : location.startsWith(path);
}

const List<AdminNavItem> adminNavItems = [
  AdminNavItem(Icons.dashboard_rounded, 'nav_dashboard', AppRouter.dashboard),
  AdminNavItem(Icons.badge_rounded, 'nav_drivers', AppRouter.drivers),
  AdminNavItem(Icons.people_alt_rounded, 'nav_passengers', AppRouter.passengers),
  AdminNavItem(Icons.receipt_long_rounded, 'nav_bookings', AppRouter.bookings),
  AdminNavItem(Icons.route_rounded, 'nav_trips', AppRouter.trips),
  AdminNavItem(Icons.bar_chart_rounded, 'nav_reports', AppRouter.reports),
  AdminNavItem(Icons.tune_rounded, 'nav_business_settings', AppRouter.businessSettings),
  AdminNavItem(Icons.history_rounded, 'nav_audit_log', AppRouter.auditLog),
];

/// Left navigation. Used as a fixed column on wide screens and as the drawer
/// content on narrow ones ([onNavigate] closes the drawer).
class AdminSidebar extends StatelessWidget {
  final String location;
  final VoidCallback? onNavigate;

  const AdminSidebar({super.key, required this.location, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Constants.sidebarWidth,
      decoration: BoxDecoration(
        color: context.cardBackground,
        border: BorderDirectional(
          end: BorderSide(color: context.textLight.withValues(alpha: 0.2)),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: Constants.topBarHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Constants.paddingSizeLarge),
                child: Row(
                  children: [
                    Container(
                      width: Constants.avatarSize * 0.75,
                      height: Constants.avatarSize * 0.75,
                      decoration: BoxDecoration(
                        gradient: ColorResource.primaryGradient,
                        borderRadius: BorderRadius.circular(Constants.radiusDefault),
                      ),
                      child: const Icon(Icons.electric_rickshaw_rounded,
                          color: ColorResource.textWhite),
                    ),
                    const SizedBox(width: Constants.paddingSizeSmall),
                    Expanded(
                      child: Text(Constants.appName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: poppinsBold.copyWith(
                              fontSize: Constants.fontSizeLarge,
                              color: context.textPrimary)),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(Constants.paddingSizeSmall),
                children: [
                  for (final item in adminNavItems)
                    _NavTile(
                      item: item,
                      selected: item.matches(location),
                      onTap: () {
                        onNavigate?.call();
                        context.go(item.path);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final AdminNavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavTile({required this.item, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? ColorResource.primaryDark : context.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: Constants.paddingSizeExtraSmall),
      child: Material(
        color: selected
            ? ColorResource.primaryDark.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(Constants.radiusDefault),
        child: InkWell(
          borderRadius: BorderRadius.circular(Constants.radiusDefault),
          onTap: onTap,
          child: SizedBox(
            height: Constants.minTapTarget + 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Constants.paddingSizeDefault),
              child: Row(
                children: [
                  Icon(item.icon, size: 20, color: color),
                  const SizedBox(width: Constants.paddingSizeSmall + 2),
                  Expanded(
                    child: Text(item.labelKey.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: (selected ? poppinsBold : poppinsMedium)
                            .copyWith(color: color)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
