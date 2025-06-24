import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:langas_user/services/geolocation.dart';
import 'package:langas_user/util/api_constants.dart';

class LocationResult {
  final LatLng coordinates;
  final String address;

  LocationResult({required this.coordinates, required this.address});
}

class LocationPickerPage extends StatefulWidget {
  final LatLng? initialCenter;

  const LocationPickerPage({Key? key, this.initialCenter}) : super(key: key);

  @override
  _LocationPickerPageState createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  // IMPORTANT: Replace with your actual key
  String googleApikey = ApiConstants.googleApiKey;
  GoogleMapController? mapController;
  LatLng _currentMapCenter = const LatLng(-17.8252, 31.0335);
  String _currentAddress = "Move the map to select location";
  bool _isFetchingAddress = false;
  bool _isMapReady = false;
  Timer? _debounce;

  late GeolocationService _geolocationService;

  @override
  void initState() {
    super.initState();
    _geolocationService = context.read<GeolocationService>();
    _initializeMapCenter();
  }

  @override
  void dispose() {
    mapController?.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _initializeMapCenter() async {
    LatLng center;
    if (widget.initialCenter != null) {
      center = widget.initialCenter!;
    } else {
      try {
        Position? position = await _geolocationService.getCurrentLocation();
        if (position != null) {
          center = LatLng(position.latitude, position.longitude);
        } else {
          center = const LatLng(-17.8252, 31.0335);
          _showErrorToast(
              "Could not get current location. Defaulting map center.");
        }
      } catch (e) {
        center = const LatLng(-17.8252, 31.0335);
        _showErrorToast("Error getting initial location.");
      }
    }

    if (mounted) {
      setState(() {
        _currentMapCenter = center;
      });
      if (_isMapReady && mapController != null) {
        mapController!
            .moveCamera(CameraUpdate.newLatLngZoom(_currentMapCenter, 16.0));
        _fetchAddressForCenter(_currentMapCenter);
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      _isMapReady = true;
    });
    if (_currentMapCenter.latitude != -17.8252) {
      mapController!
          .moveCamera(CameraUpdate.newLatLngZoom(_currentMapCenter, 16.0));
      _fetchAddressForCenter(_currentMapCenter);
    } else {
      // If still default, try initializing again
      _initializeMapCenter();
    }
  }

  void _onCameraMove(CameraPosition position) {
    _currentMapCenter = position.target;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _fetchAddressForCenter(position.target);
      }
    });
  }

  void _onCameraIdle() {
    print("Camera Idle at: $_currentMapCenter");
  }

  Future<void> _fetchAddressForCenter(LatLng center) async {
    if (!mounted) return;
    setState(() {
      _isFetchingAddress = true;
      _currentAddress = "Loading address...";
    });
    try {
      String address = await _geolocationService.getAddressFromCoordinates(
        center.latitude,
        center.longitude,
      );
      if (mounted) {
        setState(() {
          _currentAddress = address.isNotEmpty ? address : "Address not found";
          _isFetchingAddress = false;
        });
      }
    } catch (e) {
      print("Error fetching address: $e");
      if (mounted) {
        setState(() {
          _currentAddress = "Error getting address";
          _isFetchingAddress = false;
        });
      }
    }
  }

  void _confirmSelection() {
    if (_currentAddress.contains("Error") ||
        _currentAddress.contains("Loading") ||
        _currentAddress.contains("not found")) {
      _showErrorToast("Please select a valid location with an address.");
      return;
    }
    final result = LocationResult(
      coordinates: _currentMapCenter,
      address: _currentAddress,
    );
    Navigator.pop(context, result);
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  // --- Search Functionality ---
  Future<void> _handleSearchTap() async {
    try {
      Prediction? p = await PlacesAutocomplete.show(
          context: context,
          apiKey: googleApikey,
          onError: (response) {
            debugPrint("Places Autocomplete Error: ${response.errorMessage}");
            _showErrorToast("Error searching places: ${response.errorMessage}");
          },
          mode: Mode.overlay,
          language: "en",
          strictbounds: false,
          types: [
            ""
          ], // Empty array for general results
          components: [
            Component(Component.country, "zw")
          ]); // Restrict to Zimbabwe

      if (p != null) {
        await _displayPrediction(p);
      }
    } catch (e) {
      debugPrint("Error showing places autocomplete: $e");
      _showErrorToast("An error occurred during search.");
    }
  }

  Future<void> _displayPrediction(Prediction p) async {
    GoogleMapsPlaces places = GoogleMapsPlaces(
      apiKey: googleApikey,
      apiHeaders: await const GoogleApiHeaders().getHeaders(),
    );
    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);
    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;
    final newLatLng = LatLng(lat, lng);

    if (mounted) {
      setState(() {
        _currentMapCenter = newLatLng;
        _currentAddress = p.description ?? "Selected location";
        _isFetchingAddress = false; // Address comes from prediction description
      });
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: newLatLng, zoom: 17.0),
        ),
      );
    }
  }
  // --- End Search Functionality ---

  @override
  Widget build(BuildContext context) {
    final ffTheme = FlutterFlowTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Location',
          style: TextStyle(
            fontFamily: FlutterFlowTheme.of(context).headlineMediumFamily,
          ),
        ),
        backgroundColor: ffTheme.primary,
        foregroundColor: Colors.white,
        elevation: 1,
        actions: [
          // Add search button to AppBar
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _handleSearchTap,
            tooltip: 'Search Location',
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentMapCenter,
              zoom: 16.0,
            ),
            onMapCreated: _onMapCreated,
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            mapType: MapType.normal,
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40.0),
              child: Icon(
                Icons.location_pin,
                size: 40.0,
                color: Colors.red,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0)
                  .copyWith(bottom: MediaQuery.of(context).padding.bottom + 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: ffTheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _isFetchingAddress
                            ? Text("Loading address...",
                                style: ffTheme.bodyMedium.override(
                                    fontFamily: 'Poppins', color: Colors.grey))
                            : Text(
                                _currentAddress,
                                style: ffTheme.bodyLarge
                                    .override(fontFamily: 'Poppins'),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isFetchingAddress ? null : _confirmSelection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ffTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Confirm Location',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
