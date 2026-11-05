import 'package:appwrite_boilerplate/app/models/page_result.dart';
import 'package:appwrite_boilerplate/app/models/passenger_model.dart';

abstract class PassengerRepoInterface {
  /// [isActive]: null = all, true = active, false = suspended.
  Future<PageResult<PassengerModel>> getPassengers({
    String query = '',
    bool? isActive,
    required int offset,
    required int limit,
  });

  Future<PassengerModel?> getPassenger(String id);

  Future<PassengerModel> setPassengerSuspended(
    String id, {
    required bool suspended,
    required String reason,
  });
}
