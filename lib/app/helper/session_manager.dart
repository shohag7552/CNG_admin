import 'package:appwrite_boilerplate/app/controllers/auth_controller.dart';
import 'package:appwrite_boilerplate/app/controllers/profile_controller.dart';
import 'package:get/get.dart';

/// Whether a user session is currently active.
///
/// Auth-scoped controller fetches guard on this so that **no user-only Appwrite
/// request runs while the app is browsed as a guest**. The value is the cached
/// `AuthController.isLoggedIn`, which is primed at startup and flipped on
/// login / signup / logout — so guarded fetches start working the moment the
/// user signs in.
bool isUserLoggedIn() =>
    Get.isRegistered<AuthController>() && Get.find<AuthController>().isLoggedIn;

/// Coordinates user-scoped controller state across a login / logout.
abstract class SessionManager {
  const SessionManager._();

  /// Loads the app-wide user data immediately after a successful login/signup.
  /// Add every user-scoped controller that must be warm on the dashboard here;
  /// page-specific data should load when its page opens.
  static void loadUserData() {
    _safe(() => Get.find<ProfileController>().fetchUserProfile());
  }

  /// Clears locally cached user data on logout so a guest never sees stale
  /// info. Add a `clearLocal()` call for every user-scoped controller.
  static void clearUserData() {
    _safe(() => Get.find<ProfileController>().clearLocal());
  }

  static void _safe(void Function() action) {
    try {
      action();
    } catch (_) {
      // A controller may not be registered yet — ignore; it will load its own
      // data (guarded by [isUserLoggedIn]) when first used.
    }
  }
}
