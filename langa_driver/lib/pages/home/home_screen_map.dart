import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_icon_button.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_widgets.dart';
import 'package:langas_driver/nav/nav.dart';
import 'package:langas_driver/pages/Drawer/Drawer_widget.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  _DriverHomePageState createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  GoogleMapController? _mapController;
  final Completer<GoogleMapController> _mapControllerCompleter = Completer();

  final LatLng _currentLocation = const LatLng(-17.8252, 31.0335);
  final String _locationAddress = "Harare, Zimbabwe";
  final Set<Marker> _markers = {};
  final bool _isLoading = false;
  final bool _isMapReady = true;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  BitmapDescriptor? _deliveryMarkerIcon;

  final String _mapStyle =
      '''[{"featureType":"administrative","elementType":"geometry.fill","stylers":[{"color":"#d6e2e6"}]},{"featureType":"administrative","elementType":"geometry.stroke","stylers":[{"color":"#cfd4d5"}]},{"featureType":"administrative","elementType":"labels.text.fill","stylers":[{"color":"#7492a8"}]},{"featureType":"administrative.neighborhood","elementType":"labels.text.fill","stylers":[{"lightness":25}]},{"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#ffffff"}]},{"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#e9e9e9"}]},{"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#666666"}]},{"featureType":"water","elementType":"all","stylers":[{"color":"#2659F0"},{"lightness":35}]}]''';

  @override
  void initState() {
    super.initState();
    _loadCustomMarkerIcon();
  }

  Future<void> _loadCustomMarkerIcon() async {
    // The existing implementation for loading the custom marker is fine.
    try {
      _deliveryMarkerIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/images/tracking.png',
      );
    } catch (e) {
      print(
          "Error loading custom delivery marker icon using BitmapDescriptor.asset, using default: $e");
      _deliveryMarkerIcon =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      key: scaffoldKey,
      drawer: CustomDrawerWidget(
        scaffoldKey: scaffoldKey,
      ),
      appBar: AppBar(
        backgroundColor: theme.primary,
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30.0,
          borderWidth: 1.0,
          buttonSize: 60.0,
          icon: const Icon(Icons.menu, color: Colors.white, size: 28.0),
          onPressed: () async {
            if (scaffoldKey.currentState?.isDrawerOpen ?? false) {
              scaffoldKey.currentState?.closeDrawer();
            } else {
              scaffoldKey.currentState?.openDrawer();
            }
          },
        ),
        title: Text(
          'Home',
          style: theme.headlineMedium.override(
            fontFamily: theme.headlineMediumFamily,
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: const Icon(Icons.refresh_rounded,
                color: Colors.white, size: 24.0),
            onPressed: () {
              // Refresh functionality can be adapted for a static page if needed
            },
          ),
        ],
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          _isMapReady
              ? GoogleMap(
                  zoomGesturesEnabled: true,
                  zoomControlsEnabled: false,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation,
                    zoom: 14.0,
                  ),
                  mapType: MapType.normal,
                  onMapCreated: (controller) {
                    if (!_mapControllerCompleter.isCompleted) {
                      _mapControllerCompleter.complete(controller);
                    }
                    _mapController = controller;
                    _mapController?.setMapStyle(_mapStyle);
                  },
                  markers: _markers,
                )
              : const Center(
                  child: Text("Initializing Map...",
                      style: TextStyle(fontSize: 16))),
          if (_isMapReady) ...[
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: _buildLocationCard(theme),
            ),
            Align(
              alignment: const AlignmentDirectional(0.0, 1.0),
              child: PointerInterceptor(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      16.0, 0.0, 16.0, 16.0),
                  child: _buildNearbyDeliveriesButton(theme),
                ),
              ),
            ),
          ],
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(FlutterFlowTheme theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.location_on, color: theme.primary, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _locationAddress,
                style: theme.bodyMedium.override(
                    fontFamily: 'Poppins', fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: Icon(Icons.my_location, color: theme.primary, size: 24),
              onPressed: () {
                // This would require location services.
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyDeliveriesButton(FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FFButtonWidget(
          onPressed: () {
            context.push('/nearbyDeliveries');
          },
          text: "AVAILABLE ORDERS",
          icon: const Icon(Icons.local_shipping_outlined, size: 20),
          options: FFButtonOptions(
            width: double.infinity,
            height: 54.0,
            padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
            iconPadding:
                const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
            color: theme.primary,
            textStyle: theme.titleSmall.override(
              fontFamily: 'Poppins',
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            elevation: 3.0,
            borderSide: const BorderSide(color: Colors.transparent, width: 1.0),
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
      ),
    );
  }
}
