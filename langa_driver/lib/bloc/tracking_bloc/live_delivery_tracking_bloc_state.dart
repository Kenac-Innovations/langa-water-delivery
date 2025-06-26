import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

abstract class LiveDeliveryTrackingState extends Equatable {
  final String statusMessage;
  final Position? currentPosition;
  final double distanceToDestination;
  final bool isStopping; 

  const LiveDeliveryTrackingState({
    required this.statusMessage,
    this.currentPosition,
    this.distanceToDestination = double.infinity,
    this.isStopping = false,
  });

  @override
  List<Object?> get props =>
      [statusMessage, currentPosition, distanceToDestination, isStopping];
}

class TrackingInitial extends LiveDeliveryTrackingState {
  const TrackingInitial()
      : super(statusMessage: "Initializing live tracking...");
}

class TrackingActive extends LiveDeliveryTrackingState {
  const TrackingActive({
    required super.statusMessage,
    required super.currentPosition,
    required super.distanceToDestination,
  });
}

class TrackingStopping extends LiveDeliveryTrackingState {
  const TrackingStopping({
    required super.statusMessage,
    super.currentPosition,
    super.distanceToDestination, 
  }) : super(isStopping: true);
}

class TrackingStopped extends LiveDeliveryTrackingState {
  const TrackingStopped({
    required super.statusMessage,
    super.currentPosition,
    super.distanceToDestination,
  }) : super(isStopping: false); 
}

class TrackingError extends LiveDeliveryTrackingState {
  final String errorMessage;
  const TrackingError(
      {required this.errorMessage,
      super.currentPosition,
      super.distanceToDestination})
      : super(statusMessage: errorMessage);

  @override
  List<Object?> get props =>
      [statusMessage, currentPosition, distanceToDestination, errorMessage];
}
