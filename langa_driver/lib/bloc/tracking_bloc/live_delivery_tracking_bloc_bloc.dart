import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:langas_driver/bloc/tracking_bloc/live_delivery_tracking_bloc_event.dart';
import 'package:langas_driver/bloc/tracking_bloc/live_delivery_tracking_bloc_state.dart';
import 'package:langas_driver/services/geolocation.dart';
import 'package:langas_driver/services/location_tracking.dart';
import 'package:url_launcher/url_launcher.dart';

const double STOP_TRACKING_DISTANCE_METERS_BLOC = 200.0;

class LiveDeliveryTrackingBloc
    extends Bloc<LiveDeliveryTrackingEvent, LiveDeliveryTrackingState> {
  final String deliveryId;
  final String driverId;
  final LatLng destinationCoordinates;

  final LocationTrackingManager _locationTrackingManager;
  final GeolocationService _geolocationService;
  final FirebaseDatabase _firebaseDatabase;

  Timer? _distanceCheckTimer;

  LiveDeliveryTrackingBloc({
    required this.deliveryId,
    required this.driverId,
    required this.destinationCoordinates,
    required LocationTrackingManager locationTrackingManager,
    required GeolocationService geolocationService,
    required FirebaseDatabase firebaseDatabase,
  })  : _locationTrackingManager = locationTrackingManager,
        _geolocationService = geolocationService,
        _firebaseDatabase = firebaseDatabase,
        super(const TrackingInitial()) {
    on<InitializeTracking>(_onInitializeTracking);
    // Updated to use public event names
    on<CheckPositionAndDistance>(_onCheckPositionAndDistance);
    on<ProximityDetectedAndStop>(_onProximityDetectedAndStop);
    on<OpenMapsRequested>(_onOpenMapsRequested);
  }

  Future<void> _onInitializeTracking(
    InitializeTracking event,
    Emitter<LiveDeliveryTrackingState> emit,
  ) async {
    await _performDistanceAndLocationUpdate(emit);
    _distanceCheckTimer?.cancel();
    _distanceCheckTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (!isClosed &&
          state is! TrackingStopping &&
          state is! TrackingStopped) {
        // Updated to add public event name
        add(const CheckPositionAndDistance());
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _performDistanceAndLocationUpdate(
      Emitter<LiveDeliveryTrackingState> emit) async {
    if (state.isStopping || state is TrackingStopped) return;
    try {
      final position = await _geolocationService.getCurrentLocation();
      if (position != null) {
        final distance = await _geolocationService.calculateDistance(
          position.latitude,
          position.longitude,
          destinationCoordinates.latitude,
          destinationCoordinates.longitude,
        );
        if (distance <= STOP_TRACKING_DISTANCE_METERS_BLOC) {
          // Updated to add public event name
          add(const ProximityDetectedAndStop());
        } else {
          await _updateLiveLocationInRTDB(position);
          emit(TrackingActive(
            statusMessage:
                "Live tracking active. Distance: ${distance.toStringAsFixed(0)}m",
            currentPosition: position,
            distanceToDestination: distance,
          ));
        }
      } else {
        emit(TrackingActive(
          statusMessage: "Tracking active. Unable to get current location.",
          currentPosition: state.currentPosition,
          distanceToDestination: state.distanceToDestination,
        ));
      }
    } catch (e) {
      emit(TrackingError(
        errorMessage: "Error processing location: ${e.toString()}",
        currentPosition: state.currentPosition,
        distanceToDestination: state.distanceToDestination,
      ));
    }
  }

  Future<void> _updateLiveLocationInRTDB(Position position) async {
    try {
      final Map<String, dynamic> liveLocationData = {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'speed': position.speed,
        'heading': position.heading,
        'accuracy': position.accuracy,
        'timestamp': ServerValue.timestamp,
        'driverId': driverId,
      };
      await _firebaseDatabase
          .ref('detailed_live_tracking/$deliveryId')
          .set(liveLocationData);
    } catch (e) {
      print("Error updating live location to RTDB via BLoC: $e");
    }
  }

  Future<void> _onCheckPositionAndDistance(
    // Updated to use public event name
    CheckPositionAndDistance event,
    Emitter<LiveDeliveryTrackingState> emit,
  ) async {
    await _performDistanceAndLocationUpdate(emit);
  }

  Future<void> _onProximityDetectedAndStop(
    // Updated to use public event name
    ProximityDetectedAndStop event,
    Emitter<LiveDeliveryTrackingState> emit,
  ) async {
    if (state.isStopping || state is TrackingStopped) return;
    _distanceCheckTimer?.cancel();
    emit(TrackingStopping(
      statusMessage: "Driver near destination. Stopping background service.",
      currentPosition: state.currentPosition,
      distanceToDestination: state.distanceToDestination,
    ));
    try {
      await _locationTrackingManager.stopTrackingService();
      emit(TrackingStopped(
        statusMessage:
            "Background tracking service stopped. Driver near destination.",
        currentPosition: state.currentPosition,
        distanceToDestination: state.distanceToDestination,
      ));
    } catch (e) {
      emit(TrackingError(
        errorMessage: "Error stopping background service: ${e.toString()}",
        currentPosition: state.currentPosition,
        distanceToDestination: state.distanceToDestination,
      ));
    }
  }

  Future<void> _onOpenMapsRequested(
      OpenMapsRequested event, Emitter<LiveDeliveryTrackingState> emit) async {
    String googleMapsUrl;
    if (event.currentPosition != null) {
      googleMapsUrl =
          "https://www.google.com/maps/dir/?api=1&destination=${event.currentPosition!.latitude},${event.currentPosition!.longitude}&daddr=${event.destinationCoordinates.latitude},${event.destinationCoordinates.longitude}&travelmode=driving";
    } else {
      googleMapsUrl =
          "https://www.google.com/maps/dir/?api=1&origin=${event.destinationCoordinates.latitude},${event.destinationCoordinates.longitude}";
    }
    final Uri uri = Uri.parse(googleMapsUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error launching maps: $e');
    }
  }

  @override
  Future<void> close() {
    _distanceCheckTimer?.cancel();
    return super.close();
  }
}
