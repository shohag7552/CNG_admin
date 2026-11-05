import 'package:appwrite_boilerplate/app/models/driver_profile_model.dart';
import 'package:appwrite_boilerplate/app/models/page_result.dart';

/// The controller depends on this abstraction, never on the implementation.
/// The only writes an admin may make are the four review/suspension actions;
/// each one is audited server-side.
abstract class DriverRepoInterface {
  Future<PageResult<DriverProfileModel>> getDrivers({
    String query = '',
    VerificationStatus? verification,
    AvailabilityStatus? availability,
    required int offset,
    required int limit,
  });

  Future<DriverProfileModel?> getDriver(String id);

  Future<DriverProfileModel> approveDriver(String id);

  Future<DriverProfileModel> rejectDriver(String id, String reason);

  Future<DriverProfileModel> setDriverSuspended(
    String id, {
    required bool suspended,
    required String reason,
  });
}
