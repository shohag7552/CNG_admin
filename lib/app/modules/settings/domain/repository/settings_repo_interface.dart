import 'package:appwrite_boilerplate/app/models/business_setup_model.dart';
import 'package:appwrite_boilerplate/app/models/store_setup_model.dart';

abstract class SettingsRepoInterface {
  Future<BusinessSetupModel?> getBusinessSetup();
  Future<StoreSetupModel?> getStoreSetup();
}
