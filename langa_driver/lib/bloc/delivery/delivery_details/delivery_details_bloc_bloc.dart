import 'dart:async';
import 'dart:convert';
import 'dart:math' show cos, sqrt, asin;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:langas_driver/bloc/delivery/delivery_details/delivery_details_bloc_event.dart';
import 'package:langas_driver/bloc/delivery/delivery_details/delivery_details_bloc_state.dart';
import 'package:langas_driver/models/delivery_models.dart';
import 'package:langas_driver/repository/delivery_repository.dart';
import 'package:langas_driver/utils/api_constants.dart';
import 'package:langas_driver/utils/api_response_model.dart';
import 'package:langas_driver/utils/failure_models.dart';
import 'package:dartz/dartz.dart' as dartz;

// Helper function (can be moved to a utility file if preferred)
List<LatLng> _decodePolyline(String encoded) {
  List<LatLng> points = [];
  int index = 0;
  int len = encoded.length;
  int lat = 0, lng = 0;

  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1F) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1F) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;

    points.add(LatLng(lat / 1E5, lng / 1E5));
  }
  return points;
}

double _calculateHaversineDistance(
    double lat1, double lon1, double lat2, double lon2) {
  const p = 0.017453292519943295;
  final c = 0.5 -
      cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(c)); // Distance in km
}

class DeliveryDetailsBloc
    extends Bloc<DeliveryDetailsEvent, DeliveryDetailsState> {
  final DeliveryRepository _deliveryRepository;

  DeliveryDetailsBloc({required DeliveryRepository deliveryRepository})
      : _deliveryRepository = deliveryRepository,
        super(DeliveryDetailsInitial()) {
    on<FetchDeliveryRouteDetails>(_onFetchDeliveryRouteDetails);
  }

  Future<Map<String, dynamic>> _fetchRouteAndDistance(double pickupLat,
      double pickupLng, double dropoffLat, double dropoffLng) async {
    List<LatLng> routeCoordinates = [];
    String? estimatedTime;
    double? estimatedDistance;

    final origin = '$pickupLat,$pickupLng';
    final destination = '$dropoffLat,$dropoffLng';
    const apiKey = ApiConstants.googleApiKey;
    final directionsUrl =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&mode=driving&key=$apiKey';

    try {
      final directionsResponse = await http.get(Uri.parse(directionsUrl));
      if (directionsResponse.statusCode == 200) {
        final jsonResponse = jsonDecode(directionsResponse.body);
        if (jsonResponse['status'] == 'OK' &&
            jsonResponse['routes'] != null &&
            jsonResponse['routes'].isNotEmpty) {
          final route = jsonResponse['routes'][0];
          if (route['overview_polyline'] != null &&
              route['overview_polyline']['points'] != null) {
            routeCoordinates =
                _decodePolyline(route['overview_polyline']['points']);
          }
        }
      }
    } catch (e) {
      print('Error fetching directions: $e');
    }

    if (routeCoordinates.isEmpty) {
      // Fallback to straight line
      routeCoordinates.add(LatLng(pickupLat, pickupLng));
      routeCoordinates.add(LatLng(dropoffLat, dropoffLng));
    }

    final distanceMatrixUrl =
        'https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=$origin&destinations=$destination&key=$apiKey';
    try {
      final distanceResponse = await http.get(Uri.parse(distanceMatrixUrl));
      if (distanceResponse.statusCode == 200) {
        final data = jsonDecode(distanceResponse.body);
        if (data['status'] == 'OK' &&
            data['rows'] != null &&
            data['rows'].isNotEmpty &&
            data['rows'][0]['elements'] != null &&
            data['rows'][0]['elements'].isNotEmpty &&
            data['rows'][0]['elements'][0]['status'] == 'OK') {
          estimatedTime = data['rows'][0]['elements'][0]['duration']['text'];
          estimatedDistance =
              (data['rows'][0]['elements'][0]['distance']['value'] as num)
                      .toDouble() /
                  1000;
        }
      }
    } catch (e) {
      print('Error fetching distance matrix: $e');
    }

    if (estimatedDistance == null) {
      estimatedDistance = _calculateHaversineDistance(
          pickupLat, pickupLng, dropoffLat, dropoffLng);
      estimatedTime =
          "${(estimatedDistance / 30 * 60).round()} mins (est.)"; // Rough estimate
    }

    return {
      'routeCoordinates': routeCoordinates,
      'estimatedTime': estimatedTime,
      'estimatedDistance': estimatedDistance,
    };
  }

  Future<void> _onFetchDeliveryRouteDetails(FetchDeliveryRouteDetails event,
      Emitter<DeliveryDetailsState> emit) async {
    emit(DeliveryDetailsLoading());
    final dartz.Either<Failure, ApiResponse<Delivery>> result =
        await _deliveryRepository.getDeliveryDetails(event.deliveryId);

    await result.fold(
      (failure) async => emit(DeliveryDetailsLoadFailure(failure: failure)),
      (apiResponse) async {
        if (apiResponse.success && apiResponse.data != null) {
          final delivery = apiResponse.data!;
          try {
            final mapData = await _fetchRouteAndDistance(
              delivery.pickupLatitude,
              delivery.pickupLongitude,
              delivery.dropOffLatitude,
              delivery.dropOffLongitude,
            );
            emit(DeliveryDetailsLoadSuccess(
              delivery: delivery,
              routeCoordinates: mapData['routeCoordinates'],
              estimatedTime: mapData['estimatedTime'],
              estimatedDistance: mapData['estimatedDistance'],
            ));
          } catch (e) {
            emit(DeliveryDetailsLoadFailure(
                failure: ServerFailure(
                    message: "Failed to load map data: ${e.toString()}")));
          }
        } else {
          emit(DeliveryDetailsLoadFailure(
              failure: ServerFailure(message: apiResponse.message)));
        }
      },
    );
  }
}
