import 'package:appwrite_boilerplate/app/controllers/settings_controller.dart';
import 'package:appwrite_boilerplate/app/controllers/policy_controller.dart';
import 'package:appwrite_boilerplate/app/helper/dashboard_tab_bus.dart';
import 'package:appwrite_boilerplate/app/models/address_model.dart';
import 'package:appwrite_boilerplate/app/modules/address/screens/add_edit_address_page.dart';
import 'package:appwrite_boilerplate/app/modules/address/screens/addresses_page.dart';
import 'package:appwrite_boilerplate/app/modules/address/screens/full_screen_map_page.dart';
import 'package:appwrite_boilerplate/app/modules/auth/screens/forgot_password_screen.dart';
import 'package:appwrite_boilerplate/app/modules/auth/screens/reset_password_screen.dart';
import 'package:appwrite_boilerplate/app/modules/auth/screens/login_screen.dart';
import 'package:appwrite_boilerplate/app/modules/auth/screens/signup_screen.dart';
import 'package:appwrite_boilerplate/app/modules/dashboard/screens/dashboard_screen.dart';
import 'package:appwrite_boilerplate/app/modules/dashboard/widgets/full_screen_image_viewer.dart';
import 'package:appwrite_boilerplate/app/modules/language/screens/language_screen.dart';
import 'package:appwrite_boilerplate/app/modules/notification/screens/notification_screen.dart';
import 'package:appwrite_boilerplate/app/modules/help_support/screens/help_support_screen.dart';
import 'package:appwrite_boilerplate/app/modules/policies/screens/policy_content_screen.dart';
import 'package:appwrite_boilerplate/app/modules/profile/screens/edit_profile_page.dart';
import 'package:appwrite_boilerplate/app/modules/maintenance/screens/maintenance_screen.dart';
import 'package:appwrite_boilerplate/app/modules/splash/screens/splash_screen.dart';
import 'package:appwrite_boilerplate/app/modules/update/screens/force_update_screen.dart';
import 'package:appwrite_boilerplate/app/resources/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

/// Route name identifiers used with `context.goNamed` / `context.pushNamed`.
///
/// Using named routes keeps call sites decoupled from the concrete URL
/// structure — change a path in one place (the [GoRoute] below) and every
/// navigation call keeps working.
abstract class RouteNames {
  const RouteNames._();

  static const splash = 'splash';
  static const forceUpdate = 'force-update';
  static const maintenance = 'maintenance';
  static const login = 'login';
  static const signup = 'signup';
  static const forgotPassword = 'forgot-password';
  static const resetPassword = 'reset-password';
  static const dashboard = 'dashboard';
  static const editProfile = 'edit-profile';
  static const addresses = 'addresses';
  static const addEditAddress = 'add-edit-address';
  static const notifications = 'notifications';
  static const language = 'language';
  static const policy = 'policy';
  static const helpSupport = 'help-support';
  static const mapPicker = 'map-picker';
  static const imageViewer = 'image-viewer';
}

// ── Argument bundles for routes that carry more than one non-URL value. ──
// Passed through go_router's `extra`; only available for in-app navigation
// (a hard refresh / deep link has `extra == null`, handled per route below).

/// URL segment values for the `/policy/:type` route. Using stable slugs (not
/// localized titles) keeps the links language-independent and shareable.
abstract class PolicyType {
  const PolicyType._();

  static const aboutUs = 'about-us';
  static const terms = 'terms';
  static const privacy = 'privacy';
}

class ImageViewerArgs {
  /// Every image in the set the viewer can swipe through.
  final List<String> images;

  /// Which of [images] to open on.
  final int initialIndex;

  /// Hero tag of the thumbnail that was tapped. Only the page at
  /// [initialIndex] carries it, so the flight matches the origin.
  final String heroTag;

  const ImageViewerArgs({
    required this.images,
    required this.heroTag,
    this.initialIndex = 0,
  });

  /// Shorthand for screens that only have one image to show.
  ImageViewerArgs.single({required String imageUrl, required this.heroTag})
      : images = [imageUrl],
        initialIndex = 0;
}

/// Central app router.
///
/// Keeps GetX for state/DI/i18n while go_router owns navigation. Detail pages
/// use a path parameter for their id (clean, deep-linkable URLs) plus `extra`
/// carrying the already-loaded model for instant render; on a cold deep link
/// the page hydrates from the id where possible, otherwise falls back home.
abstract class AppRouter {
  const AppRouter._();

  // Reuse GetX's navigator key so GetX overlays (Get.snackbar / Get.dialog /
  // Get.bottomSheet) resolve against the same navigator go_router drives.
  static final GlobalKey<NavigatorState> rootNavigatorKey = Get.key;

  /// Where the app opens. Defaults to the splash route (used on mobile). On web
  /// `Global.init` runs the bootstrap (auth + settings/module resolution) up
  /// front and overrides this to [dashboard] or [login] so the browser lands
  /// there directly, skipping the splash. Must be set before [router] is first
  /// accessed.
  static String startLocation = splash;

  // Concrete paths (templates for the ones with parameters).
  static const String splash = '/splash';
  static const String forceUpdate = '/force-update';
  static const String maintenance = '/maintenance';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  /// Landing path of Appwrite's password-recovery email link. Must stay in sync
  /// with [AppwriteConfig.passwordRecoveryUrl], the `<data android:pathPrefix>`
  /// in `android/app/src/main/AndroidManifest.xml`, and the components in
  /// `web/.well-known/apple-app-site-association`.
  static const String resetPassword = '/reset-password';
  static const String dashboard = '/';
  static const String editProfile = '/edit-profile';
  static const String addresses = '/addresses';
  static const String addEditAddress = '/addresses/edit';
  static const String notifications = '/notifications';
  static const String language = '/language';
  static const String policyPath = '/policy/:type';
  static const String helpSupport = '/help-support';
  static const String mapPicker = '/map-picker';
  static const String imageViewer = '/image-viewer';

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: startLocation,
    routes: [
      GoRoute(
        path: splash,
        name: RouteNames.splash,
        // `?next=` lets a screen that started outside the normal boot path —
        // e.g. a cold deep link into /reset-password, which skips the splash
        // entirely — hand control back for the real bootstrap and still land
        // somewhere specific afterwards.
        builder: (context, state) =>
            SplashScreen(nextLocation: state.uri.queryParameters['next']),
      ),
      GoRoute(
        path: forceUpdate,
        name: RouteNames.forceUpdate,
        builder: (context, state) => const ForceUpdateScreen(),
      ),
      GoRoute(
        path: maintenance,
        name: RouteNames.maintenance,
        builder: (context, state) => const MaintenanceScreen(),
      ),
      GoRoute(
        path: login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: signup,
        name: RouteNames.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: forgotPassword,
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: resetPassword,
        name: RouteNames.resetPassword,
        // Landing route for Appwrite's recovery email:
        //   https://…/reset-password?userId=…&secret=…&expire=…
        //
        // Hydrated purely from the query string — a platform deep link (browser
        // URL, Android App Link, iOS Universal Link) never carries `extra`.
        //
        // ⚠️ If a top-level auth `redirect` is ever added to this router, this
        // path must be allowlisted: it is reached with no session by design.
        builder: (context, state) => ResetPasswordScreen(
          userId: state.uri.queryParameters['userId'] ?? '',
          secret: state.uri.queryParameters['secret'] ?? '',
        ),
      ),
      GoRoute(
        path: dashboard,
        name: RouteNames.dashboard,
        // `?tab=profile` (etc.) selects a dashboard tab, making every tab a
        // shareable URL; no parameter means "leave the current tab alone".
        builder: (context, state) => DashboardScreen(
          initialTab:
              DashboardTabs.indexFromName(state.uri.queryParameters['tab']),
        ),
      ),
      GoRoute(
        path: editProfile,
        name: RouteNames.editProfile,
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: addresses,
        name: RouteNames.addresses,
        builder: (context, state) => const AddressesPage(),
      ),
      GoRoute(
        path: addEditAddress,
        name: RouteNames.addEditAddress,
        builder: (context, state) =>
            AddEditAddressPage(address: state.extra as AddressModel?),
      ),
      GoRoute(
        path: notifications,
        name: RouteNames.notifications,
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: language,
        name: RouteNames.language,
        builder: (context, state) => const LanguageScreen(),
      ),
      GoRoute(
        path: policyPath,
        name: RouteNames.policy,
        // Content is resolved from PolicyController by the :type slug, so the
        // page needs nothing beyond its URL — fully deep-linkable.
        builder: (context, state) => _DeepLinkLoader<(String, String)>(
          fetch: () async {
            final policyController = Get.find<PolicyController>();
            if (policyController.policies == null) {
              await policyController.fetchPolicies();
            }
            final policies = policyController.policies;
            if (policies == null) return null;
            return switch (state.pathParameters['type']) {
              PolicyType.aboutUs => ('about_us'.tr, policies.aboutUsHtml),
              PolicyType.terms => (
                  'terms_and_conditions_title'.tr,
                  policies.termsAndConditionsHtml,
                ),
              PolicyType.privacy => (
                  'privacy_policy_title'.tr,
                  policies.privacyPolicyHtml,
                ),
              _ => null,
            };
          },
          notFoundKey: 'content_not_available',
          builder: (content) => PolicyContentScreen(
            title: content.$1,
            htmlContent: content.$2,
          ),
        ),
      ),
      GoRoute(
        path: helpSupport,
        name: RouteNames.helpSupport,
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: mapPicker,
        name: RouteNames.mapPicker,
        builder: (context, state) => FullScreenMapPage(
          initialLocation:
              state.extra as LatLng? ??
              Get.find<SettingsController>().defaultMapLocation,
        ),
      ),
      GoRoute(
        path: imageViewer,
        name: RouteNames.imageViewer,
        redirect: (context, state) =>
            state.extra is ImageViewerArgs ? null : dashboard,
        builder: (context, state) {
          final args = state.extra as ImageViewerArgs;
          return FullScreenImageViewer(
            images: args.images,
            initialIndex: args.initialIndex,
            heroTag: args.heroTag,
          );
        },
      ),
    ],
  );
}

/// Hydrates a page's data from its URL when a route is opened via a cold deep
/// link (hard refresh / copied URL — `extra` is `null`). Shows a spinner while
/// [fetch] resolves, the page from [builder] on success, and a translated
/// not-found message ([notFoundKey]) when the data cannot be loaded.
class _DeepLinkLoader<T> extends StatefulWidget {
  final Future<T?> Function() fetch;
  final Widget Function(T data) builder;
  final String notFoundKey;

  const _DeepLinkLoader({
    required this.fetch,
    required this.builder,
    required this.notFoundKey,
  });

  @override
  State<_DeepLinkLoader<T>> createState() => _DeepLinkLoaderState<T>();
}

class _DeepLinkLoaderState<T> extends State<_DeepLinkLoader<T>> {
  late final Future<T?> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.fetch();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final data = snapshot.data;
        if (data == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text(
                widget.notFoundKey.tr,
                style: TextStyle(color: context.textSecondary),
              ),
            ),
          );
        }
        return widget.builder(data);
      },
    );
  }
}
