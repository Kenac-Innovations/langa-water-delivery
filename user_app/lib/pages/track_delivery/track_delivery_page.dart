import 'dart:async';
import 'dart:convert';
import 'dart:math' show cos, sqrt, asin, min, max;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:langas_user/bloc/deliveries/single_delivery_bloc/single_delivery_bloc_bloc.dart';
import 'package:langas_user/bloc/deliveries/single_delivery_bloc/single_delivery_bloc_event.dart';
import 'package:langas_user/bloc/deliveries/single_delivery_bloc/single_delivery_bloc_state.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_user/models/delivery_model.dart';
import 'package:langas_user/util/api_constants.dart';
import 'package:langas_user/util/apps_enums.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io' show Platform;

class TrackDeliveryPage extends StatefulWidget {
  final int deliveryId;
  final String clientId;

  const TrackDeliveryPage({
    super.key,
    required this.deliveryId,
    required this.clientId,
  });

  @override
  State<TrackDeliveryPage> createState() => _TrackDeliveryPageState();
}

class _TrackDeliveryPageState extends State<TrackDeliveryPage> {
  GoogleMapController? _mapController;
  List<LatLng> _routeCoordinates = [];
  Timer? _periodicBlocRefreshTimer;
  StreamSubscription? _rtdbLocationSubscription;

  Delivery? _currentDelivery;
  LatLng? _driverLocation;
  LatLng?
      _lastDriverLocationForRouteCalculation; // To manage route API call frequency
  String _deliveryStatusText = "Loading...";
  String _statusDescription = "Fetching delivery details...";
  String? _distanceFromDestinationText;

  BitmapDescriptor? _pickupIcon;
  BitmapDescriptor? _dropoffIcon;
  BitmapDescriptor? _driverIcon;

  static const String RTDB_LIVE_TRACKING_PATH = 'detailed_live_tracking';
  static const String Maps_API_KEY = ApiConstants.googleApiKey;
  static const double SIGNIFICANT_MOVE_THRESHOLD_KM = 0.1;

  var CameraUpdate; // e.g., 100 meters

  @override
  void initState() {
    super.initState();
    _setCustomMapPins();
    _fetchInitialDeliveryDetails();
    _periodicBlocRefreshTimer =
        Timer.periodic(const Duration(seconds: 20), (timer) {
      _fetchDeliveryUpdate();
    });
  }

  @override
  void dispose() {
    _periodicBlocRefreshTimer?.cancel();
    _rtdbLocationSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _fetchInitialDeliveryDetails() {
    context.read<SingleDeliveryBloc>().add(FetchSingleDeliveryRequested(
        clientId: widget.clientId, deliveryId: widget.deliveryId));
  }

  void _fetchDeliveryUpdate() {
    context.read<SingleDeliveryBloc>().add(FetchSingleDeliveryRequested(
        clientId: widget.clientId, deliveryId: widget.deliveryId));
  }

  void _setCustomMapPins() async {
    _pickupIcon =
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    _dropoffIcon =
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    try {
      _driverIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/images/delivery_pin.png',
      );
    } catch (e) {
      print(
          "TrackDeliveryPage: Error loading custom driver icon, using default: $e");
      _driverIcon =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }
    if (mounted) setState(() {});
  }

  void _setupRTDBLocationListener(String deliveryIdForRtdb) {
    _rtdbLocationSubscription?.cancel();
    print(
        "TrackDeliveryPage: Setting up RTDB listener for $RTDB_LIVE_TRACKING_PATH/$deliveryIdForRtdb");
    final DatabaseReference driverLocationRef = FirebaseDatabase.instance
        .ref('$RTDB_LIVE_TRACKING_PATH/$deliveryIdForRtdb');

    _rtdbLocationSubscription =
        driverLocationRef.onValue.listen((DatabaseEvent event) {
      if (!mounted) return;
      if (event.snapshot.exists && event.snapshot.value != null) {
        try {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          final double? lat = data['latitude'] as double?;
          final double? lng = data['longitude'] as double?;

          if (lat != null && lng != null) {
            final newDriverLocation = LatLng(lat, lng);
            bool needsRouteUpdate =
                _lastDriverLocationForRouteCalculation == null ||
                    calculateDistance(
                            _lastDriverLocationForRouteCalculation!.latitude,
                            _lastDriverLocationForRouteCalculation!.longitude,
                            newDriverLocation.latitude,
                            newDriverLocation.longitude) >
                        SIGNIFICANT_MOVE_THRESHOLD_KM;

            setState(() {
              _driverLocation = newDriverLocation;
              if (_currentDelivery != null) {
                _updateDistanceText(_currentDelivery!);
                if (needsRouteUpdate &&
                    _currentDelivery!.deliveryStatus !=
                        DeliveryStatus.COMPLETED &&
                    _currentDelivery!.deliveryStatus !=
                        DeliveryStatus.CANCELLED) {
                  print(
                      "TrackDeliveryPage: Driver moved significantly, updating route.");
                  _drawRouteFromDriverToDropoff();
                }
              }
            });
          }
        } catch (e) {
          print("TrackDeliveryPage: Error parsing RTDB location data: $e");
        }
      }
    }, onError: (error) {
      print(
          "TrackDeliveryPage: Error listening to RTDB driver location: $error");
    });
  }

  void _updateDistanceText(Delivery delivery) {
    if (_driverLocation != null) {
      double distToDestinationKm = calculateDistance(
          _driverLocation!.latitude,
          _driverLocation!.longitude,
          delivery.dropOffLatitude,
          delivery.dropOffLongitude);
      _distanceFromDestinationText =
          "${distToDestinationKm.toStringAsFixed(1)} km";
    } else {
      _distanceFromDestinationText = null;
    }
  }

  void _updateStateFromDelivery(Delivery delivery) {
    _currentDelivery = delivery;
    _deliveryStatusText = delivery.deliveryStatus.name.replaceAll('_', ' ');
    _deliveryStatusText = _deliveryStatusText[0].toUpperCase() +
        _deliveryStatusText.substring(1).toLowerCase();

    switch (delivery.deliveryStatus) {
      case DeliveryStatus.ASSIGNED:
        _statusDescription =
            "Your driver is assigned and heading to the pickup location.";
        break;
      case DeliveryStatus.PICKED_UP:
        _statusDescription =
            "Package picked up and is now en route to your location!";
        break;
      case DeliveryStatus.COMPLETED:
        _statusDescription = "Your delivery has been completed successfully!";
        _rtdbLocationSubscription?.cancel();
        _rtdbLocationSubscription = null;
        break;
      case DeliveryStatus.CANCELLED:
        _statusDescription = "This delivery has been cancelled.";
        _rtdbLocationSubscription?.cancel();
        _rtdbLocationSubscription = null;
        break;
      case DeliveryStatus.OPEN:
        _statusDescription = "We're finding a nearby driver for your delivery.";
        _rtdbLocationSubscription?.cancel();
        _rtdbLocationSubscription = null;
        break;
      default:
        _statusDescription = "Updating delivery status...";
    }

    if (_driverLocation == null &&
        delivery.driver?.latitude != null &&
        delivery.driver?.longitude != null) {
      _driverLocation =
          LatLng(delivery.driver!.latitude!, delivery.driver!.longitude!);
    }
    if (_driverLocation == null &&
        (delivery.deliveryStatus == DeliveryStatus.ASSIGNED ||
            delivery.deliveryStatus == DeliveryStatus.PICKED_UP)) {
      _driverLocation =
          LatLng(delivery.pickupLatitude, delivery.pickupLongitude);
    }

    _updateDistanceText(delivery);

    // Initial route draw or if route is empty
    if (_driverLocation != null &&
        (_routeCoordinates.isEmpty ||
            _lastDriverLocationForRouteCalculation == null) &&
        (delivery.deliveryStatus == DeliveryStatus.ASSIGNED ||
            delivery.deliveryStatus == DeliveryStatus.PICKED_UP)) {
      _drawRouteFromDriverToDropoff();
    }

    if (delivery.deliveryStatus == DeliveryStatus.ASSIGNED ||
        delivery.deliveryStatus == DeliveryStatus.PICKED_UP) {
      if (_rtdbLocationSubscription == null) {
        _setupRTDBLocationListener(widget.deliveryId.toString());
      }
    } else {
      _rtdbLocationSubscription?.cancel();
      _rtdbLocationSubscription = null;
    }

    if (mounted) setState(() {});
  }

  Future<void> _drawRouteFromDriverToDropoff() async {
    if (!mounted ||
        _driverLocation == null ||
        _currentDelivery == null ||
        Maps_API_KEY == ApiConstants.googleApiKey ||
        Maps_API_KEY.isEmpty) {
      if (Maps_API_KEY == ApiConstants.googleApiKey || Maps_API_KEY.isEmpty) {
        print(
            "TrackDeliveryPage: Google Maps API Key not configured. Cannot draw dynamic route.");
      }
      if (_driverLocation != null && _currentDelivery != null) {
        _setDefaultRoute(
            _driverLocation!,
            LatLng(_currentDelivery!.dropOffLatitude,
                _currentDelivery!.dropOffLongitude));
      }
      return;
    }

    print(
        "TrackDeliveryPage: Drawing route from Driver: ${_driverLocation} to Dropoff: (${_currentDelivery!.dropOffLatitude}, ${_currentDelivery!.dropOffLongitude})");

    final origin = '${_driverLocation!.latitude},${_driverLocation!.longitude}';
    final destination =
        '${_currentDelivery!.dropOffLatitude},${_currentDelivery!.dropOffLongitude}';
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&mode=driving&key=$Maps_API_KEY';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final routes = json['routes'];
        if (routes != null && routes.isNotEmpty) {
          final points = routes[0]['overview_polyline']?['points'];
          if (points != null) {
            if (mounted) {
              setState(() {
                _routeCoordinates = decodePolyline(points);
                _lastDriverLocationForRouteCalculation =
                    _driverLocation; // Update last location for which route was drawn
              });
              // No automatic zoomToFitRoute here, map pans with driver if implemented or user controls zoom.
              // Or, we can adjust camera to keep driver and some part of route visible.
            }
          } else {
            _setDefaultRoute(
                _driverLocation!,
                LatLng(_currentDelivery!.dropOffLatitude,
                    _currentDelivery!.dropOffLongitude));
          }
        } else {
          print("TrackDeliveryPage: No routes found by Directions API.");
          _setDefaultRoute(
              _driverLocation!,
              LatLng(_currentDelivery!.dropOffLatitude,
                  _currentDelivery!.dropOffLongitude));
        }
      } else {
        print(
            "TrackDeliveryPage: Directions API error HTTP ${response.statusCode}");
        _setDefaultRoute(
            _driverLocation!,
            LatLng(_currentDelivery!.dropOffLatitude,
                _currentDelivery!.dropOffLongitude));
      }
    } catch (e) {
      print("TrackDeliveryPage: Exception drawing route: $e");
      if (_driverLocation != null && _currentDelivery != null) {
        _setDefaultRoute(
            _driverLocation!,
            LatLng(_currentDelivery!.dropOffLatitude,
                _currentDelivery!.dropOffLongitude));
      }
    }
  }

  void _setDefaultRoute(LatLng origin, LatLng destination) {
    if (mounted) {
      setState(() {
        _routeCoordinates = [origin, destination];
        _lastDriverLocationForRouteCalculation = origin;
      });
      // zoomToFitRoute(); // Decide if this is needed for a simple straight line
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    LatLng initialMapCenter;

    if (_driverLocation != null) {
      initialMapCenter = _driverLocation!;
    } else if (_currentDelivery != null) {
      initialMapCenter = LatLng(
        _currentDelivery!
            .pickupLatitude, // Keep pickup for initial map centering before driver location is known
        _currentDelivery!.pickupLongitude,
      );
    } else {
      initialMapCenter = const LatLng(-17.8252, 31.0335);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primary,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon:
              Icon(Icons.chevron_left_rounded, color: Colors.white, size: 30.0),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Track Delivery #TK${widget.deliveryId}",
          style: theme.headlineSmall.override(
              fontFamily: 'Poppins',
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                _fetchDeliveryUpdate();
                if (_driverLocation != null && _currentDelivery != null) {
                  _drawRouteFromDriverToDropoff(); // Refresh route on manual refresh
                }
              }),
        ],
        centerTitle: true,
        elevation: 2.0,
      ),
      body: BlocConsumer<SingleDeliveryBloc, SingleDeliveryState>(
        listener: (context, state) {
          if (state is SingleDeliverySuccess) {
            _updateStateFromDelivery(state.delivery);
          } else if (state is SingleDeliveryFailure) {
            _showToast("Error: ${state.failure.message}", success: false);
          }
        },
        builder: (context, state) {
          bool showLoadingOverlay = (state is SingleDeliveryLoading ||
                  state is SingleDeliveryInitial) &&
              _currentDelivery == null;

          return Stack(
            children: [
              GoogleMap(
                onMapCreated: _onMapCreated,
                markers: _buildMarkers(),
                polylines: {
                  if (_routeCoordinates.isNotEmpty)
                    Polyline(
                      polylineId: const PolylineId(
                          'driverRoute'), // Changed ID for clarity
                      color: theme.primary,
                      points: _routeCoordinates,
                      width: 5,
                    ),
                },
                initialCameraPosition: CameraPosition(
                    target: initialMapCenter,
                    zoom: 14), // Default zoom adjusted
                mapType: MapType.normal,
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                compassEnabled: true,
                zoomControlsEnabled: true,
                onCameraMove: (CameraPosition position) {
                  // You could use this to stop auto-panning if user moves map
                },
              ),
              if (_currentDelivery != null)
                _buildStatusCard(_currentDelivery!, theme)
              else if (showLoadingOverlay)
                Container(
                  color: theme.secondaryBackground.withOpacity(0.8),
                  child: Center(
                      child: CircularProgressIndicator(color: theme.primary)),
                )
              else if (state is SingleDeliveryFailure)
                Align(
                  alignment: Alignment.center,
                  child: Card(
                    margin: const EdgeInsets.all(30),
                    color: theme.secondaryBackground,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Could not load delivery details.",
                              textAlign: TextAlign.center,
                              style: theme.titleMedium),
                          const SizedBox(height: 8),
                          Text(state.failure.message,
                              textAlign: TextAlign.center,
                              style: theme.bodySmall),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: Icon(Icons.refresh,
                                color: theme.customColor1 ?? Colors.white),
                            label: Text('Retry',
                                style: theme.bodyMedium.override(
                                    fontFamily: 'Poppins',
                                    color: theme.customColor1 ?? Colors.white)),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primary),
                            onPressed: _fetchInitialDeliveryDetails,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              if (_currentDelivery != null)
                _buildBottomDetailsCard(_currentDelivery!, theme),
            ],
          );
        },
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // Route is now drawn when _driverLocation is available and changes,
    // or when delivery details are first loaded with a driver location.
    // Initial zoomToFitRoute for the full pickup-to-dropoff might not be what we want anymore.
    // The map will center on initialMapCenter, then driver marker appears.
    // We can potentially animate to driver if _driverLocation is known here.
    if (_driverLocation != null && _mapController != null) {
      _mapController!
          .animateCamera(CameraUpdate.newLatLngZoom(_driverLocation!, 15));
      if (_routeCoordinates.isNotEmpty) zoomToIncludeDriverAndDropoff();
    } else if (_currentDelivery != null && _mapController != null) {
      // If no driver location yet, but we have pickup/dropoff, fit them.
      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(
            min(_currentDelivery!.pickupLatitude,
                _currentDelivery!.dropOffLatitude),
            min(_currentDelivery!.pickupLongitude,
                _currentDelivery!.dropOffLongitude)),
        northeast: LatLng(
            max(_currentDelivery!.pickupLatitude,
                _currentDelivery!.dropOffLatitude),
            max(_currentDelivery!.pickupLongitude,
                _currentDelivery!.dropOffLongitude)),
      );
      _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
    }
  }

  void zoomToIncludeDriverAndDropoff() {
    if (_mapController == null ||
        _driverLocation == null ||
        _currentDelivery == null) return;

    List<LatLng> pointsToInclude = [
      _driverLocation!,
      LatLng(
          _currentDelivery!.dropOffLatitude, _currentDelivery!.dropOffLongitude)
    ];

    if (_routeCoordinates.isNotEmpty) {
      // Optionally include some route points for better framing
      pointsToInclude.add(_routeCoordinates[
          _routeCoordinates.length ~/ 2]); // middle point of route
    }

    double minLat = pointsToInclude.first.latitude;
    double maxLat = pointsToInclude.first.latitude;
    double minLng = pointsToInclude.first.longitude;
    double maxLng = pointsToInclude.first.longitude;

    for (final point in pointsToInclude) {
      minLat = min(minLat, point.latitude);
      maxLat = max(maxLat, point.latitude);
      minLng = min(minLng, point.longitude);
      maxLng = max(maxLng, point.longitude);
    }

    final double latPadding = (maxLat - minLat).abs() < 0.0001
        ? 0.02
        : (maxLat - minLat).abs() * 0.25; // Increased padding
    final double lngPadding = (maxLng - minLng).abs() < 0.0001
        ? 0.02
        : (maxLng - minLng).abs() * 0.25;

    LatLng southwest = LatLng(minLat - latPadding, minLng - lngPadding);
    LatLng northeast = LatLng(maxLat + latPadding, maxLng + lngPadding);

    if (southwest.latitude > northeast.latitude) {
      final tempLat = southwest.latitude;
      southwest = LatLng(northeast.latitude, southwest.longitude);
      northeast = LatLng(tempLat, northeast.longitude);
    }
    if (southwest.longitude > northeast.longitude) {
      final tempLng = southwest.longitude;
      southwest = LatLng(southwest.latitude, northeast.longitude);
      northeast = LatLng(northeast.latitude, tempLng);
    }

    try {
      if (southwest.latitude <= northeast.latitude &&
          southwest.longitude <= northeast.longitude) {
        _mapController!.animateCamera(CameraUpdate.newLatLngBounds(
            LatLngBounds(southwest: southwest, northeast: northeast),
            80.0)); // More padding for animateCamera
      } else {
        _mapController!
            .animateCamera(CameraUpdate.newLatLngZoom(_driverLocation!, 14));
      }
    } catch (e) {
      _mapController!
          .animateCamera(CameraUpdate.newLatLngZoom(_driverLocation!, 14));
    }
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    // Pickup marker is now optional, map focuses on driver to dropoff
    // if (_currentDelivery != null) {
    //   markers.add(Marker(
    //     markerId: const MarkerId('pickup'),
    //     position: LatLng(_currentDelivery!.pickupLatitude, _currentDelivery!.pickupLongitude),
    //     icon: _pickupIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    //     infoWindow: InfoWindow(title: 'Pickup Location', snippet: _currentDelivery!.pickupLocation),
    //   ));
    // }
    if (_currentDelivery != null) {
      // Always show dropoff
      markers.add(Marker(
        markerId: const MarkerId('dropoff'),
        position: LatLng(_currentDelivery!.dropOffLatitude,
            _currentDelivery!.dropOffLongitude),
        icon: _dropoffIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
            title: 'Drop-off Location',
            snippet: _currentDelivery!.dropOffLocation),
      ));
    }

    if (_driverLocation != null) {
      markers.add(Marker(
        markerId: const MarkerId('driver'),
        position: _driverLocation!,
        icon: _driverIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(
            title: 'Driver Location',
            snippet:
                '${_currentDelivery?.driver?.firstname ?? 'Your'} ${_currentDelivery?.driver?.lastname ?? 'Driver'}'
                    .trim()),
        flat: true,
        anchor: const Offset(0.5, 0.5),
      ));
    }
    return markers;
  }

  Widget _buildStatusCard(Delivery delivery, FlutterFlowTheme theme) {
    bool isActiveTracking =
        delivery.deliveryStatus == DeliveryStatus.ASSIGNED ||
            delivery.deliveryStatus == DeliveryStatus.PICKED_UP;

    return Positioned(
      top: 10,
      left: 10,
      right: 10,
      child: Card(
        elevation: 5,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: theme.secondaryBackground,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: _getStatusColor(delivery.deliveryStatus)
                            .withOpacity(0.15),
                        shape: BoxShape.circle),
                    child: Icon(_getDeliveryStatusIcon(delivery.deliveryStatus),
                        color: _getStatusColor(delivery.deliveryStatus),
                        size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ORDER #TK${delivery.deliveryId}',
                            style: theme.bodySmall.override(
                                fontFamily: 'Poppins',
                                color: theme.secondaryText,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(_deliveryStatusText,
                            style: theme.titleMedium.override(
                                fontFamily: 'Poppins',
                                color: _getStatusColor(delivery.deliveryStatus),
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isActiveTracking && _distanceFromDestinationText != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Distance",
                            style: theme.labelSmall.override(
                                fontFamily: 'Poppins',
                                color: theme.secondaryText)),
                        Text(_distanceFromDestinationText!,
                            style: theme.titleSmall.override(
                                fontFamily: 'Poppins',
                                color: theme.primary,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(_statusDescription,
                  style: theme.bodyMedium.override(
                      fontFamily: 'Poppins',
                      color: theme.primaryText.withOpacity(0.8))),
              const SizedBox(height: 12),
              if (delivery.deliveryStatus != DeliveryStatus.OPEN &&
                  delivery.deliveryStatus != DeliveryStatus.CANCELLED)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _calculateProgress(delivery.deliveryStatus),
                    backgroundColor: theme.alternate.withOpacity(0.5),
                    valueColor: AlwaysStoppedAnimation<Color>(
                        _getStatusColor(delivery.deliveryStatus)),
                    minHeight: 8,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getDeliveryStatusIcon(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.OPEN:
        return Icons.hourglass_empty_rounded;
      case DeliveryStatus.ASSIGNED:
        return Icons.person_pin_circle_outlined;
      case DeliveryStatus.PICKED_UP:
        return Icons.local_shipping_outlined;
      case DeliveryStatus.COMPLETED:
        return Icons.check_circle_outline_rounded;
      case DeliveryStatus.CANCELLED:
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Widget _buildBottomDetailsCard(Delivery delivery, FlutterFlowTheme theme) {
    return Align(
      alignment: const AlignmentDirectional(0.0, 1.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
          boxShadow: [
            BoxShadow(
                blurRadius: 15,
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, -5))
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              20.0, 24.0, 20.0, (Platform.isIOS ? 34.0 : 24.0)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (delivery.driver != null &&
                  (delivery.deliveryStatus == DeliveryStatus.ASSIGNED ||
                      delivery.deliveryStatus == DeliveryStatus.PICKED_UP)) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: theme.primary.withOpacity(0.1),
                      backgroundImage:
                          delivery.driver!.profilePhotoUrl != null &&
                                  delivery.driver!.profilePhotoUrl!.isNotEmpty
                              ? NetworkImage(delivery.driver!.profilePhotoUrl!)
                              : null,
                      child: delivery.driver!.profilePhotoUrl == null ||
                              delivery.driver!.profilePhotoUrl!.isEmpty
                          ? Icon(Icons.person_outline_rounded,
                              size: 30, color: theme.primary)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${delivery.driver!.firstname ?? ''} ${delivery.driver!.lastname ?? ''}'
                                  .trim(),
                              style: theme.titleMedium.override(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold)),
                          Text(
                              delivery.vehicle?.vehicleModel ??
                                  delivery.vehicleType.name,
                              style: theme.bodySmall.override(
                                  fontFamily: 'Poppins',
                                  color: theme.secondaryText)),
                        ],
                      ),
                    ),
                    if (delivery.driver!.phoneNumber != null)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () =>
                              _callDriver(delivery.driver!.phoneNumber!),
                          borderRadius: BorderRadius.circular(25),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: theme.success.withOpacity(0.15),
                                shape: BoxShape.circle),
                            child: Icon(Icons.phone_outlined,
                                color: theme.success, size: 26),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
              ] else if (delivery.deliveryStatus == DeliveryStatus.OPEN) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: theme.primary)),
                      const SizedBox(width: 10),
                      Text("Searching for a driver...",
                          style: theme.bodyMedium.override(
                              fontFamily: 'Poppins',
                              fontStyle: FontStyle.italic,
                              color: theme.secondaryText)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: Text('Close',
                      style: theme.titleSmall.override(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateProgress(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.OPEN:
        return 0.05;
      case DeliveryStatus.ASSIGNED:
        return 0.25;
      case DeliveryStatus.PICKED_UP:
        return 0.60;
      case DeliveryStatus.COMPLETED:
        return 1.0;
      case DeliveryStatus.CANCELLED:
        return 0.0;
      default:
        return 0.0;
    }
  }

  Color _getStatusColor(DeliveryStatus status) {
    final theme = FlutterFlowTheme.of(context);
    switch (status) {
      case DeliveryStatus.ASSIGNED:
        return theme.primary;
      case DeliveryStatus.PICKED_UP:
        return theme.warning;
      case DeliveryStatus.OPEN:
        return theme.accent2 ?? theme.warning;
      case DeliveryStatus.COMPLETED:
        return theme.success;
      case DeliveryStatus.CANCELLED:
        return theme.error;
      default:
        return theme.secondaryText;
    }
  }

  void _callDriver(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showToast('Could not launch phone dialer.', success: false);
      }
    } catch (e) {
      _showToast('Could not make a call to $phone', success: false);
    }
  }

  void _showToast(String message, {required bool success}) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: success ? Colors.green : Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    const p = 0.017453292519943295;
    final h = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(h));
  }

  // This method for HTTP distance/time is no longer used if ETA is removed.
  // Kept here if you decide to re-add it.
  // Future<Map<String, dynamic>> getTravelTimeAndDistance(double lat1, double lon1, double lat2, double lon2) async { ... }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  // --- Zoom and Route Drawing Logic ---
  // zoomToFitRoute now becomes more about framing driver and dropoff if route is shown
  void zoomToFitRoute() {
    if (_mapController == null) return;

    List<LatLng> pointsToConsiderForBounds = [];
    if (_driverLocation != null)
      pointsToConsiderForBounds.add(_driverLocation!);
    if (_currentDelivery != null)
      pointsToConsiderForBounds.add(LatLng(_currentDelivery!.dropOffLatitude,
          _currentDelivery!.dropOffLongitude));
    if (_routeCoordinates.isNotEmpty)
      pointsToConsiderForBounds.addAll(_routeCoordinates);

    if (pointsToConsiderForBounds.length < 2 && _driverLocation != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(
          _driverLocation!, 15)); // Zoom to driver if only driver
      return;
    }
    if (pointsToConsiderForBounds.length < 2) return;

    double minLat = pointsToConsiderForBounds.first.latitude;
    double maxLat = pointsToConsiderForBounds.first.latitude;
    double minLng = pointsToConsiderForBounds.first.longitude;
    double maxLng = pointsToConsiderForBounds.first.longitude;

    for (final point in pointsToConsiderForBounds) {
      minLat = min(minLat, point.latitude);
      maxLat = max(maxLat, point.latitude);
      minLng = min(minLng, point.longitude);
      maxLng = max(maxLng, point.longitude);
    }

    final double latPadding = (maxLat - minLat).abs() < 0.0001
        ? 0.02
        : (maxLat - minLat).abs() * 0.25;
    final double lngPadding = (maxLng - minLng).abs() < 0.0001
        ? 0.02
        : (maxLng - minLng).abs() * 0.25;

    LatLng southwest = LatLng(minLat - latPadding, minLng - lngPadding);
    LatLng northeast = LatLng(maxLat + latPadding, maxLng + lngPadding);

    if (southwest.latitude > northeast.latitude) {
      final tempLat = southwest.latitude;
      southwest = LatLng(northeast.latitude, southwest.longitude);
      northeast = LatLng(tempLat, northeast.longitude);
    }
    if (southwest.longitude > northeast.longitude) {
      final tempLng = southwest.longitude;
      southwest = LatLng(southwest.latitude, northeast.longitude);
      northeast = LatLng(northeast.latitude, tempLng);
    }

    try {
      if (southwest.latitude <= northeast.latitude &&
          southwest.longitude <= northeast.longitude) {
        _mapController!.animateCamera(CameraUpdate.newLatLngBounds(
            LatLngBounds(southwest: southwest, northeast: northeast),
            70.0)); // Increased padding
      } else {
        if (_driverLocation != null)
          _mapController!
              .animateCamera(CameraUpdate.newLatLngZoom(_driverLocation!, 14));
      }
    } catch (e) {
      if (_driverLocation != null)
        _mapController!
            .animateCamera(CameraUpdate.newLatLngZoom(_driverLocation!, 14));
    }
  }
}
