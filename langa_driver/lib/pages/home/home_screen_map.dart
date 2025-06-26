import 'dart:async';
import 'dart:convert';
import 'dart:ffi' hide Size; // Hide Size from dart:ffi to avoid conflict
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:langas_driver/bloc/auth/auth_bloc/auth_bloc_bloc.dart';
import 'package:langas_driver/bloc/auth/auth_bloc/auth_bloc_state.dart';
import 'package:langas_driver/bloc/delivery/nearby_deliveries_bloc/nearby_deliveries_bloc_bloc.dart';
import 'package:langas_driver/bloc/delivery/nearby_deliveries_bloc/nearby_deliveries_bloc_event.dart';
import 'package:langas_driver/bloc/delivery/nearby_deliveries_bloc/nearby_deliveries_bloc_state.dart';
import 'package:langas_driver/bloc/driver_profile/driver_profile_bloc_bloc.dart';
import 'package:langas_driver/bloc/driver_profile/driver_profile_bloc_event.dart';
import 'package:langas_driver/bloc/driver_profile/driver_profile_bloc_state.dart';
import 'package:langas_driver/bloc/vehicles/vehicle_management/vehicle_management_bloc_bloc.dart';
import 'package:langas_driver/bloc/vehicles/vehicle_management/vehicle_management_bloc_event.dart';
import 'package:langas_driver/bloc/vehicles/vehicle_management/vehicle_management_bloc_state.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_icon_button.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_widgets.dart';
import 'package:langas_driver/models/delivery_models.dart';
import 'package:langas_driver/models/auth_models.dart';
import 'package:langas_driver/models/firebase_delivery_model.dart';
import 'package:langas_driver/nav/nav.dart';
import 'package:langas_driver/pages/Drawer/Drawer_widget.dart';
import 'package:langas_driver/services/geolocation.dart';
import 'package:langas_driver/utils/delivery_enums.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  _DriverHomePageState createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  GoogleMapController? _mapController;
  final Completer<GoogleMapController> _mapControllerCompleter = Completer();

  LatLng _currentLocation = const LatLng(-17.8252, 31.0335);
  String _locationAddress = "Locating...";
  Set<Marker> _markers = {};
  bool _isLoading = true;
  bool _isMapReady = false;
  String? _driverId;
  VehicleType? _activeVehicleType;

  late GeolocationService _geolocationService;
  late NearbyDeliveriesBloc _nearbyDeliveriesBloc;
  late AuthBloc _authBloc;
  late VehicleManagementBloc _vehicleManagementBloc;
  late DriverProfileBloc _driverProfileBloc;
  bool _isOnline = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  BitmapDescriptor? _deliveryMarkerIcon;

  final String _mapStyle =
      '''[{"featureType":"administrative","elementType":"geometry.fill","stylers":[{"color":"#d6e2e6"}]},{"featureType":"administrative","elementType":"geometry.stroke","stylers":[{"color":"#cfd4d5"}]},{"featureType":"administrative","elementType":"labels.text.fill","stylers":[{"color":"#7492a8"}]},{"featureType":"administrative.neighborhood","elementType":"labels.text.fill","stylers":[{"lightness":25}]},{"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#ffffff"}]},{"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#e9e9e9"}]},{"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#666666"}]},{"featureType":"water","elementType":"all","stylers":[{"color":"#2659F0"},{"lightness":35}]}]''';

  @override
  void initState() {
    super.initState();
    _geolocationService = context.read<GeolocationService>();
    _nearbyDeliveriesBloc = context.read<NearbyDeliveriesBloc>();
    _authBloc = context.read<AuthBloc>();
    _vehicleManagementBloc = context.read<VehicleManagementBloc>();
    _driverProfileBloc = context.read<DriverProfileBloc>();
    //print("========> this is the logged in profile ${jsonEncode(_driverProfileBloc)}");

    _loadCustomMarkerIcon();
    _initializeMapAndData();
  }

  Future<void> _loadCustomMarkerIcon() async {
    try {
      _deliveryMarkerIcon = await BitmapDescriptor.asset(
        ImageConfiguration(size: Size(48, 48)), // Remove 'const' here
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

  Future<void> _initializeMapAndData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final position = await _geolocationService.getCurrentLocation();
    if (!mounted) return;

    if (position != null) {
      _currentLocation = LatLng(position.latitude, position.longitude);
      await _updateLocationAddress(_currentLocation);
      _updateMarkers([]);
      if (mounted) setState(() => _isMapReady = true);

      if (_mapControllerCompleter.isCompleted && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _currentLocation, zoom: 14.0),
          ),
        );
      } else {
        _mapControllerCompleter.future.then((controller) {
          if (mounted) {
            controller.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(target: _currentLocation, zoom: 14.0),
              ),
            );
          }
        });
      }

      final authState = _authBloc.state;
      if (authState is AuthDriverAuthenticated) {
        final DriverProfile? driverProfile = authState.authData.driverProfile;
        _driverId = driverProfile?.id.toString();

        if (driverProfile?.activeVehicle != null) {
          _activeVehicleType = driverProfile!.activeVehicle!.vehicleType;
        } else {
          if (_driverId != null && _driverId!.isNotEmpty) {
            _vehicleManagementBloc
                .add(LoadDriverVehicles(driverId: _driverId!));
          }
        }

        if (_driverId != null && _driverId!.isNotEmpty) {
          if (_activeVehicleType != null) {
            _nearbyDeliveriesBloc.add(LoadNearbyDeliveries(
                driverId: _driverId!, vehicleType: _activeVehicleType!));
          } else {
            if (driverProfile?.activeVehicle == null &&
                _vehicleManagementBloc.state is! VehicleLoading &&
                _vehicleManagementBloc.state is! VehicleListLoadSuccess) {
              if (_driverId != null && _driverId!.isNotEmpty) {
                _vehicleManagementBloc
                    .add(LoadDriverVehicles(driverId: _driverId!));
              }
            }
          }
        } else {
          _showError('Driver ID not available.');
          if (mounted) setState(() => _isLoading = false);
        }
      } else {
        _showError('User not authenticated.');
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      _locationAddress = "Location Unavailable";
      _showError(
          'Could not get current location. Please enable location services and permissions.');
      if (mounted) {
        setState(() {
          _isMapReady = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateLocationAddress(LatLng location) async {
    final address = await _geolocationService.getAddressFromCoordinates(
        location.latitude, location.longitude);
    if (mounted) {
      setState(() {
        _locationAddress = address;
      });
    }
  }

  Future<void> _goToCurrentLocation() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final position = await _geolocationService.getCurrentLocation();
    if (!mounted) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (position != null) {
      _currentLocation = LatLng(position.latitude, position.longitude);
      await _updateLocationAddress(_currentLocation);
      _goToLatLng(_currentLocation, zoom: 15.0);

      final nearbyState = _nearbyDeliveriesBloc.state;
      if (nearbyState is NearbyDeliveriesLoadSuccess) {
        _updateMarkers(nearbyState.deliveries);
      } else {
        _updateMarkers([]);
      }
    } else {
      _showError('Could not get current location.');
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _goToLatLng(LatLng location, {double zoom = 14.0}) async {
    if (!_mapControllerCompleter.isCompleted || _mapController == null) return;
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: zoom),
      ),
    );
  }

  void _refreshData() {
    _goToCurrentLocation();
    if (_driverId != null && _activeVehicleType != null) {
      _nearbyDeliveriesBloc.add(LoadNearbyDeliveries(
          driverId: _driverId!,
          vehicleType: _activeVehicleType!,
          isRefresh: true));
    } else {
      _initializeMapAndData();
    }
  }

  Future<void> _updateMarkers(List<FirebaseDelivery> deliveries) async {
    if (!mounted) return;
    Set<Marker> updatedMarkers = {};

    updatedMarkers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: _currentLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Your Location'),
      ),
    );

    for (final delivery in deliveries) {
      final position =
          LatLng(delivery.pickupLatitude, delivery.pickupLongitude);
      double distanceInMeters = 0;
      if (_currentLocation.latitude != 0.0 ||
          _currentLocation.longitude != 0.0) {
        distanceInMeters = await _geolocationService.calculateDistance(
          _currentLocation.latitude,
          _currentLocation.longitude,
          position.latitude,
          position.longitude,
        );
      }
      final distanceKm = (distanceInMeters / 1000).toStringAsFixed(1);

      updatedMarkers.add(
        Marker(
          markerId: MarkerId('delivery_${delivery.id}'),
          position: position,
          icon: _deliveryMarkerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(
            title: 'Pickup: ${delivery.pickupLocation}',
            snippet:
                '\$${delivery.priceAmount.toStringAsFixed(2)} | $distanceKm km away',
          ),
          onTap: () => _showDeliveryDetails(delivery),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _markers = updatedMarkers;
      });
    }
  }

  void _showDeliveryDetails(FirebaseDelivery delivery) {
    context.push('/deliveryRoute', extra: delivery.id.toString());
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showWarning(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.amber),
    );
  }

  void _toggleOnlineStatus() {
    if (_driverId == null) {
      _showError('Driver ID not available');
      return;
    }

    final newStatus = !_isOnline;
    _driverProfileBloc.add(
      UpdateWorkStatus(
        driverId: int.parse(_driverId!),
        status: newStatus,
      ),
    );
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
        title: BlocConsumer<DriverProfileBloc, DriverProfileState>(
          listener: (context, state) {
            if (state is UpdateWorkStatusSuccess) {
              setState(() {
                _isOnline = !_isOnline;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Status updated to ${_isOnline ? 'ONLINE' : 'OFFLINE'}'),
                  backgroundColor: _isOnline ? Colors.green : Colors.grey,
                  duration: const Duration(seconds: 2),
                ),
              );
            } else if (state is UpdateStatusFailure) {
              _showError(state.failure.message);
            } else if (state is DriverProfileLoadSuccess) {
              setState(() {
                _isOnline = state.driverProfile.onlineStatus;
              });
            }
          },
          builder: (context, state) {
            return GestureDetector(
              onTap: _toggleOnlineStatus,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isOnline ? Colors.blue : Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isOnline ? Icons.circle : Icons.circle_outlined,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isOnline ? 'ONLINE' : 'OFFLINE',
                          style: theme.bodyMedium.override(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: const Icon(Icons.refresh_rounded,
                color: Colors.white, size: 24.0),
            onPressed: _refreshData,
          ),
        ],
        centerTitle: true,
        elevation: 0,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<NearbyDeliveriesBloc, NearbyDeliveriesState>(
            listener: (context, state) {
              if (state is NearbyDeliveriesLoadSuccess) {
                if (mounted) {
                  _updateMarkers(state.deliveries);
                  setState(() => _isLoading = false);
                }
              } else if (state is NearbyDeliveriesLoadFailure) {
                if (mounted) {
                  _showError(
                      'Failed to load nearby deliveries: ${state.failure.message}');
                  _updateMarkers([]);
                  setState(() => _isLoading = false);
                }
              } else if (state is NearbyDeliveriesLoading) {
                if (mounted) setState(() => _isLoading = true);
              } else if (state is ProposalSuccess) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.green),
                  );
                  _refreshData();
                }
              } else if (state is ProposalFailure) {
                if (mounted)
                  _showError('Failed to propose: ${state.failure.message}');
              }
            },
          ),
          BlocListener<VehicleManagementBloc, VehicleManagementState>(
              listener: (context, state) {
            if (state is VehicleListLoadSuccess) {
              VehicleType? determinedVehicleType;
              if (state.activeVehicleId != null) {
                try {
                  final activeVehicle = state.vehicles.firstWhere((v) =>
                      v.vehicleId == state.activeVehicleId && v.active == true);
                  determinedVehicleType = activeVehicle.vehicleType;
                } catch (e) {
                  if (state.vehicles.any((v) => v.active == true)) {
                    determinedVehicleType = state.vehicles
                        .firstWhere((v) => v.active == true)
                        .vehicleType;
                  }
                }
              } else if (state.vehicles.any((v) => v.active == true)) {
                determinedVehicleType = state.vehicles
                    .firstWhere((v) => v.active == true)
                    .vehicleType;
              }

              if (determinedVehicleType != null) {
                bool shouldFetchDeliveries = _activeVehicleType == null ||
                    _activeVehicleType != determinedVehicleType;
                if (mounted) {
                  setState(() {
                    _activeVehicleType = determinedVehicleType;
                  });
                }
                if (shouldFetchDeliveries &&
                    _driverId != null &&
                    _driverId!.isNotEmpty) {
                  _nearbyDeliveriesBloc.add(LoadNearbyDeliveries(
                      driverId: _driverId!, vehicleType: _activeVehicleType!));
                }
              } else if (mounted && _activeVehicleType == null) {
                _showWarning(
                    "No APPROVED vehicles available. Please add/select one to see deliveries.");
                _updateMarkers([]);
                if (mounted) setState(() => _isLoading = false);
              }
            } else if (state is VehicleSwitchSuccess) {
              if (_driverId != null) {
                context
                    .read<VehicleManagementBloc>()
                    .add(LoadDriverVehicles(driverId: _driverId!));
              }
            } else if (state is VehicleListLoadFailure) {
              _showError(
                  "Failed to load vehicle information: ${state.failure.message}");
              _updateMarkers([]);
              if (mounted) setState(() => _isLoading = false);
            }
          }),
        ],
        child: Stack(
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
                    onCameraIdle: () async {
                      if (!_mapControllerCompleter.isCompleted ||
                          _mapController == null) return;
                      final LatLngBounds visibleRegion =
                          await _mapController!.getVisibleRegion();
                      final LatLng centerLatLng = LatLng(
                        (visibleRegion.northeast.latitude +
                                visibleRegion.southwest.latitude) /
                            2,
                        (visibleRegion.northeast.longitude +
                                visibleRegion.southwest.longitude) /
                            2,
                      );
                      await _updateLocationAddress(centerLatLng);
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
                  child: SpinKitSpinningLines(
                    color: Colors.white,
                    size: 50.0,
                    lineWidth: 2,
                  ),
                ),
              ),
          ],
        ),
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
              onPressed: _goToCurrentLocation,
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
            if (_activeVehicleType == null) {
              _showWarning(
                  "Select an active vehicle in the Vehicles tab to see nearby deliveries");
              return;
            }
            final driverProfile = context.read<DriverProfileBloc>().state;
            if (driverProfile is DriverProfileLoadSuccess) {
              if (driverProfile.driverProfile.onlineStatus) {
                context.push('/nearbyDeliveries');
              } else {
                SnackBar snackBar = const SnackBar(
                  content: Text('You need to be online',
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.amber,
                  duration: Duration(seconds: 2),
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            }
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
