import 'package:appwrite_boilerplate/app/models/booking_model.dart';

enum OfferStatus { pending, accepted, rejected, expired }

/// A driver's response to a booking: accept the proposed fare, or counter.
class OfferModel {
  final String id;
  final String bookingId;
  final String driverId;
  final String driverName;
  final double rating;
  final int tripCount;
  final VehicleType vehicleType;
  final String vehiclePlate;
  final int offeredFare;
  final bool isCounteroffer;
  final OfferStatus status;

  const OfferModel({
    required this.id,
    required this.bookingId,
    required this.driverId,
    required this.driverName,
    required this.rating,
    required this.tripCount,
    required this.vehicleType,
    required this.vehiclePlate,
    required this.offeredFare,
    required this.isCounteroffer,
    required this.status,
  });
}
