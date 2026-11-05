import 'package:appwrite_boilerplate/app/modules/shell/widgets/admin_sidebar.dart';
import 'package:appwrite_boilerplate/app/modules/shell/widgets/admin_top_bar.dart';
import 'package:appwrite_boilerplate/app/common/widgets/web_top_nav.dart';
import 'package:appwrite_boilerplate/app/resources/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Sidebar + top bar around every admin page (go_router ShellRoute builder).
/// >= 900px: fixed sidebar. Narrower: the sidebar becomes a drawer.
class AdminShell extends StatefulWidget {
  /// Current URL path, e.g. `/drivers/drv_3`.
  final String location;
  final Widget child;

  const AdminShell({super.key, required this.location, required this.child});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _detailTitles = {
    '/drivers': 'driver_details',
    '/passengers': 'passenger_details',
    '/bookings': 'booking_details',
    '/trips': 'trip_details',
  };

  String get _title {
    final loc = widget.location;
    final detail = _detailTitles.entries
        .where((e) => loc.startsWith('${e.key}/'))
        .firstOrNull;
    if (detail != null) return detail.value.tr;
    final nav = adminNavItems.where((n) => n.matches(loc)).firstOrNull;
    return (nav?.labelKey ?? 'nav_dashboard').tr;
  }

  @override
  Widget build(BuildContext context) {
    final wide =
        MediaQuery.sizeOf(context).width >= WebTopNav.wideBreakpoint;
    final body = Column(
      children: [
        AdminTopBar(
          title: _title,
          onMenuTap: wide ? null : () => _scaffoldKey.currentState?.openDrawer(),
        ),
        Expanded(child: widget.child),
      ],
    );
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: context.scaffoldBackground,
      drawer: wide
          ? null
          : Drawer(
              child: AdminSidebar(
                location: widget.location,
                onNavigate: () => Navigator.of(context).pop(),
              ),
            ),
      body: wide
          ? Row(
              children: [
                AdminSidebar(location: widget.location),
                Expanded(child: body),
              ],
            )
          : body,
    );
  }
}
