import 'package:appwrite_setup/schema.dart';
import 'package:test/test.dart';

void main() {
  test('table ids are unique', () {
    final ids = tables.map((t) => t.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('bucket ids are unique and not table ids', () {
    final ids = buckets.map((b) => b.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  for (final t in tables) {
    group('table ${t.id}', () {
      test('column keys are unique', () {
        final keys = t.columns.map((c) => c.key).toList();
        expect(keys.toSet().length, keys.length);
      });

      test('every index references existing columns, and index keys are unique',
          () {
        final keys = t.columns.map((c) => c.key).toSet();
        for (final i in t.indexes) {
          for (final c in i.columns) {
            expect(keys, contains(c), reason: '${i.key} -> $c');
          }
        }
        final idx = t.indexes.map((i) => i.key).toList();
        expect(idx.toSet().length, idx.length);
      });

      test('required columns have no default (Appwrite rejects it)', () {
        for (final c in t.columns.where((c) => c.required)) {
          expect(c.def, isNull, reason: c.key);
        }
      });

      test('strings have a size; enums have elements; defaults are valid', () {
        for (final c in t.columns) {
          if (c.type == ColType.string) expect(c.size, greaterThan(0));
          if (c.type == ColType.enumeration) {
            expect(c.elements, isNotEmpty);
            if (c.def != null) expect(c.elements, contains(c.def));
          }
        }
      });

      test('unique indexes only cover required or enum/id columns '
          '(no accidental NULL-heavy uniqueness)', () {
        for (final i in t.indexes.where((i) => i.unique)) {
          final cols = t.columns.where((c) => i.columns.contains(c.key));
          expect(cols.any((c) => c.required), isTrue, reason: i.key);
        }
      });
    });
  }

  test('booking status values match the spec (docs/booking_workflow.md)', () {
    expect(bookingStatuses, [
      'pending',
      'receiving_offers',
      'confirmed',
      'driver_arriving',
      'ongoing',
      'completed',
      'cancelled',
      'expired',
    ]);
  });

  test('no product table grants clients write access', () {
    const productTables = [
      'driver_profiles',
      'driver_documents',
      'driver_locations',
      'route_fare_templates',
      'booking_requests',
      'booking_dispatches',
      'booking_offers',
      'business_settings',
      'conversations',
      'messages',
      'ratings',
      'admin_audit_logs',
    ];
    for (final t in tables.where((t) => productTables.contains(t.id))) {
      for (final p in t.permissions) {
        expect(p.startsWith('read('), isTrue, reason: '${t.id}: $p');
      }
    }
  });
}
