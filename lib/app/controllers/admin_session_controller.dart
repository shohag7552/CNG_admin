import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

enum AdminRole { admin, viewer }

class RouterRefresh extends ChangeNotifier {
  void ping() => notifyListeners();
}

/// Mock admin identity for the UI phase.
///
/// SECURITY: hiding screens is not access control. In the real build the role
/// comes from a server-verified source (Appwrite team/label checked in each
/// Function), and every repository call is re-authorised server-side. This
/// controller only decides which screens to *render*.
class AdminSessionController extends GetxController implements GetxService {
  String get name => 'Nadia Rahman';
  String get email => 'nadia@cnggo.example';

  AdminRole _role = AdminRole.admin;
  AdminRole get role => _role;
  bool get isAdmin => _role == AdminRole.admin;

  bool _signedIn = true;
  bool get isSignedIn => _signedIn;

  /// Pinged on any change so the router re-runs its redirect (see AdminGuard).
  final RouterRefresh routerRefresh = RouterRefresh();

  void _changed() {
    update();
    routerRefresh.ping();
  }

  /// Demo only: lets reviewers see the "not authorized" screen.
  void toggleDemoRole() {
    _role = isAdmin ? AdminRole.viewer : AdminRole.admin;
    _changed();
  }

  void signIn() {
    _signedIn = true;
    _changed();
  }

  void logout() {
    _signedIn = false;
    _changed();
  }
}
