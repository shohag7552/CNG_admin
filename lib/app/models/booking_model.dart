import 'package:latlong2/latlong.dart';

enum VehicleType { cng, car }

/// Allowed transitions are enforced server-side; the UI only renders them.
enum BookingStatus {
  pending,
  receivingOffers,
  confirmed,
  driverArriving,
  inProgress,
  completed,
  cancelled,
  expired;

  static BookingStatus parse(String? v) => BookingStatus.values.firstWhere(
        (e) => e.name == v,
        orElse: () => BookingStatus.pending,
      );

  bool get isActive => index <= BookingStatus.inProgress.index;

  /// Statuses of a booking that has a driver assigned (shown as a "trip").
  bool get isTrip =>
      this == BookingStatus.confirmed ||
      this == BookingStatus.driverArriving ||
      this == BookingStatus.inProgress ||
      this == BookingStatus.completed;
}

class PlaceModel {
  final String name;
  final String address;
  final LatLng position;

  const PlaceModel({
    required this.name,
    required this.address,
    required this.position,
  });
}

/// One step of a booking's history (status timeline).
class BookingEvent {
  final BookingStatus status;
  final DateTime at;

  const BookingEvent(this.status, this.at);
}

/// A passenger's request, merged with the confirmed trip fields once a driver
/// is assigned (the backend keeps them as separate tables).
class BookingModel {
  final String id;
  final String passengerId;
  final String passengerName;
  final PlaceModel pickup;
  final PlaceModel destination;
  final VehicleType vehicleType;
  final int proposedFare;
  final BookingStatus status;
  final DateTime createdAt;
  final int? agreedFare;
  final String? driverId;
  final String? driverName;
  final String? vehiclePlate;
  final String? cancelReason;
  final List<BookingEvent> events;

  const BookingModel({
    required this.id,
    required this.passengerId,
    required this.passengerName,
    required this.pickup,
    required this.destination,
    required this.vehicleType,
    required this.proposedFare,
    required this.status,
    required this.createdAt,
    this.agreedFare,
    this.driverId,
    this.driverName,
    this.vehiclePlate,
    this.cancelReason,
    this.events = const [],
  });

  BookingModel copyWith({
    BookingStatus? status,
    int? agreedFare,
    String? driverId,
    String? driverName,
    String? vehiclePlate,
    String? cancelReason,
    List<BookingEvent>? events,
  }) =>
      BookingModel(
        id: id,
        passengerId: passengerId,
        passengerName: passengerName,
        pickup: pickup,
        destination: destination,
        vehicleType: vehicleType,
        proposedFare: proposedFare,
        status: status ?? this.status,
        createdAt: createdAt,
        agreedFare: agreedFare ?? this.agreedFare,
        driverId: driverId ?? this.driverId,
        driverName: driverName ?? this.driverName,
        vehiclePlate: vehiclePlate ?? this.vehiclePlate,
        cancelReason: cancelReason ?? this.cancelReason,
        events: events ?? this.events,
      );

  /// Fare to display: the locked agreed fare once confirmed, else the proposal.
  int get displayFare => agreedFare ?? proposedFare;
}
