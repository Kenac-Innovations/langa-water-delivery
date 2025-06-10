import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:langas_user/flutter_flow/nav/nav.dart';
import 'package:langas_user/pages/drawer/drawer_widget.dart';
import 'package:langas_user/pages/home_page/map_widgets.dart';
import 'package:langas_user/pages/home_page/ui_componets.dart';
import 'package:langas_user/services/geolocation.dart';
import 'package:langas_user/util/api_constants.dart';
import '../../flutter_flow/flutter_flow_icon_button.dart';
import '../../flutter_flow/flutter_flow_theme.dart';

class HomeScreenPage extends StatefulWidget {
  const HomeScreenPage({Key? key}) : super(key: key);

  @override
  _HomeScreenPageState createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreenPage> {
  String googleApikey = ApiConstants.googleApiKey;
  GoogleMapController? mapController;
  CameraPosition? cameraPosition;

  LatLng currentLatLng = const LatLng(-17.8252, 31.0335);
  String currentLocationString = "Loading location...";
  final List<Marker> _markers = <Marker>[];
  bool _isLoadingLocation = true;
  bool _isProcessingAction = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSelectedInstant = false;
  bool isSelectedScheduled = false;

  late GeolocationService _geolocationService;

  @override
  void initState() {
    super.initState();
    _geolocationService = context.read<GeolocationService>();
    _initializeLocation();
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    if (!mounted) return;
    setState(() {
      _isLoadingLocation = true;
      currentLocationString = "Fetching location...";
    });
    await _updateLocation(animateCamera: false);
    if (mounted) {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _updateLocation({bool animateCamera = false}) async {
    try {
      Position? position = await _geolocationService.getCurrentLocation();
      if (!mounted) return;

      if (position != null) {
        final newLatLng = LatLng(position.latitude, position.longitude);
        String address = "Address lookup failed";
        try {
          address = await _geolocationService.getAddressFromCoordinates(
              position.latitude, position.longitude);
        } catch (addrErr) {
          debugPrint(
              "[HomeScreenPage] _updateLocation: Error getting address: $addrErr");
        }

        setState(() {
          currentLatLng = newLatLng;
          currentLocationString =
              address.isNotEmpty ? address : "Current Location";
        });

        if (mapController != null) {
          final cameraUpdate = CameraUpdate.newCameraPosition(
            CameraPosition(target: newLatLng, zoom: 16.0),
          );
          if (animateCamera) {
            mapController!.animateCamera(cameraUpdate);
          } else {
            mapController!.moveCamera(cameraUpdate);
          }
        }
      } else {
        setState(() {
          currentLocationString = "Could not get location";
        });
        _showErrorToast(
            "Could not access your location. Please ensure location services and permissions are enabled.");
      }
    } catch (e) {
      debugPrint("Error updating location: $e");
      if (mounted) {
        setState(() {
          currentLocationString = "Error getting location";
        });
        _showErrorToast("Error getting location. Please try again.");
      }
    }
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: scaffoldKey,
        drawer: const AppDrawer(),
        appBar: _buildAppBar(),
        body: _buildMapContent(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: FlutterFlowTheme.of(context).primary,
      automaticallyImplyLeading: false,
      leading: FlutterFlowIconButton(
        borderColor: Colors.transparent,
        borderRadius: 30.0,
        borderWidth: 1.0,
        buttonSize: 50.0,
        icon: const Icon(Icons.menu, color: Colors.white, size: 28.0),
        onPressed: () => scaffoldKey.currentState?.openDrawer(),
      ),
      title: Text(
        'Home',
        style: FlutterFlowTheme.of(context).headlineMedium.override(
              fontFamily: 'Poppins',
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () => context.pushNamed('Notification'),
        ),
      ],
      centerTitle: true,
      elevation: 0,
    );
  }

  Widget _buildMapContent() {
    return Stack(
      children: [
        // --- Simplified GoogleMap ---
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: currentLatLng, // Use default or fetched location
            zoom: 14.0, // Start with a reasonable zoom
          ),
          mapType: MapType.normal,
          onMapCreated: (controller) {
            print("--- Google Map Created ---"); // Check if this prints
            mapController = controller;
            // Move camera after map is created if location is ready
            if (!_isLoadingLocation) {
              mapController?.moveCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(target: currentLatLng, zoom: 16.0)));
            }
          },
          myLocationEnabled: true, // Keep blue dot
          myLocationButtonEnabled: false, // Keep custom button
          // Temporarily remove other properties to test basic rendering
          // onCameraMove: (CameraPosition cameraPositiona) {
          //   cameraPosition = cameraPositiona;
          // },
          // markers: Set<Marker>.of(_markers),
          // compassEnabled: true,
          // zoomControlsEnabled: false,
          // zoomGesturesEnabled: true,
        ),
        // --- End Simplified GoogleMap ---

        // Keep other UI elements
        MapWidgets.buildSearchBar(
            context: context,
            location: currentLocationString,
            onTap: _handleSearchTap),

        MapWidgets.buildBottomCard(
          context: context,
          isSelected: isSelectedInstant,
          isSelected2: false,
          isSelected3: isSelectedScheduled,
          onInstantPressed: () {
            setState(() {
              isSelectedInstant = true;
              isSelectedScheduled = false;
            });
            _navigateToInstantDelivery();
          },
        ),

        Positioned(
          bottom: 200,
          right: 16,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            onPressed: _isLoadingLocation || _isProcessingAction
                ? null
                : _goToCurrentLocation,
            child: _isProcessingAction
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)))
                : const Icon(Icons.my_location, color: Colors.black54),
          ),
        ),

        if (_isLoadingLocation)
          Container(
              color: Colors.white,
              child: UIComponents.buildLoadingIndicator(context)),

        UIComponents.buildProgressOverlay(
            _isProcessingAction && !_isLoadingLocation)
      ],
    );
  }

  Future<void> _handleSearchTap() async {
    if (_isLoadingLocation || _isProcessingAction) return;

    try {
      var place = await PlacesAutocomplete.show(
        context: context,
        apiKey: googleApikey,
        mode: Mode.overlay,
        types: [],
        strictbounds: false,
        onError: (err) {
          debugPrint("Places API error: ${err.errorMessage}");
          _showErrorToast("Error searching places: ${err.errorMessage}");
        },
      );

      if (place != null && mounted) {
        setState(() {
          currentLocationString = place.description.toString();
          _isProcessingAction = true;
        });

        final plist = GoogleMapsPlaces(
          apiKey: googleApikey,
          apiHeaders: await const GoogleApiHeaders().getHeaders(),
        );
        String placeid = place.placeId ?? "0";
        final detail = await plist.getDetailsByPlaceId(placeid);

        if (!mounted) return;

        if (detail.result.geometry != null) {
          final geometry = detail.result.geometry!;
          final lat = geometry.location.lat;
          final lang = geometry.location.lng;
          var newLatLng = LatLng(lat, lang);

          setState(() {
            currentLatLng = newLatLng;
          });

          mapController?.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(target: newLatLng, zoom: 17)));
        } else {
          _showErrorToast(
              "Could not get location details for the selected place.");
        }
        setState(() {
          _isProcessingAction = false;
        });
      }
    } catch (e) {
      debugPrint("Error in search tap: $e");
      if (mounted) {
        setState(() {
          _isProcessingAction = false;
        });
        _showErrorToast("An error occurred during search.");
      }
    }
  }

  Future<void> _goToCurrentLocation() async {
    setState(() => _isProcessingAction = true);
    await _updateLocation(animateCamera: true);
    if (mounted) {
      setState(() => _isProcessingAction = false);
    }
  }

  void _navigateToInstantDelivery() {
    if (_isLoadingLocation ||
        (currentLatLng.latitude == -17.8252 &&
            currentLatLng.longitude == 31.0335 &&
            !currentLocationString.contains("Error"))) {
      _showErrorToast("Please wait for location to load or select manually.");
      return;
    }
    context.pushNamed('Create_Delivery', extra: {
      'currentLocation': currentLocationString,
      'latLng': currentLatLng
    });
  }
}
