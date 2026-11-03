import 'dart:convert';

import 'package:appwrite_boilerplate/app/appwrite/appwrite_service.dart';
import 'package:appwrite_boilerplate/app/controllers/address_controller.dart';
import 'package:appwrite_boilerplate/app/controllers/auth_controller.dart';
import 'package:appwrite_boilerplate/app/controllers/item_controller.dart';
import 'package:appwrite_boilerplate/app/controllers/localization_controller.dart';
import 'package:appwrite_boilerplate/app/controllers/notification_controller.dart';
import 'package:appwrite_boilerplate/app/controllers/policy_controller.dart';
import 'package:appwrite_boilerplate/app/controllers/profile_controller.dart';
import 'package:appwrite_boilerplate/app/controllers/settings_controller.dart';
import 'package:appwrite_boilerplate/app/controllers/splash_controller.dart';
import 'package:appwrite_boilerplate/app/controllers/update_controller.dart';
import 'package:appwrite_boilerplate/app/modules/address/domain/repository/address_repo_interface.dart';
import 'package:appwrite_boilerplate/app/modules/address/domain/repository/address_repository.dart';
import 'package:appwrite_boilerplate/app/modules/auth/domain/repository/auth_repo_interface.dart';
import 'package:appwrite_boilerplate/app/modules/auth/domain/repository/auth_repository.dart';
import 'package:appwrite_boilerplate/app/modules/example/domain/repository/item_repo_interface.dart';
import 'package:appwrite_boilerplate/app/modules/example/domain/repository/item_repository.dart';
import 'package:appwrite_boilerplate/app/modules/notification/domain/repository/notification_repo_interface.dart';
import 'package:appwrite_boilerplate/app/modules/notification/domain/repository/notification_repository.dart';
import 'package:appwrite_boilerplate/app/modules/policies/domain/repository/policy_repo_interface.dart';
import 'package:appwrite_boilerplate/app/modules/policies/domain/repository/policy_repository.dart';
import 'package:appwrite_boilerplate/app/modules/profile/domain/repository/profile_repo_interface.dart';
import 'package:appwrite_boilerplate/app/modules/profile/domain/repository/profile_repository.dart';
import 'package:appwrite_boilerplate/app/modules/settings/domain/repository/settings_repo_interface.dart';
import 'package:appwrite_boilerplate/app/modules/settings/domain/repository/settings_repository.dart';
import 'package:appwrite_boilerplate/app/modules/splash/domain/repository/splash_repo_interface.dart';
import 'package:appwrite_boilerplate/app/modules/splash/domain/repository/splash_repository.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wires every repository + controller, then loads the translation maps.
///
/// New feature: build `XRepoInterface x = XRepository(...)`,
/// `Get.lazyPut(() => x)`, then `Get.lazyPut(() => XController(xRepoInterface: Get.find()))`.
Future<Map<String, Map<String, String>>> initializeDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.lazyPut(() => sharedPreferences, fenix: true);

  Get.lazyPut(() => LocalizationController(sharedPreferences: Get.find()));
  Get.lazyPut(() => AppwriteService());

  /// Repositories
  AuthRepoInterface authRepoInterface = AuthRepository(
    sharedPreferences: sharedPreferences,
    appwriteService: Get.find(),
  );
  Get.lazyPut(() => authRepoInterface);

  SplashRepoInterface splashRepoInterface = SplashRepository(
    sharedPreferences: sharedPreferences,
  );
  Get.lazyPut(() => splashRepoInterface);

  SettingsRepoInterface settingsRepoInterface = SettingsRepository(
    appwriteService: Get.find(),
  );
  Get.lazyPut(() => settingsRepoInterface);

  ProfileRepoInterface profileRepoInterface = ProfileRepository(
    appwriteService: Get.find(),
  );
  Get.lazyPut(() => profileRepoInterface);

  AddressRepoInterface addressRepoInterface = AddressRepository(
    appwriteService: Get.find(),
  );
  Get.lazyPut(() => addressRepoInterface);

  NotificationRepoInterface notificationRepoInterface = NotificationRepository(
    appwriteService: Get.find(),
  );
  Get.lazyPut(() => notificationRepoInterface);

  PolicyRepoInterface policyRepoInterface = PolicyRepository(
    appwriteService: Get.find(),
  );
  Get.lazyPut(() => policyRepoInterface);

  ItemRepoInterface itemRepoInterface = ItemRepository(
    appwriteService: Get.find(),
  );
  Get.lazyPut(() => itemRepoInterface);

  /// Controllers
  Get.lazyPut(() => AuthController(authRepoInterface: Get.find()));
  Get.lazyPut(() => SplashController(splashRepositoryInterface: Get.find()));
  Get.lazyPut(() => SettingsController(settingsRepoInterface: Get.find()));
  Get.lazyPut(() => UpdateController());
  Get.lazyPut(() => ProfileController(profileRepoInterface: Get.find()));
  Get.lazyPut(() => AddressController(addressRepoInterface: Get.find()));
  Get.lazyPut(
    () => NotificationController(notificationRepoInterface: Get.find()),
  );
  Get.lazyPut(() => PolicyController(policyRepoInterface: Get.find()));
  Get.lazyPut(() => ItemController(itemRepoInterface: Get.find()));

  /// Retrieving localized data
  Map<String, Map<String, String>> languages = {};
  for (LanguageModel languageModel in Constants.languages) {
    String jsonStringValues = await rootBundle.loadString(
      'assets/language/${languageModel.languageCode}.json',
    );
    Map<String, dynamic> mappedJson = jsonDecode(jsonStringValues);
    Map<String, String> json = {};
    mappedJson.forEach((key, value) {
      json[key] = value.toString();
    });
    languages['${languageModel.languageCode}_${languageModel.countryCode}'] =
        json;
  }
  return languages;
}
