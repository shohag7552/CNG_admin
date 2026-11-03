import 'package:appwrite_boilerplate/app/resources/constants.dart';

/// Appwrite ids in one place. Project-level ids come from [Constants]; table
/// (collection) ids are listed here — add one line per new table.
class AppwriteConfig {
  static const String projectId = Constants.projectId;
  static const String endpoint = Constants.endpoint;

  /// Deployed Flutter web build. MUST be registered as a **Web platform** in
  /// the Appwrite project: `account.createRecovery` validates its `url`
  /// against those hostnames, even when called from Android/iOS.
  static const String webAppBaseUrl = Constants.webBaseUrl;

  /// Page Appwrite links to in the password-recovery email (it appends
  /// `?userId=…&secret=…&expire=…`). Keep the path in sync with
  /// `AppRouter.resetPassword`, the `<data android:pathPrefix>` in
  /// `AndroidManifest.xml`, and `web/.well-known/apple-app-site-association`.
  static const String passwordRecoveryUrl = '${Constants.webBaseUrl}/reset-password';
  static const String databaseId = Constants.databaseId;
  static const String dbId = Constants.dbId;
  static const String storageBucketId = Constants.storageBucketId;
  static const String messagingProviderId = Constants.messagingProviderId;
  static const String notificationFunctionId = Constants.notificationFunctionId;
  static const String topicId = Constants.topicId;

  // ── Table ids ──
  static const String usersCollection = 'users';
  static const String businessSetup = 'business_setup';
  static const String storeSetup = 'store_setup';
  static const String addressesCollection = 'addresses';
  static const String notificationsCollection = 'notifications';
  static const String privacyPolicyCollection = 'privacy_policy';

  /// Example feature table — rename/delete with `modules/example`.
  static const String itemsCollection = 'items';
}
