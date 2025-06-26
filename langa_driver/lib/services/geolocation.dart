import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';

/// Service for geolocation operations like distance calculation and reverse geocoding.
class GeolocationService {
  /// Calculates distance in meters between two points.
  Future<double> calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) async {
    try {
      return Geolocator.distanceBetween(
        startLatitude,
        startLongitude,
        endLatitude,
        endLongitude,
      );
    } catch (e) {
      debugPrint('Error calculating distance: $e');
      rethrow;
    }
  }

  /// Gets Placemark (address details) from coordinates. Returns null on failure.
  Future<Placemark?> getPlacemarkFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        return placemarks.first;
      } else {
        debugPrint(
            'No placemarks found for coordinates: $latitude, $longitude');
        return null;
      }
    } catch (e) {
      debugPrint('Error during reverse geocoding: $e');
      return null;
    }
  }

  /// Gets a formatted address string from coordinates.
  Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    Placemark? placemark =
        await getPlacemarkFromCoordinates(latitude, longitude);

    if (placemark != null) {
      String address = [
        placemark.street,
        placemark.locality,
        placemark.subAdministrativeArea,
        placemark.administrativeArea,
        placemark.postalCode,
        placemark.country
      ].where((s) => s != null && s.isNotEmpty).join(', ');

      return address.isNotEmpty ? address : 'Address details not found';
    } else {
      return 'Unable to determine address';
    }
  }

  /// Gets the current device location, handling permissions. Returns null on failure.
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permissions are denied');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permissions are permanently denied.');
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }
}
