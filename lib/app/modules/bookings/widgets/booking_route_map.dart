import 'package:appwrite_boilerplate/app/common/widgets/app_map_layers.dart';
import 'package:appwrite_boilerplate/app/models/booking_model.dart';
import 'package:appwrite_boilerplate/app/resources/colors.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

/// Small read-only map: pickup, destination and a straight route line.
class BookingRouteMap extends StatelessWidget {
  final PlaceModel pickup;
  final PlaceModel destination;

  const BookingRouteMap({super.key, required this.pickup, required this.destination});

  Widget _pin(IconData icon, Color color) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2.5),
          boxShadow: [BoxShadow(color: ColorResource.shadowMedium, blurRadius: 6)],
        ),
        child: Icon(icon, color: color, size: 22),
      );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Constants.radiusLarge),
      child: SizedBox(
        height: Constants.mapHeight,
        child: FlutterMap(
          options: MapOptions(
            initialCameraFit: CameraFit.bounds(
              bounds: LatLngBounds.fromPoints([pickup.position, destination.position]),
              padding: const EdgeInsets.all(Constants.paddingSizeExtraLarge * 2),
            ),
            // No scroll-wheel zoom: it would hijack scrolling the page.
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.drag |
                  InteractiveFlag.pinchZoom |
                  InteractiveFlag.doubleTapZoom,
            ),
          ),
          children: [
            const AppTileLayer(),
            PolylineLayer(polylines: [
              Polyline(
                points: [pickup.position, destination.position],
                strokeWidth: 5,
                color: ColorResource.primaryDark,
              ),
            ]),
            MarkerLayer(markers: [
              Marker(
                point: pickup.position,
                width: Constants.mapPinSize,
                height: Constants.mapPinSize,
                child: _pin(Icons.my_location_rounded, ColorResource.primaryDark),
              ),
              Marker(
                point: destination.position,
                width: Constants.mapPinSize,
                height: Constants.mapPinSize,
                child: _pin(Icons.flag_rounded, ColorResource.accentDark),
              ),
            ]),
            const Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.all(Constants.paddingSizeExtraSmall),
                child: MapAttribution(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
