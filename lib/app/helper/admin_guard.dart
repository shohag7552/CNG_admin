import 'package:appwrite_boilerplate/app/controllers/admin_session_controller.dart';
import 'package:appwrite_boilerplate/app/controllers/auth_controller.dart';
import 'package:appwrite_boilerplate/app/helper/routes/app_router.dart';
import 'package:get/get.dart';

/// Route-level gate for the admin area.
///
/// SECURITY: this only decides which screen to render. Hiding a screen is not
/// access control: in the real build the role is verified server-side (Appwrite
/// team/label checked inside every Function and enforced by collection
/// permissions), so a tampered client still cannot read or change anything.
abstract class AdminGuard {
  const AdminGuard._();

  static bool _isPublic(String path) =>
      path.startsWith('/policy') ||
      const {
        AppRouter.splash,
        AppRouter.forceUpdate,
        AppRouter.maintenance,
        AppRouter.login,
        AppRouter.signup,
        AppRouter.forgotPassword,
        AppRouter.resetPassword,
        AppRouter.language,
      }.contains(path);

  /// Redirect target for [path], or null to let the navigation proceed.
  static String? redirect(String path) {
    final session = Get.find<AdminSessionController>();
    if (path == AppRouter.notAuthorized) {
      return session.isAdmin ? AppRouter.dashboard : null;
    }
    if (_isPublic(path)) return null;
    // A completed Appwrite login also counts, so the login screen can return here.
    final signedIn = session.isSignedIn || Get.find<AuthController>().isLoggedIn;
    if (!signedIn) return AppRouter.login;
    if (!session.isAdmin) return AppRouter.notAuthorized;
    return null;
  }
}
