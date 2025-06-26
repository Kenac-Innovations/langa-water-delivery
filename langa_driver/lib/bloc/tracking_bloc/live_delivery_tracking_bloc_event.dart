import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class LiveDeliveryTrackingEvent extends Equatable {
  const LiveDeliveryTrackingEvent();

  @override
  List<Object?> get props => [];
}

class InitializeTracking extends LiveDeliveryTrackingEvent {
  const InitializeTracking();
}

// Internal event to periodically update location and check distance
class CheckPositionAndDistance extends LiveDeliveryTrackingEvent {
  const CheckPositionAndDistance();
}

// Event when proximity is detected and we need to stop
class ProximityDetectedAndStop extends LiveDeliveryTrackingEvent {
  const ProximityDetectedAndStop();
}

class OpenMapsRequested extends LiveDeliveryTrackingEvent {
  final Position? currentPosition;
  final LatLng destinationCoordinates;
  final String destinationAddressForMaps;

  const OpenMapsRequested({
    required this.currentPosition,
    required this.destinationCoordinates,
    required this.destinationAddressForMaps,
  });

  @override
  List<Object?> get props =>
      [currentPosition, destinationCoordinates, destinationAddressForMaps];
}

