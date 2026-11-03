import 'package:appwrite_boilerplate/app/models/business_setup_model.dart';
import 'package:appwrite_boilerplate/app/models/store_setup_model.dart';
import 'package:appwrite_boilerplate/app/modules/settings/domain/repository/settings_repo_interface.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart';

class SettingsController extends GetxController implements GetxService {
  final SettingsRepoInterface settingsRepoInterface;

  SettingsController({required this.settingsRepoInterface});

  BusinessSetupModel? _businessSetup;
  BusinessSetupModel? get businessSetup => _businessSetup;

  StoreSetupModel? _storeSetup;
  StoreSetupModel? get storeSetup => _storeSetup;

  /// Where a map opens when there is no saved or current location: the
  /// store's own location from business setup. Falls back to [Constants]
  /// only when the store hasn't set one (or setup failed to load).
  LatLng get defaultMapLocation {
    final lat = _businessSetup?.latitude;
    final lng = _businessSetup?.longitude;
    // 0,0 is the unset default of a numeric column, not a real store.
    if (lat != null && lng != null && !(lat == 0 && lng == 0)) {
      return LatLng(lat, lng);
    }
    return const LatLng(
      Constants.mapDefaultLatitude,
      Constants.mapDefaultLongitude,
    );
  }

  /// LocationIQ key: the remote one from business setup wins, else the
  /// compile-time [Constants.locationIqKey]. Empty means the free
  /// OpenStreetMap servers are used for map tiles and address lookups.
  String get locationIqKey {
    final remote = _businessSetup?.locationIqKey?.trim() ?? '';
    return remote.isNotEmpty ? remote : Constants.locationIqKey.trim();
  }
  bool get usesLocationIq => locationIqKey.isNotEmpty;

  String get mapTileUrl => usesLocationIq
      ? '${Constants.locationIqTileUrl}?key=$locationIqKey'
      : Constants.mapTileUrl;
  String get mapAttribution => usesLocationIq
      ? Constants.locationIqAttribution
      : Constants.mapAttribution;
  String get mapAttributionUrl => usesLocationIq
      ? Constants.locationIqAttributionUrl
      : Constants.mapAttributionUrl;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Fetch both business setup and store setup
  Future<bool> fetchSettings() async {
    _isLoading = true;
    update();

    try {
      // Fetch both in parallel for better performance
      final results = await Future.wait([
        settingsRepoInterface.getBusinessSetup(),
        settingsRepoInterface.getStoreSetup(),
      ]);

      _businessSetup = results[0] as BusinessSetupModel?;
      _storeSetup = results[1] as StoreSetupModel?;

      _isLoading = false;
      update();

      // Return true only if both are successfully fetched
      return _businessSetup != null && _storeSetup != null;
    } catch (e) {
      debugPrint('Error in fetchSettings: $e');
      _isLoading = false;
      update();
      return false;
    }
  }

  /// Fetch business setup only
  Future<bool> fetchBusinessSetup() async {
    try {
      _businessSetup = await settingsRepoInterface.getBusinessSetup();
      update();
      return _businessSetup != null;
    } catch (e) {
      debugPrint('Error fetching business setup: $e');
      return false;
    }
  }

  /// Fetch store setup only
  Future<bool> fetchStoreSetup() async {
    try {
      _storeSetup = await settingsRepoInterface.getStoreSetup();
      update();
      return _storeSetup != null;
    } catch (e) {
      debugPrint('Error fetching store setup: $e');
      return false;
    }
  }
}
