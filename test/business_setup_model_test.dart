import 'package:appwrite_boilerplate/app/models/business_setup_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('compareVersions is numeric and pads missing segments', () {
    expect(BusinessSetupModel.compareVersions('1.2', '1.2.0'), 0);
    expect(BusinessSetupModel.compareVersions('1.10.0', '1.9.9'), greaterThan(0));
    expect(BusinessSetupModel.compareVersions('1.0.0', '1.0.1'), lessThan(0));
    expect(BusinessSetupModel.compareVersions('1.x', '1.0'), 0);
  });

  test('force update fails open and respects the switch', () {
    const off = BusinessSetupModel(appMinVersion: '9.0.0');
    expect(off.requiresForceUpdate('1.0.0'), isFalse);

    const blank = BusinessSetupModel(isForceUpdateActive: true, appMinVersion: ' ');
    expect(blank.requiresForceUpdate('1.0.0'), isFalse);

    const on = BusinessSetupModel(isForceUpdateActive: true, appMinVersion: '1.2.0');
    expect(on.requiresForceUpdate('1.1.9'), isTrue);
    expect(on.requiresForceUpdate('1.2.0'), isFalse);
  });

  test('fromJson maps Appwrite columns', () {
    final m = BusinessSetupModel.fromJson({
      '\$id': 'x',
      'business_name': 'Acme',
      'store_latitude': 23,
      'location_iq_key': 'pk.abc',
      'is_maintenance_mode_on': true,
    });
    expect(m.businessName, 'Acme');
    expect(m.latitude, 23.0);
    expect(m.locationIqKey, 'pk.abc');
    expect(m.isMaintenanceModeOn, isTrue);
  });
}
