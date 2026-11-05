import 'package:appwrite_boilerplate/app/models/booking_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Money is whole BDT everywhere in the app.
String bdt(int amount) => '৳$amount';

String fmtDateTime(DateTime d) => DateFormat.yMMMd().add_jm().format(d);

String fmtDate(DateTime d) => DateFormat.yMMMd().format(d);

String vehicleLabel(VehicleType v) => v == VehicleType.cng ? 'cng'.tr : 'car'.tr;

String percent(double ratio) => '${(ratio * 100).round()}%';
