import 'package:appwrite_boilerplate/app/models/audit_log_model.dart';
import 'package:appwrite_boilerplate/app/models/booking_model.dart';
import 'package:appwrite_boilerplate/app/models/business_settings_model.dart';
import 'package:appwrite_boilerplate/app/models/driver_profile_model.dart';
import 'package:appwrite_boilerplate/app/models/offer_model.dart';
import 'package:appwrite_boilerplate/app/models/passenger_model.dart';
import 'package:latlong2/latlong.dart';

/// UI-phase "database": one in-memory dataset shared by every mock repository,
/// so an action in one screen (approve a driver, cancel a booking) is visible
/// everywhere, and the audit entry the real server Function would write
/// appears in the audit log. Delete this file when the Appwrite-backed
/// repositories replace the mocks.
class MockAdminStore {
  /// The signed-in admin recorded on audit entries.
  static const String actorName = 'Nadia Rahman';

  final DateTime now;
  final List<DriverProfileModel> drivers = [];
  final List<PassengerModel> passengers = [];
  final List<BookingModel> bookings = [];
  final Map<String, List<OfferModel>> offers = {};
  final List<AuditLogModel> audit = []; // newest first

  BusinessSettingsModel settings = const BusinessSettingsModel(
    businessName: 'CNG Go',
    supportPhone: '+880 1700-000000',
    supportEmail: 'support@cnggo.example',
    enabledVehicleTypes: {VehicleType.cng, VehicleType.car},
    defaultSearchRadiusKm: 3,
    maxSearchRadiusKm: 10,
    bookingExpirySeconds: 90,
    driverLocationFreshnessSeconds: 60,
  );

  int _auditSeq = 0;

  MockAdminStore({DateTime? now}) : now = now ?? DateTime.now() {
    _seed();
  }

  void addAudit(AuditAction action, String targetType, String targetId,
      {String? reason}) {
    audit.insert(
      0,
      AuditLogModel(
        id: 'au_${++_auditSeq}',
        adminName: actorName,
        action: action,
        targetType: targetType,
        targetId: targetId,
        reason: reason,
        createdAt: DateTime.now(),
      ),
    );
  }

  static const _places = <PlaceModel>[
    PlaceModel(name: 'Dhanmondi 27', address: 'Road 27, Dhanmondi, Dhaka', position: LatLng(23.7561, 90.3742)),
    PlaceModel(name: 'Farmgate', address: 'Farmgate, Tejgaon, Dhaka', position: LatLng(23.7576, 90.3894)),
    PlaceModel(name: 'Bashundhara City', address: 'Panthapath, Dhaka', position: LatLng(23.7513, 90.3911)),
    PlaceModel(name: 'Gulshan 1', address: 'Gulshan Avenue, Dhaka', position: LatLng(23.7806, 90.4167)),
    PlaceModel(name: 'Motijheel', address: 'Motijheel C/A, Dhaka', position: LatLng(23.7330, 90.4172)),
    PlaceModel(name: 'Uttara Sector 7', address: 'Uttara, Dhaka', position: LatLng(23.8759, 90.3795)),
  ];

  static const _driverNames = [
    'Rahim Uddin', 'Karim Mia', 'Sohel Rana', 'Jamal Hossain', 'Faruk Ahmed',
    'Babul Sheikh', 'Imran Khan', 'Shafiq Alam', 'Nasir Uddin', 'Delwar Hossain',
    'Monir Hasan', 'Tarek Aziz', 'Habib Molla', 'Ruhul Amin',
  ];

  static const _passengerNames = [
    'Ayesha Siddika', 'Tanvir Ahmed', 'Mitu Akter', 'Sabbir Hasan',
    'Nusrat Jahan', 'Arif Chowdhury', 'Rima Begum', 'Zahid Hasan',
    'Farhana Yasmin', 'Imtiaz Rahman', 'Sharmin Sultana', 'Kamrul Islam',
  ];

  void _seed() {
    for (var i = 0; i < _driverNames.length; i++) {
      final car = i % 4 == 3;
      drivers.add(DriverProfileModel(
        id: 'drv_${i + 1}',
        name: _driverNames[i],
        phone: '+880 17${10000000 + (i * 1234567) % 90000000}',
        vehicleType: car ? VehicleType.car : VehicleType.cng,
        registration: 'Dhaka Metro-${car ? 'GA' : 'HA'} ${11 + i * 4}-${3000 + i * 417}',
        vehicleModel: car ? 'Toyota Axio' : 'Bajaj RE CNG',
        verificationStatus: i < 4
            ? VerificationStatus.pending
            : i == 4
                ? VerificationStatus.rejected
                : VerificationStatus.approved,
        availabilityStatus: i % 7 == 0
            ? AvailabilityStatus.onTrip
            : i % 2 == 0
                ? AvailabilityStatus.online
                : AvailabilityStatus.offline,
        isActive: i != 9,
        rating: 4.3 + (i % 7) / 10,
        tripCount: i < 4 ? 0 : 120 + i * 97,
        joinedAt: now.subtract(Duration(days: 20 + i * 23)),
        rejectionReason: i == 4 ? 'Driving licence photo is unreadable' : null,
        suspensionReason: i == 9 ? 'Repeated rider complaints' : null,
      ));
    }
    for (var i = 0; i < _passengerNames.length; i++) {
      passengers.add(PassengerModel(
        id: 'pas_${i + 1}',
        name: _passengerNames[i],
        phone: '+880 18${10000000 + (i * 7654321) % 90000000}',
        email: 'user${i + 1}@example.com',
        isActive: i != 6,
        tripCount: 3 + i * 5,
        joinedAt: now.subtract(Duration(days: 10 + i * 17)),
        suspensionReason: i == 6 ? 'Fake bookings' : null,
      ));
    }
    _seedBookings();
    audit
      ..add(AuditLogModel(
        id: 'au_0b',
        adminName: actorName,
        action: AuditAction.driverRejected,
        targetType: 'driver',
        targetId: 'drv_5',
        reason: 'Driving licence photo is unreadable',
        createdAt: now.subtract(const Duration(days: 2)),
      ))
      ..add(AuditLogModel(
        id: 'au_0a',
        adminName: actorName,
        action: AuditAction.driverSuspended,
        targetType: 'driver',
        targetId: 'drv_10',
        reason: 'Repeated rider complaints',
        createdAt: now.subtract(const Duration(days: 4)),
      ));
  }

  void _seedBookings() {
    final approved = drivers
        .where((d) => d.verificationStatus == VerificationStatus.approved)
        .toList();
    final todayStatuses = [
      BookingStatus.receivingOffers,
      BookingStatus.confirmed,
      BookingStatus.driverArriving,
      BookingStatus.inProgress,
      BookingStatus.completed,
      BookingStatus.completed,
    ];
    var seq = 1000;
    for (var d = 0; d < 30; d++) {
      final count = d == 0 ? todayStatuses.length : 2 + (d * 7) % 5;
      for (var j = 0; j < count; j++) {
        seq++;
        final k = d * 7 + j;
        final status = d == 0
            ? todayStatuses[j]
            : k % 7 == 0
                ? BookingStatus.cancelled
                : k % 11 == 3
                    ? BookingStatus.expired
                    : BookingStatus.completed;
        final pickIdx = k % _places.length;
        final destIdx = (k + 2) % _places.length;
        final car = k % 3 == 0;
        final fare = 80 + ((k * 37) % 40) * 10;
        final created = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: d))
            .add(Duration(hours: 7 + j * 2, minutes: (k * 13) % 60));
        final createdAt = created.isAfter(now)
            ? now.subtract(Duration(minutes: 20 + j * 15))
            : created;
        final pas = passengers[k % passengers.length];
        final matching = approved
            .where((x) => x.vehicleType == (car ? VehicleType.car : VehicleType.cng))
            .toList();
        final drv = matching[k % matching.length];
        final hasDriver = status.isTrip;
        final agreed = hasDriver ? fare + (k % 3) * 10 : null;
        final id = 'bk_$seq';

        final steps = switch (status) {
          BookingStatus.completed => const [
              (BookingStatus.receivingOffers, 0),
              (BookingStatus.confirmed, 4),
              (BookingStatus.driverArriving, 6),
              (BookingStatus.inProgress, 14),
              (BookingStatus.completed, 34),
            ],
          BookingStatus.inProgress => const [
              (BookingStatus.receivingOffers, 0),
              (BookingStatus.confirmed, 4),
              (BookingStatus.driverArriving, 6),
              (BookingStatus.inProgress, 14),
            ],
          BookingStatus.driverArriving => const [
              (BookingStatus.receivingOffers, 0),
              (BookingStatus.confirmed, 4),
              (BookingStatus.driverArriving, 6),
            ],
          BookingStatus.confirmed => const [
              (BookingStatus.receivingOffers, 0),
              (BookingStatus.confirmed, 4),
            ],
          BookingStatus.cancelled => const [
              (BookingStatus.receivingOffers, 0),
              (BookingStatus.cancelled, 5),
            ],
          BookingStatus.expired => const [
              (BookingStatus.receivingOffers, 0),
              (BookingStatus.expired, 2),
            ],
          _ => const [(BookingStatus.receivingOffers, 0)],
        };

        final booking = BookingModel(
          id: id,
          passengerId: pas.id,
          passengerName: pas.name,
          pickup: _places[pickIdx],
          destination: _places[destIdx],
          vehicleType: car ? VehicleType.car : VehicleType.cng,
          proposedFare: fare,
          status: status,
          createdAt: createdAt,
          agreedFare: agreed,
          driverId: hasDriver ? drv.id : null,
          driverName: hasDriver ? drv.name : null,
          vehiclePlate: hasDriver ? drv.registration : null,
          cancelReason:
              status == BookingStatus.cancelled ? 'Passenger changed plans' : null,
          events: [
            for (final s in steps)
              BookingEvent(s.$1, createdAt.add(Duration(minutes: s.$2))),
          ],
        );
        bookings.add(booking);

        final others = matching.where((x) => x.id != drv.id).toList();
        offers[id] = [
          for (var o = 0; o < 3; o++)
            () {
              final dr = o == 0 && hasDriver ? drv : others[(k + o) % others.length];
              final accepted = hasDriver && dr.id == drv.id;
              return OfferModel(
                id: 'of_${id}_$o',
                bookingId: id,
                driverId: dr.id,
                driverName: dr.name,
                rating: dr.rating,
                tripCount: dr.tripCount,
                vehicleType: dr.vehicleType,
                vehiclePlate: dr.registration,
                offeredFare: accepted ? agreed! : fare + o * 10,
                isCounteroffer: accepted ? agreed != fare : o != 1,
                status: accepted
                    ? OfferStatus.accepted
                    : status.isActive && !hasDriver
                        ? OfferStatus.pending
                        : (status == BookingStatus.expired ||
                                status == BookingStatus.cancelled)
                            ? OfferStatus.expired
                            : OfferStatus.rejected,
              );
            }(),
        ];
      }
    }
    bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
