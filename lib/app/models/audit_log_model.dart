enum AuditAction {
  driverApproved,
  driverRejected,
  driverSuspended,
  driverReactivated,
  passengerSuspended,
  passengerReactivated,
  bookingCancelled,
  settingsUpdated,
}

/// Written by the server-side function that performs the action; the admin UI
/// only reads it.
class AuditLogModel {
  final String id;
  final String adminName;
  final AuditAction action;

  /// 'driver' | 'passenger' | 'booking' | 'settings'
  final String targetType;
  final String targetId;
  final String? reason;
  final DateTime createdAt;

  const AuditLogModel({
    required this.id,
    required this.adminName,
    required this.action,
    required this.targetType,
    required this.targetId,
    required this.createdAt,
    this.reason,
  });
}
