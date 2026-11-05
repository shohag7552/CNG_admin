import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

/// Scrollable page body capped at [Constants.adminMaxContentWidth].
class AdminPage extends StatelessWidget {
  final List<Widget> children;

  const AdminPage({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: Constants.adminMaxContentWidth),
        child: ListView(
          padding: const EdgeInsets.all(Constants.paddingSizeLarge),
          children: children,
        ),
      ),
    );
  }
}

/// "← Back to list" link at the top of a detail page.
class BackLink extends StatelessWidget {
  final String path;
  final String labelKey;

  const BackLink({super.key, required this.path, required this.labelKey});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: TextButton.icon(
        onPressed: () => context.go(path),
        icon: const Icon(Icons.arrow_back_rounded),
        label: Text(labelKey.tr),
      ),
    );
  }
}
