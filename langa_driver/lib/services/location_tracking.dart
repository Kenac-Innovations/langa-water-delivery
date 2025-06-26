import 'dart:async';
import 'dart:ui'; // Required for DartPluginRegistrant
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart'; // For @pragma
import 'package:geolocator/geolocator.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

const String notificationChannelId = 'langas_driver_location_channel';
const int notificationId = 888;
const String initialNotificationTitle = 'Langas Driver Active';
const String initialNotificationContent =
    'Location tracking is initializing...';
const String trackingNotificationTitle = 'Langas Driver - On Duty';
const String trackingNotificationContent =
    'Your location is being shared for active delivery.';

// Common background task handler
@pragma('vm:entry-point')
Future<bool> _flutterBackgroundServiceHandler(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp();
      debugPrint('Firebase initialized in background handler.');
    } catch (e) {
      debugPrint('Firebase.initializeApp() error in background: $e');
      return false; // Signal failure to start/continue service
    }
  }

  final FirebaseDatabase database = FirebaseDatabase.instance;
  StreamSubscription<Position>? positionStreamSubscription;
  String? currentDriverId;
  String? currentDeliveryId;

  // Set up initial notification for Android if it's a foreground service
  if (service is AndroidServiceInstance) {
    if (await service.isForegroundService()) {
      service.setForegroundNotificationInfo(
        title: initialNotificationTitle,
        content: initialNotificationContent,
      );
    }
  }

  service.on('startTracking').listen((payload) async {
    if (payload != null &&
        payload.containsKey('driverId') &&
        payload.containsKey('deliveryId')) {
      currentDriverId = payload['driverId']?.toString();
      currentDeliveryId = payload['deliveryId']?.toString();

      await positionStreamSubscription?.cancel();
      positionStreamSubscription = null;

      if (currentDriverId == null || currentDeliveryId == null) {
        debugPrint(
            'Background Tracking Error: driverId or deliveryId is null.');
        return;
      }

      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint(
            'Background Location Service: Location services are disabled.');
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        debugPrint(
            'Background Location Service: Location permissions are denied (cannot request from background).');
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint(
            'Background Location Service: Location permissions are permanently denied.');
        return;
      }

      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 15, // Update if distance changes by 15 meters
      );

      positionStreamSubscription =
          Geolocator.getPositionStream(locationSettings: locationSettings)
              .handleError((error) {
        debugPrint('Background Location Stream Error: $error');
      }).listen((Position? position) async {
        // Made listen callback async
        if (position != null &&
            currentDriverId != null &&
            currentDeliveryId != null) {
          final locationData = {
            'driverId': currentDriverId,
            'deliveryId': currentDeliveryId,
            'latitude': position.latitude,
            'longitude': position.longitude,
            'accuracy': position.accuracy,
            'speed': position.speed,
            'heading': position.heading,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          };

          try {
            DatabaseReference ref =
                database.ref('active_driver_locations/$currentDeliveryId');
            await ref.set(locationData); // Added await
            debugPrint(
                'Background location updated to Firebase: $currentDeliveryId');

            if (service is AndroidServiceInstance) {
              if (await service.isForegroundService()) {
                // Await here
                service.setForegroundNotificationInfo(
                  title: trackingNotificationTitle,
                  content:
                      "$trackingNotificationContent\nLat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}",
                );
              }
            }
          } catch (e) {
            debugPrint('Firebase Database Error in background: $e');
          }
        }
      });
      debugPrint(
          'Background tracking started for delivery: $currentDeliveryId by driver: $currentDriverId');
    }
  });

  service.on('stopTracking').listen((payload) async {
    await positionStreamSubscription?.cancel();
    positionStreamSubscription = null;

    if (currentDeliveryId != null) {
      try {
        DatabaseReference ref =
            database.ref('active_driver_locations/$currentDeliveryId');
        await ref.remove();
        debugPrint(
            'Background tracking stopped and data removed for delivery: $currentDeliveryId');
      } catch (e) {
        debugPrint('Firebase Database Error on stopTracking (remove): $e');
      }
    }
    currentDriverId = null;
    currentDeliveryId = null;
    debugPrint('Background tracking variables reset.');
  });

  debugPrint('Background service handler initialized and listening.');
  return true; // Service initialized successfully and should continue
}

// Android specific entry point
@pragma('vm:entry-point')
void onStartAndroid(ServiceInstance service) async {
  bool success = await _flutterBackgroundServiceHandler(service);
  if (!success) {
    // If handler failed (e.g., Firebase init), stop the Android service instance
    service.stopSelf();
  }
}

// iOS specific entry point
@pragma('vm:entry-point')
Future<bool> onStartIos(ServiceInstance service) async {
  return await _flutterBackgroundServiceHandler(service);
}

Future<void> initializeLocationService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStartAndroid, // Use the void-returning wrapper for Android
      isForegroundMode: true,
      autoStart: false,
      notificationChannelId: notificationChannelId,
      initialNotificationTitle: initialNotificationTitle,
      initialNotificationContent: initialNotificationContent,
      foregroundServiceNotificationId: notificationId,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground:
          onStartIos, // Use the Future<bool>-returning wrapper for iOS
      onBackground:
          onStartIos, // Use the Future<bool>-returning wrapper for iOS
    ),
  );
}

class LocationTrackingManager {
  final FlutterBackgroundService _service = FlutterBackgroundService();

  Future<void> startTrackingService(String driverId, String deliveryId) async {
    bool isRunning = await _service.isRunning();
    if (!isRunning) {
      try {
        await _service.startService();
        debugPrint('LocationTrackingManager: Background service started.');
      } catch (e) {
        debugPrint("Error starting background service: $e");
        return;
      }
    }
    _service.invoke('startTracking', {
      'driverId': driverId,
      'deliveryId': deliveryId,
    });
    debugPrint(
        'LocationTrackingManager: Invoked startTracking for $deliveryId by $driverId');
  }

  Future<void> stopTrackingService() async {
    bool isRunning = await _service.isRunning();
    if (isRunning) {
      _service.invoke('stopTracking');
      debugPrint('LocationTrackingManager: Invoked stopTracking');
    } else {
      debugPrint(
          'LocationTrackingManager: Service not running, cannot invoke stopTracking.');
    }
  }

  Future<bool> isServiceRunning() async {
    return await _service.isRunning();
  }
}
