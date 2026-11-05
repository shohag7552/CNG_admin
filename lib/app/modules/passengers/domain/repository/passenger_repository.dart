import 'package:appwrite_boilerplate/app/helper/mock_admin_store.dart';
import 'package:appwrite_boilerplate/app/models/audit_log_model.dart';
import 'package:appwrite_boilerplate/app/models/page_result.dart';
import 'package:appwrite_boilerplate/app/models/passenger_model.dart';
import 'package:appwrite_boilerplate/app/modules/passengers/domain/repository/passenger_repo_interface.dart';

class PassengerRepository implements PassengerRepoInterface {
  final MockAdminStore store;
  final Duration tick;

  PassengerRepository({required this.store, this.tick = const Duration(milliseconds: 500)});

  @override
  Future<PageResult<PassengerModel>> getPassengers({
    String query = '',
    bool? isActive,
    required int offset,
    required int limit,
  }) async {
    await Future<void>.delayed(tick);
    final q = query.trim().toLowerCase();
    final all = store.passengers.where((p) {
      if (isActive != null && p.isActive != isActive) return false;
      return q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.phone.contains(q) ||
          p.email.toLowerCase().contains(q);
    }).toList();
    return PageResult(all.skip(offset).take(limit).toList(), all.length);
  }

  @override
  Future<PassengerModel?> getPassenger(String id) async {
    await Future<void>.delayed(tick);
    return store.passengers.where((p) => p.id == id).firstOrNull;
  }

  @override
  Future<PassengerModel> setPassengerSuspended(
    String id, {
    required bool suspended,
    required String reason,
  }) async {
    await Future<void>.delayed(tick);
    final i = store.passengers.indexWhere((p) => p.id == id);
    if (i < 0) throw StateError('not_found');
    final p = store.passengers[i];
    if (p.isActive != suspended) throw StateError('invalid_transition');
    store.addAudit(
      suspended ? AuditAction.passengerSuspended : AuditAction.passengerReactivated,
      'passenger',
      id,
      reason: reason,
    );
    return store.passengers[i] = p.copyWith(
      isActive: !suspended,
      suspensionReason: suspended ? reason : p.suspensionReason,
    );
  }
}
