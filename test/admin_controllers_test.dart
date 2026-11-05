import 'package:appwrite_boilerplate/app/controllers/audit_controller.dart';
import 'package:appwrite_boilerplate/app/controllers/bookings_controller.dart';
import 'package:appwrite_boilerplate/app/controllers/business_settings_controller.dart';
import 'package:appwrite_boilerplate/app/controllers/drivers_controller.dart';
import 'package:appwrite_boilerplate/app/helper/mock_admin_store.dart';
import 'package:appwrite_boilerplate/app/models/audit_log_model.dart';
import 'package:appwrite_boilerplate/app/models/booking_model.dart';
import 'package:appwrite_boilerplate/app/models/business_settings_model.dart';
import 'package:appwrite_boilerplate/app/models/driver_profile_model.dart';
import 'package:appwrite_boilerplate/app/modules/audit/domain/repository/audit_repository.dart';
import 'package:appwrite_boilerplate/app/modules/bookings/domain/repository/booking_repository.dart';
import 'package:appwrite_boilerplate/app/modules/business_settings/domain/repository/business_settings_repository.dart';
import 'package:appwrite_boilerplate/app/modules/drivers/domain/repository/driver_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockAdminStore store;
  late AuditController audit;

  setUp(() {
    store = MockAdminStore();
    audit = AuditController(
        auditRepoInterface: AuditRepository(store: store, tick: Duration.zero));
  });

  // The seeded dataset has drv_1..drv_4 pending verification.
  Future<DriversController> driversOn(String id) async {
    final c = DriversController(
        driverRepoInterface: DriverRepository(store: store, tick: Duration.zero));
    await c.loadDriver(id);
    return c;
  }

  group('driver review', () {
    test('reject requires a non-empty reason and changes nothing without one', () async {
      final c = await driversOn('drv_1');
      final auditBefore = store.audit.length;

      expect(await c.reject('   '), isNotNull);
      expect(c.driver!.verificationStatus, VerificationStatus.pending);
      expect(store.audit.length, auditBefore);

      expect(await c.reject('Licence expired'), isNull);
      expect(c.driver!.verificationStatus, VerificationStatus.rejected);
      expect(c.driver!.rejectionReason, 'Licence expired');
      expect(store.audit.first.action, AuditAction.driverRejected);
      expect(store.audit.first.reason, 'Licence expired');
    });

    test('approve updates the status and writes an audit entry', () async {
      final c = await driversOn('drv_2');
      expect(await c.approve(), isNull);
      expect(c.driver!.verificationStatus, VerificationStatus.approved);
      expect(store.drivers.firstWhere((d) => d.id == 'drv_2').verificationStatus,
          VerificationStatus.approved);

      await audit.load();
      expect(audit.items.first.action, AuditAction.driverApproved);
      expect(audit.items.first.targetId, 'drv_2');
    });

    test('suspend needs a reason and is audited; a second suspend is refused', () async {
      final c = await driversOn('drv_6');
      expect(await c.setSuspended(true, ''), isNotNull);
      expect(c.driver!.isActive, isTrue);

      expect(await c.setSuspended(true, 'Complaints'), isNull);
      expect(c.driver!.isActive, isFalse);
      expect(store.audit.first.action, AuditAction.driverSuspended);

      expect(await c.setSuspended(true, 'Again'), isNotNull);
    });

    test('list filters by verification status', () async {
      final c = DriversController(
          driverRepoInterface: DriverRepository(store: store, tick: Duration.zero));
      c.setVerification(VerificationStatus.pending);
      await c.load();
      expect(c.total, 4);
      expect(c.items.every((d) => d.verificationStatus == VerificationStatus.pending), isTrue);
    });
  });

  group('business settings', () {
    late BusinessSettingsController c;

    setUp(() async {
      c = BusinessSettingsController(
          settingsRepoInterface:
              BusinessSettingsRepository(store: store, tick: Duration.zero));
      await c.load();
    });

    test('a default radius above the maximum is rejected and not saved', () async {
      c.edit((d) => d.copyWith(defaultSearchRadiusKm: 20, maxSearchRadiusKm: 10));
      expect(c.errors['defaultSearchRadiusKm'], 'default_radius_exceeds_max');
      expect(c.isValid, isFalse);

      final before = store.audit.length;
      expect(await c.save(), isNotNull);
      expect(store.settings.defaultSearchRadiusKm, 3);
      expect(store.audit.length, before);
    });

    test('the last enabled vehicle type cannot be disabled', () async {
      c.toggleVehicle(VehicleType.cng, false);
      expect(c.draft!.enabledVehicleTypes, {VehicleType.car});
      c.toggleVehicle(VehicleType.car, false);
      expect(c.draft!.enabledVehicleTypes, {VehicleType.car});

      // Validation still rejects an empty set built any other way.
      final empty = c.draft!.copyWith(enabledVehicleTypes: {});
      expect(empty.validate()['enabledVehicleTypes'], 'one_vehicle_required');
    });

    test('out-of-range values are rejected', () {
      c.edit((d) => d.copyWith(bookingExpirySeconds: 5));
      expect(c.errors['bookingExpirySeconds'], 'out_of_range');
    });

    test('a valid save persists, clears the unsaved flag and is audited', () async {
      c.edit((d) => d.copyWith(maxSearchRadiusKm: 15));
      expect(c.hasUnsavedChanges, isTrue);
      expect(await c.save(), isNull);
      expect(c.hasUnsavedChanges, isFalse);
      expect(store.settings.maxSearchRadiusKm, 15);
      expect(store.audit.first.action, AuditAction.settingsUpdated);
      expect(BusinessSettingsModel.currency, 'BDT');
    });
  });

  group('booking cancel', () {
    late BookingsController c;

    setUp(() {
      c = BookingsController(
          bookingRepoInterface: BookingRepository(store: store, tick: Duration.zero));
    });

    String activeId() => store.bookings.firstWhere((b) => b.status.isActive).id;

    test('requires a reason, then cancels and writes an audit entry', () async {
      final id = activeId();
      await c.loadBooking(id);
      final before = store.audit.length;

      expect(await c.cancelBooking(' '), isNotNull);
      expect(c.booking!.status.isActive, isTrue);
      expect(store.audit.length, before);

      expect(await c.cancelBooking('Passenger unreachable'), isNull);
      expect(c.booking!.status, BookingStatus.cancelled);
      expect(c.booking!.cancelReason, 'Passenger unreachable');
      expect(c.booking!.events.last.status, BookingStatus.cancelled);
      expect(store.audit.first.action, AuditAction.bookingCancelled);
      expect(store.audit.first.targetId, id);
    });

    test('a finished booking cannot be cancelled', () async {
      final done = store.bookings.firstWhere((b) => b.status == BookingStatus.completed);
      await c.loadBooking(done.id);
      expect(await c.cancelBooking('Late dispute'), isNotNull);
      expect(c.booking!.status, BookingStatus.completed);
    });

    test('trips list only contains trip statuses', () async {
      final t = TripsController(
          bookingRepoInterface: BookingRepository(store: store, tick: Duration.zero));
      await t.load();
      expect(t.items, isNotEmpty);
      expect(t.items.every((b) => b.status.isTrip || b.status == BookingStatus.cancelled), isTrue);
    });
  });
}
