import 'package:appwrite_boilerplate/app/helper/mock_admin_store.dart';
import 'package:appwrite_boilerplate/app/models/audit_log_model.dart';
import 'package:appwrite_boilerplate/app/models/driver_profile_model.dart';
import 'package:appwrite_boilerplate/app/models/page_result.dart';
import 'package:appwrite_boilerplate/app/modules/drivers/domain/repository/driver_repo_interface.dart';

/// UI-phase implementation over [MockAdminStore]. Swap it for the Appwrite
/// implementation (reads via listTable, writes via executeFunction) in
/// `dependencies.dart`; nothing above this layer changes.
class DriverRepository implements DriverRepoInterface {
  final MockAdminStore store;

  /// Pass `Duration.zero` in tests to skip the simulated latency.
  final Duration tick;

  DriverRepository({required this.store, this.tick = const Duration(milliseconds: 500)});

  @override
  Future<PageResult<DriverProfileModel>> getDrivers({
    String query = '',
    VerificationStatus? verification,
    AvailabilityStatus? availability,
    required int offset,
    required int limit,
  }) async {
    await Future<void>.delayed(tick);
    final q = query.trim().toLowerCase();
    final all = store.drivers.where((d) {
      if (verification != null && d.verificationStatus != verification) return false;
      if (availability != null && d.availabilityStatus != availability) return false;
      return q.isEmpty ||
          d.name.toLowerCase().contains(q) ||
          d.phone.contains(q) ||
          d.registration.toLowerCase().contains(q);
    }).toList();
    return PageResult(all.skip(offset).take(limit).toList(), all.length);
  }

  @override
  Future<DriverProfileModel?> getDriver(String id) async {
    await Future<void>.delayed(tick);
    return store.drivers.where((d) => d.id == id).firstOrNull;
  }

  DriverProfileModel _replace(DriverProfileModel d) {
    store.drivers[store.drivers.indexWhere((x) => x.id == d.id)] = d;
    return d;
  }

  Future<DriverProfileModel> _current(String id) async {
    await Future<void>.delayed(tick);
    final d = store.drivers.where((x) => x.id == id).firstOrNull;
    if (d == null) throw StateError('not_found');
    return d;
  }

  @override
  Future<DriverProfileModel> approveDriver(String id) async {
    final d = await _current(id);
    if (d.verificationStatus == VerificationStatus.approved) {
      throw StateError('invalid_transition');
    }
    store.addAudit(AuditAction.driverApproved, 'driver', id);
    return _replace(d.copyWith(verificationStatus: VerificationStatus.approved));
  }

  @override
  Future<DriverProfileModel> rejectDriver(String id, String reason) async {
    final d = await _current(id);
    if (d.verificationStatus != VerificationStatus.pending) {
      throw StateError('invalid_transition');
    }
    store.addAudit(AuditAction.driverRejected, 'driver', id, reason: reason);
    return _replace(d.copyWith(
      verificationStatus: VerificationStatus.rejected,
      rejectionReason: reason,
    ));
  }

  @override
  Future<DriverProfileModel> setDriverSuspended(
    String id, {
    required bool suspended,
    required String reason,
  }) async {
    final d = await _current(id);
    if (d.isActive != suspended) throw StateError('invalid_transition');
    store.addAudit(
      suspended ? AuditAction.driverSuspended : AuditAction.driverReactivated,
      'driver',
      id,
      reason: reason,
    );
    return _replace(d.copyWith(
      isActive: !suspended,
      suspensionReason: suspended ? reason : d.suspensionReason,
      // A suspended driver cannot stay online.
      availabilityStatus: suspended ? AvailabilityStatus.offline : null,
    ));
  }
}
