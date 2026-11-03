import 'package:appwrite_boilerplate/app/modules/splash/domain/repository/splash_repo_interface.dart';
import 'package:appwrite_boilerplate/app/controllers/settings_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class SplashController extends GetxController implements GetxService{
  SplashRepoInterface splashRepositoryInterface;
  SplashController({required this.splashRepositoryInterface});

  Future<void> saveIntroSeen(bool isSeen) async{
    await splashRepositoryInterface.saveIntroSeen(isSeen);
  }

  /// Fetch business and store setup data
  Future<bool> fetchSettings() async {
    try {
      // Use the settings controller to fetch data
      final settingsController = Get.find<SettingsController>();
      return await settingsController.fetchSettings();
    } catch (e) {
      debugPrint('Error fetching settings in SplashController: $e');
      return false;
    }
  }

  bool isIntroSeen() {
    return splashRepositoryInterface.isIntroSeen();
  }
}