import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:langas_driver/bloc/tracking_bloc/live_delivery_tracking_bloc_bloc.dart';
import 'package:langas_driver/bloc/tracking_bloc/live_delivery_tracking_bloc_event.dart';
import 'package:langas_driver/bloc/tracking_bloc/live_delivery_tracking_bloc_state.dart';
import 'package:langas_driver/services/geolocation.dart';
import 'package:langas_driver/services/location_tracking.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_theme.dart';

class LiveDeliveryTrackingScreen extends StatelessWidget {
  final String deliveryId;
  final String driverId;
  final LatLng destinationCoordinates;
  final String destinationAddressForMaps;

  const LiveDeliveryTrackingScreen({
    super.key,
    required this.deliveryId,
    required this.driverId,
    required this.destinationCoordinates,
    required this.destinationAddressForMaps,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LiveDeliveryTrackingBloc(
        deliveryId: deliveryId,
        driverId: driverId,
        destinationCoordinates: destinationCoordinates,
        locationTrackingManager: context.read<LocationTrackingManager>(),
        geolocationService: context.read<GeolocationService>(),
        firebaseDatabase: context.read<FirebaseDatabase>(),
      )..add(const InitializeTracking()),
      child: LiveDeliveryTrackingView(
        destinationAddressForMaps: destinationAddressForMaps,
        destinationCoordinates: destinationCoordinates,
      ),
    );
  }
}

class LiveDeliveryTrackingView extends StatelessWidget {
  final String destinationAddressForMaps;
  final LatLng destinationCoordinates;

  const LiveDeliveryTrackingView({
    super.key,
    required this.destinationAddressForMaps,
    required this.destinationCoordinates,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primary,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Tracking Delivery: ${context.read<LiveDeliveryTrackingBloc>().deliveryId.split('_').last}',
          style: theme.headlineMedium.override(
            fontFamily: theme.headlineMediumFamily,
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocConsumer<LiveDeliveryTrackingBloc, LiveDeliveryTrackingState>(
        listener: (context, state) {
          if (state is TrackingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.errorMessage}'),
                backgroundColor: theme.error,
              ),
            );
          } else if (state is TrackingStopped) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.statusMessage),
                backgroundColor: theme.success,
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Column(
                  children: [
                    Text(
                      state.statusMessage,
                      textAlign: TextAlign.center,
                      style: theme.titleLarge.override(
                        fontFamily: theme.titleLargeFamily,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (state.currentPosition != null &&
                        !state.isStopping &&
                        state is! TrackingStopped &&
                        state is TrackingActive)
                      Card(
                        elevation: 2,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        color: theme.secondaryBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Destination:',
                                  style: theme.titleMedium.override(
                                      fontFamily: theme.titleMediumFamily)),
                              Text(
                                'Lat: ${context.read<LiveDeliveryTrackingBloc>().destinationCoordinates.latitude.toStringAsFixed(4)}, Lon: ${context.read<LiveDeliveryTrackingBloc>().destinationCoordinates.longitude.toStringAsFixed(4)}',
                                style: theme.bodyMedium.override(
                                    fontFamily: theme.bodyMediumFamily),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Approx. Distance: ${state.distanceToDestination.toStringAsFixed(0)} meters',
                                style: theme.bodyLarge.override(
                                  fontFamily: theme.bodyLargeFamily,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Last check: ${TimeOfDay.fromDateTime(DateTime.now()).format(context)}',
                                style: theme.bodySmall.override(
                                  fontFamily: theme.bodySmallFamily,
                                  color: theme.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (state is TrackingStopped ||
                        (state.isStopping && state is! TrackingInitial))
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Text(
                          state is TrackingStopped
                              ? "Background tracking has been stopped."
                              : "Attempting to stop background tracking...",
                          textAlign: TextAlign.center,
                          style: theme.bodyLarge.override(
                            fontFamily: theme.bodyLargeFamily,
                            color: theme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.directions, color: Colors.white),
                  label: Text('Open in Google Maps',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: theme.titleSmallFamily ?? 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                      textStyle: theme.titleSmall.override(
                          fontFamily: theme.titleSmallFamily, fontSize: 14)),
                  onPressed: state is TrackingStopping
                      ? null
                      : () {
                          context.read<LiveDeliveryTrackingBloc>().add(
                                OpenMapsRequested(
                                  currentPosition: state.currentPosition,
                                  destinationCoordinates:
                                      destinationCoordinates,
                                  destinationAddressForMaps:
                                      destinationAddressForMaps,
                                ),
                              );
                        },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
