import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:langas_driver/bloc/auth/auth_bloc/auth_bloc_bloc.dart';
import 'package:langas_driver/bloc/auth/auth_bloc/auth_bloc_state.dart';
import 'package:langas_driver/bloc/delivery/current_deliveries_bloc/current_deliveries_bloc_bloc.dart';
import 'package:langas_driver/bloc/delivery/current_deliveries_bloc/current_deliveries_bloc_event.dart';
import 'package:langas_driver/bloc/delivery/current_deliveries_bloc/current_deliveries_bloc_state.dart';
import 'package:langas_driver/dto/delivery_dto.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_icon_button.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_driver/models/delivery_models.dart';
import 'package:langas_driver/nav/nav.dart';
import 'package:langas_driver/services/geolocation.dart';
import 'package:langas_driver/services/location_tracking.dart';
import 'package:langas_driver/services/permision_helper.dart';
import 'package:langas_driver/utils/delivery_enums.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class CurrentDeliveriesWidget extends StatefulWidget {
  const CurrentDeliveriesWidget({super.key});

  @override
  State<CurrentDeliveriesWidget> createState() =>
      _CurrentDeliveriesWidgetState();
}

class _CurrentDeliveriesWidgetState extends State<CurrentDeliveriesWidget>
    with WidgetsBindingObserver {
  final unfocusNode = FocusNode();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _otpController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  String? _driverId;
  Position? _currentPosition;

  late GeolocationService _geolocationService;
  late CurrentDeliveriesBloc _currentDeliveriesBloc;
  late LocationTrackingManager _locationManager;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);

    _geolocationService = context.read<GeolocationService>();
    _currentDeliveriesBloc = context.read<CurrentDeliveriesBloc>();
    _locationManager = context.read<LocationTrackingManager>();

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthDriverAuthenticated) {
      _driverId = authState.authData.driverProfile?.id.toString();
    }
    _fetchInitialData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unfocusNode.dispose();
    _otpController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      var statusWhenInUse = await Permission.locationWhenInUse.status;
      var statusAlways = await Permission.locationAlways.status;
    }
  }

  Future<void> _fetchInitialData({bool isRefresh = true}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      _currentPosition = await _geolocationService.getCurrentLocation();
    } catch (e) {
      print("Error getting current position in _fetchInitialData: $e");
    }

    if (!mounted) return;

    if (_driverId == null) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthDriverAuthenticated) {
        _driverId = authState.authData.driverProfile?.id.toString();
      }
    }

    if (_driverId != null && _driverId!.isNotEmpty) {
      _currentDeliveriesBloc.add(
          LoadCurrentDeliveries(driverId: _driverId!, isRefresh: isRefresh));
    } else {
      _showErrorSnackbar('Driver ID not available. Cannot load deliveries.');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onScroll() {
    if (_isBottom) {
      final currentState = context.read<CurrentDeliveriesBloc>().state;
      if (currentState is CurrentDeliveriesLoadSuccess &&
          !currentState.hasReachedMax &&
          _driverId != null) {
        _currentDeliveriesBloc
            .add(LoadMoreCurrentDeliveries(driverId: _driverId!));
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _showPermissionDeniedDialog() async {
    if (!mounted) return;
    final theme = FlutterFlowTheme.of(context);
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          title: Text('Location Permission Required',
              style: theme.titleMedium.override(
                  fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
          content: Text(
              "Background location access ('Allow all the time') is essential for tracking active deliveries. Please enable this permission in the app settings to use this feature.",
              style: theme.bodyMedium.override(fontFamily: 'Poppins')),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',
                  style: TextStyle(
                      color: theme.secondaryText, fontFamily: 'Poppins')),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text('Open Settings',
                  style: TextStyle(
                      color: theme.primary,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchMapsUrl(double lat, double lng) async {
    String googleMapsUrl;
    Position? currentPosition = await _geolocationService.getCurrentLocation();
    if (currentPosition != null) {
      googleMapsUrl =
          "https://www.google.com/maps/dir/?api=1&origin=${currentPosition.latitude},${currentPosition.longitude}&destination=$lat,$lng&travelmode=driving";
    } else {
      googleMapsUrl =
          "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
    }

    final Uri mapsUri = Uri.parse(googleMapsUrl);
    final Uri appleMapsUri = Uri.parse('maps://?daddr=$lat,$lng&dirflg=d');

    if (Platform.isIOS) {
      if (await canLaunchUrl(appleMapsUri)) {
        await launchUrl(appleMapsUri);
      } else if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri);
      } else {
        _showErrorSnackbar('Could not launch any maps app.');
      }
    } else {
      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri);
      } else {
        _showErrorSnackbar('Could not launch Google Maps.');
      }
    }
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, FlutterFlowTheme theme) {
    return AppBar(
      backgroundColor: theme.primary,
      automaticallyImplyLeading: false,
      leading: FlutterFlowIconButton(
        borderColor: Colors.transparent,
        borderRadius: 30.0,
        borderWidth: 1.0,
        buttonSize: 60.0,
        icon: const Icon(Icons.arrow_back_rounded,
            color: Colors.white, size: 24.0),
        onPressed: () async => context.go('/homePage'),
      ),
      title: Text(
        "Current Deliveries",
        style: theme.headlineMedium.override(
            fontFamily: theme.headlineMediumFamily,
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.w600),
      ),
      actions: [
        FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30.0,
          borderWidth: 1.0,
          buttonSize: 60.0,
          icon: const Icon(Icons.refresh_rounded,
              color: Colors.white, size: 24.0),
          onPressed: () => _fetchInitialData(isRefresh: true),
        ),
      ],
      centerTitle: true,
      elevation: 0,
    );
  }

  Widget _buildLoadingIndicator(FlutterFlowTheme theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpinKitSpinningLines(color: theme.primary, size: 50.0, lineWidth: 2),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text('Loading your deliveries...',
                style: theme.bodyMedium.override(
                    fontFamily: theme.bodyMediumFamily,
                    color: theme.secondaryText)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(FlutterFlowTheme theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_shipping_outlined,
              color: theme.secondaryText.withOpacity(0.6), size: 80),
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text('No Active Deliveries',
                style: theme.titleLarge.override(
                    fontFamily: theme.titleLargeFamily,
                    color: theme.primaryText,
                    fontWeight: FontWeight.w600)),
          ),
          Text('You don\'t have any active deliveries right now.',
              style: theme.bodyMedium.override(
                  fontFamily: theme.bodyMediumFamily,
                  color: theme.secondaryText),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  void _showPickupBottomSheet(Delivery delivery) {
    File? tempParcelImageFromSheet;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return StatefulBuilder(
          builder: (BuildContext modalContext, StateSetter setModalState) {
            Future<void> takePhoto() async {
              final XFile? photo = await _picker.pickImage(
                  source: ImageSource.camera, imageQuality: 70);
              if (photo != null) {
                setModalState(() {
                  tempParcelImageFromSheet = File(photo.path);
                });
              }
            }

            return Container(
              decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0))),
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(modalContext).viewInsets.bottom),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primary,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16.0),
                                topRight: Radius.circular(16.0))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pickup Parcel',
                                style: FlutterFlowTheme.of(context)
                                    .headlineSmall
                                    .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .headlineSmallFamily,
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('Order ID: ${delivery.deliverId}',
                                style: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .titleSmallFamily,
                                        color: Colors.white.withOpacity(0.8))),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Take a photo of the parcel',
                                style:
                                    FlutterFlowTheme.of(context).titleMedium),
                            const SizedBox(height: 8),
                            Text(
                                'Please take a clear photo of the parcel for verification purposes.',
                                style: FlutterFlowTheme.of(context).bodyMedium),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: takePhoto,
                              child: Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .alternate
                                        .withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: FlutterFlowTheme.of(context)
                                            .alternate)),
                                child: tempParcelImageFromSheet != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                            tempParcelImageFromSheet!,
                                            fit: BoxFit.cover))
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                            Icon(Icons.camera_alt,
                                                size: 48,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText),
                                            const SizedBox(height: 8),
                                            Text('Tap to take a photo',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium)
                                          ]),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                    child: OutlinedButton(
                                        onPressed: () =>
                                            Navigator.pop(bottomSheetContext),
                                        style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8))),
                                        child: const Text('Cancel'))),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: tempParcelImageFromSheet !=
                                                null &&
                                            _driverId != null
                                        ? () {
                                            Navigator.pop(bottomSheetContext);
                                            _startPickupAndTracking(delivery,
                                                pickupImage:
                                                    tempParcelImageFromSheet);
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8))),
                                    child: const Text('Confirm Pickup',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _startPickupAndTracking(Delivery delivery, {File? pickupImage}) async {
    bool permissionsGranted = await requestLocationPermissions();
    if (!mounted) return;

    if (!permissionsGranted) {
      _showPermissionDeniedDialog();
      return;
    }

    _currentPosition = await _geolocationService.getCurrentLocation();
    if (_currentPosition == null || _driverId == null) {
      _showErrorSnackbar("Could not get current location or driver ID.");
      return;
    }

    final pickupDto = PickupDeliveryRequest(
      driverId: int.parse(_driverId!),
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      pickupImage: pickupImage,
    );
    _currentDeliveriesBloc.add(
      PickupDeliveryRequested(
        deliveryId: delivery.deliverId.toString(),
        driverId: _driverId!,
        request: pickupDto,
      ),
    );

    try {
      await _locationManager.startTrackingService(
          _driverId!, delivery.deliverId.toString());
      print(
          "[CurrentDeliveriesWidget] Background tracking initiated for ${delivery.deliverId}");

      if (mounted) {
        context.pushNamed(
          'liveTracking',
          pathParameters: {
            'deliveryId': delivery.deliverId.toString(),
          },
          extra: {
            'driverId': _driverId!,
            'destinationCoordinates': LatLng(
              delivery.dropOffLatitude,
              delivery.dropOffLongitude,
            ),
            'destinationAddressForMaps':
                "${delivery.dropOffLatitude},${delivery.dropOffLongitude}",
          },
        );
      }
    } catch (e) {
      print(
          "[CurrentDeliveriesWidget] Error starting tracking or navigating: $e");
      _showErrorSnackbar("Failed to start live tracking. Check settings.");
    }
  }

  void _showCompleteDeliveryBottomSheet(Delivery delivery,
      {bool isRide = false}) {
    _otpController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return Container(
          decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0))),
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primary,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16.0),
                            topRight: Radius.circular(16.0))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isRide ? 'End Ride' : 'Complete Delivery',
                            style: FlutterFlowTheme.of(context)
                                .headlineSmall
                                .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .headlineSmallFamily,
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('Order ID: ${delivery.deliverId}',
                            style: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .titleSmallFamily,
                                    color: Colors.white.withOpacity(0.8))),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Enter the OTP',
                            style: FlutterFlowTheme.of(context).titleMedium),
                        const SizedBox(height: 8),
                        Text(
                            'Ask the recipient for the OTP to complete the ${isRide ? 'ride' : 'delivery'}.',
                            style: FlutterFlowTheme.of(context).bodyMedium),
                        const SizedBox(height: 16),
                        Form(
                          child: TextFormField(
                            controller: _otpController,
                            decoration: InputDecoration(
                                labelText: 'OTP Code (6 Digits)',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                labelStyle:
                                    const TextStyle(color: Colors.black),
                                hintStyle: TextStyle(
                                    color: Colors.black.withOpacity(0.5))),
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .titleMediumFamily,
                                    fontSize: 24,
                                    letterSpacing: 8,
                                    color: Colors.black),
                            cursorColor: Colors.black,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: (value) =>
                                value == null || value.length != 6
                                    ? 'Enter 6-digit OTP'
                                    : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                                child: OutlinedButton(
                                    onPressed: () =>
                                        Navigator.pop(bottomSheetContext),
                                    style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8))),
                                    child: const Text('Cancel'))),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_otpController.text.length == 6) {
                                    Navigator.pop(bottomSheetContext);
                                    _currentPosition = await _geolocationService
                                        .getCurrentLocation();
                                    if (_driverId != null &&
                                        _currentPosition != null) {
                                      final completeDto =
                                          CompleteDeliveryRequest(
                                        otp: _otpController.text,
                                        driverId: int.parse(_driverId!),
                                        latitude: _currentPosition!.latitude,
                                        longitude: _currentPosition!.longitude,
                                      );
                                      _currentDeliveriesBloc.add(
                                        CompleteDeliveryRequested(
                                          deliveryId:
                                              delivery.deliverId.toString(),
                                          driverId: _driverId!,
                                          request: completeDto,
                                        ),
                                      );
                                      try {
                                        if (await _locationManager
                                            .isServiceRunning()) {
                                          await _locationManager
                                              .stopTrackingService();
                                        }
                                      } catch (e) {
                                        print(
                                            "[CurrentDeliveriesWidget] Error stopping background tracking during fallback: $e");
                                      }
                                    } else {
                                      _showErrorSnackbar(
                                          "Could not get current location or driver ID.");
                                    }
                                  } else {
                                    ScaffoldMessenger.of(bottomSheetContext)
                                        .showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Please enter the complete 6-digit OTP'),
                                          backgroundColor: Colors.orange),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        FlutterFlowTheme.of(context).primary,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8))),
                                child: Text(isRide ? 'End Ride' : 'Complete',
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCancelConfirmation(Delivery delivery) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Delivery',
              style: TextStyle(fontFamily: 'Poppins')),
          content: Text(
              'Are you sure you want to cancel delivery #${delivery.deliverId}?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('No')),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                _currentPosition =
                    await _geolocationService.getCurrentLocation();
                if (_driverId != null && _currentPosition != null) {
                  final request = CancelDeliveryRequest(
                    driverId: int.parse(_driverId!),
                    latitude: _currentPosition!.latitude,
                    longitude: _currentPosition!.longitude,
                  );
                  _currentDeliveriesBloc.add(CancelDeliveryRequested(
                      deliveryId: delivery.deliverId.toString(),
                      driverId: _driverId!,
                      request: request));
                  try {
                    if (await _locationManager.isServiceRunning()) {
                      await _locationManager.stopTrackingService();
                    }
                  } catch (e) {
                    print(
                        "[CurrentDeliveriesWidget] Error stopping background tracking service during cancellation: $e");
                  }
                } else {
                  _showErrorSnackbar(
                      "Could not get current location or driver ID to cancel.");
                }
              },
              child: const Text('Yes, Cancel',
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, FlutterFlowTheme theme) {
    return BlocConsumer<CurrentDeliveriesBloc, CurrentDeliveriesState>(
      listener: (context, state) {
        if (mounted) {
          setState(() {
            _isLoading = state is CurrentDeliveriesLoading ||
                state is CurrentDeliveriesLoadingNextPage ||
                state is DeliveryActionLoading;
          });
        }
        if (state is CurrentDeliveriesLoadFailure) {
          _showErrorSnackbar(
              'Failed to load deliveries: ${state.failure.message}');
        } else if (state is CurrentDeliveriesNextPageError) {
          _showErrorSnackbar(
              'Failed to load more deliveries: ${state.failure.message}');
        } else if (state is DeliveryActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message), backgroundColor: Colors.green),
          );
          if (_driverId != null) {
            _currentDeliveriesBloc.add(
                LoadCurrentDeliveries(driverId: _driverId!, isRefresh: true));
          }
        } else if (state is DeliveryActionFailure) {
          _showErrorSnackbar(
              'Action failed for delivery ID ${state.deliveryId}: ${state.failure.message}');
        }
      },
      builder: (context, state) {
        if (state.runtimeType == CurrentDeliveriesLoading &&
            !(state is CurrentDeliveriesLoadingNextPage) &&
            !(state is DeliveryActionLoading)) {
          final blocState = context.read<CurrentDeliveriesBloc>().state;
          if (blocState is CurrentDeliveriesLoadSuccess &&
              blocState.deliveries.isNotEmpty) {
          } else {
            return _buildLoadingIndicator(theme);
          }
        }

        if (state is CurrentDeliveriesLoadFailure) {
          final blocState = context.read<CurrentDeliveriesBloc>().state;
          bool hasExistingData = false;
          if (blocState is CurrentDeliveriesLoadSuccess) {
            hasExistingData = blocState.deliveries.isNotEmpty;
          }

          if (!hasExistingData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Error: ${state.failure.message}',
                        textAlign: TextAlign.center),
                  ),
                  ElevatedButton(
                    onPressed: () => _fetchInitialData(isRefresh: true),
                    child: const Text('Retry'),
                  )
                ],
              ),
            );
          }
        }

        List<Delivery> deliveries = [];
        bool hasReachedMax = true;
        bool isLoadingMore = false;

        if (state is CurrentDeliveriesLoadSuccess) {
          deliveries = state.deliveries;
          hasReachedMax = state.hasReachedMax;
        } else if (state is CurrentDeliveriesLoadingNextPage) {
          deliveries = state.deliveries;
          hasReachedMax = state.hasReachedMax;
          isLoadingMore = true;
        } else if (state is CurrentDeliveriesNextPageError) {
          deliveries = state.deliveries;
          hasReachedMax = state.hasReachedMax;
        } else if (state is DeliveryActionLoading ||
            state is DeliveryActionSuccess ||
            state is DeliveryActionFailure) {
          final currentStateFromBloc =
              context.read<CurrentDeliveriesBloc>().state;
          if (currentStateFromBloc is CurrentDeliveriesLoadSuccess) {
            deliveries = currentStateFromBloc.deliveries;
            hasReachedMax = currentStateFromBloc.hasReachedMax;
          } else if (currentStateFromBloc is CurrentDeliveriesLoadingNextPage) {
            deliveries = currentStateFromBloc.deliveries;
            hasReachedMax = currentStateFromBloc.hasReachedMax;
            isLoadingMore = true;
          }
        }

        if (deliveries.isEmpty &&
            !isLoadingMore &&
            !(state is CurrentDeliveriesLoading &&
                state.runtimeType == CurrentDeliveriesLoading) &&
            !(state is DeliveryActionLoading)) {
          return _buildEmptyState(theme);
        }

        if (deliveries.isEmpty && _isLoading) {
          return _buildLoadingIndicator(theme);
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
          itemCount: hasReachedMax ? deliveries.length : deliveries.length + 1,
          itemBuilder: (context, index) {
            if (index >= deliveries.length) {
              if (isLoadingMore) {
                return const Center(
                    child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator()));
              } else if (state is CurrentDeliveriesNextPageError) {
                return Center(
                    child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                                'Error loading more: ${state.failure.message}'),
                            ElevatedButton(
                                onPressed: () {
                                  if (_driverId != null) {
                                    _currentDeliveriesBloc.add(
                                        LoadMoreCurrentDeliveries(
                                            driverId: _driverId!));
                                  }
                                },
                                child: const Text("Retry"))
                          ],
                        )));
              }
              return const SizedBox.shrink();
            }
            return _buildDeliveryCard(deliveries[index], theme);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return GestureDetector(
      onTap: () => unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.primaryBackground,
        appBar: _buildAppBar(context, theme),
        body: SafeArea(
          top: true,
          child: _buildBody(context, theme),
        ),
      ),
    );
  }

  void _callClient(String phone) async {
    if (phone.isEmpty) return;
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showErrorSnackbar('Could not launch call to $phone');
      }
    } catch (e) {
      _showErrorSnackbar('Could not launch call: $e');
    }
  }

  Widget _buildDeliveryCard(Delivery delivery, FlutterFlowTheme theme) {
    bool isRide = delivery.deliveryType == 'RIDE';

    return FutureBuilder<double>(
      future: _currentPosition != null
          ? _geolocationService.calculateDistance(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              delivery.pickupLatitude,
              delivery.pickupLongitude)
          : Future.value(0.0),
      builder: (context, snapshot) {
        String distanceToPickupKm = snapshot.hasData
            ? (snapshot.data! / 1000).toStringAsFixed(1)
            : "...";

        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          elevation: 2,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          color: theme.secondaryBackground,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardHeader(delivery, theme),
                const SizedBox(height: 12),
                _buildCardInfoRow(delivery, distanceToPickupKm, theme),
                if (delivery.deliveryInstructions != null &&
                    delivery.deliveryInstructions!.isNotEmpty)
                  _buildSpecialInstructions(delivery, theme),
                Divider(height: 24, thickness: 1, color: theme.alternate),
                _buildLocationSection(delivery, theme),
                _buildClientInfo(delivery, theme, isRide: isRide),
                if (!isRide) const SizedBox(height: 16),
                if (!isRide) _buildParcelInfo(delivery, theme),
                const SizedBox(height: 16),
                _buildActionButtons(delivery, theme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardHeader(Delivery delivery, FlutterFlowTheme theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            "Order ID: ${delivery.deliverId}",
            style: theme.titleMedium.override(
                fontFamily: theme.titleMediumFamily,
                fontWeight: FontWeight.w600,
                color: theme.primaryText),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: _getStatusColor(delivery.deliveryStatus, theme)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(30)),
          child: Text(
            _getStatusText(delivery.deliveryStatus),
            style: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: _getStatusColor(delivery.deliveryStatus, theme)),
          ),
        ),
      ],
    );
  }

  Widget _buildCardInfoRow(
      Delivery delivery, String distanceToPickupKm, FlutterFlowTheme theme) {
    bool isRide = delivery.deliveryType == 'RIDE';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow(Icons.local_offer_outlined,
                  '\$${delivery.priceAmount.toStringAsFixed(2)}', theme,
                  title: "Price: "),
              const SizedBox(height: 4),
              if (delivery.deliveryStatus == DeliveryStatus.ASSIGNED)
                _infoRow(Icons.social_distance_sharp, '$distanceToPickupKm km',
                    theme,
                    title: "To Pickup: "),
              if (isRide) const SizedBox(height: 4),
              if (isRide)
                _infoRow(Icons.airline_seat_recline_normal,
                    '${delivery.numberOfSeats} Seats', theme,
                    title: "Seats: "),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _getVehicleIcon(delivery.vehicleType, theme),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: theme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                delivery.deliveryType,
                style: theme.bodySmall.copyWith(
                    color: theme.primary, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String text, FlutterFlowTheme theme,
      {String title = ""}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.secondaryText),
        const SizedBox(width: 4),
        Text(title,
            style: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                fontWeight: FontWeight.w600)),
        Expanded(
            child: Text(text,
                style: theme.bodyMedium, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildSpecialInstructions(Delivery delivery, FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: theme.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.warning.withOpacity(0.3))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 20, color: theme.warning),
            const SizedBox(width: 8),
            Expanded(
                child: Text(delivery.deliveryInstructions!,
                    style: theme.bodyMedium.override(
                        fontFamily: theme.bodyMediumFamily,
                        fontStyle: FontStyle.italic))),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(Delivery delivery, FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                  child: const Icon(Icons.location_on,
                      color: Colors.white, size: 16)),
              Container(
                  width: 1.5,
                  height: 60,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: Colors.grey.shade400),
              Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                      color: Colors.blue, shape: BoxShape.circle),
                  child: const Icon(Icons.flag, color: Colors.white, size: 16)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Pickup Location",
                    style: theme.titleSmall.override(
                        fontFamily: theme.titleSmallFamily,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w600)),
                Text(delivery.pickupLocation,
                    style: theme.bodyMedium.override(
                        fontFamily: theme.bodyMediumFamily,
                        color: theme.secondaryText),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 16),
                Text("Drop-Off Location",
                    style: theme.titleSmall.override(
                        fontFamily: theme.titleSmallFamily,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(delivery.dropOffLocation,
                    style: theme.bodyMedium.override(
                        fontFamily: theme.bodyMediumFamily,
                        color: theme.secondaryText),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientInfo(Delivery delivery, FlutterFlowTheme theme,
      {bool isRide = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: theme.alternate.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.alternate)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_pin_circle_outlined,
                  size: 18, color: theme.primary),
              const SizedBox(width: 8),
              Text(isRide ? "Rider Contact" : "Delivery Contact",
                  style: theme.titleSmall.override(
                      fontFamily: theme.titleSmallFamily,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: theme.primary)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
              '${delivery.customer.firstname} ${delivery.customer.lastname}'
                  .trim(),
              style: theme.bodyLarge.override(
                  fontFamily: theme.bodyLargeFamily,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryText)),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(Icons.phone_outlined, size: 16, color: theme.secondaryText),
              const SizedBox(width: 4),
              Expanded(
                  child: Text(delivery.customer.mobileNumber,
                      style: theme.bodyMedium)),
              IconButton(
                iconSize: 24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.call, color: theme.success),
                onPressed: () => _callClient(delivery.customer.mobileNumber),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParcelInfo(Delivery delivery, FlutterFlowTheme theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: theme.info.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.info.withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined,
                  size: 18, color: Colors.black),
              const SizedBox(width: 8),
              Text("Parcel Details",
                  style: theme.titleSmall.override(
                      fontFamily: theme.titleSmallFamily,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black)),
            ],
          ),
          const SizedBox(height: 5),
          Text(delivery.parcelDescription, style: theme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Delivery delivery, FlutterFlowTheme theme) {
    bool isRide = delivery.deliveryType == 'RIDE';
    bool isAssigned = delivery.deliveryStatus == DeliveryStatus.ASSIGNED;
    bool isPickedUp = delivery.deliveryStatus == DeliveryStatus.PICKED_UP;

    List<Widget> topRowButtons = [];
    Widget? mainAction;

    final chatButton = Expanded(
      child: OutlinedButton.icon(
        icon: Icon(Icons.chat_bubble_outline, size: 18, color: theme.primary),
        label: Text('CHAT',
            style: TextStyle(
                color: theme.primary,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 14)),
        style: OutlinedButton.styleFrom(
            foregroundColor: theme.primary,
            side: BorderSide(color: theme.primary),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        onPressed: () {
          context.push('/chat', extra: {
            'deliveryId': delivery.deliverId.toString(),
            'customerId': delivery.customer.clientId.toString(),
            'customerName':
                '${delivery.customer.firstname} ${delivery.customer.lastname}',
          });
        },
      ),
    );

    if (isAssigned) {
      topRowButtons.add(
        Expanded(
          child: OutlinedButton.icon(
            icon:
                Icon(Icons.directions_outlined, size: 18, color: theme.primary),
            label: Text('TO PICKUP',
                style: TextStyle(
                    color: theme.primary,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
            style: OutlinedButton.styleFrom(
                foregroundColor: theme.primary,
                side: BorderSide(color: theme.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            onPressed: () => _launchMapsUrl(
                delivery.pickupLatitude, delivery.pickupLongitude),
          ),
        ),
      );

      topRowButtons.add(const SizedBox(width: 8));
      topRowButtons.add(chatButton);

      mainAction = ElevatedButton.icon(
        icon: Icon(
            isRide ? Icons.directions_car_outlined : Icons.inventory_outlined,
            size: 18,
            color: Colors.white),
        label: Text(isRide ? 'START RIDE' : 'CONFIRM PICKUP',
            style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 14)),
        style: ElevatedButton.styleFrom(
            backgroundColor: theme.primary,
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: const Size(double.infinity, 48),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        onPressed: () => isRide
            ? _startPickupAndTracking(delivery)
            : _showPickupBottomSheet(delivery),
      );
    } else if (isPickedUp) {
      topRowButtons.add(
        Expanded(
          child: OutlinedButton.icon(
            icon:
                Icon(Icons.directions_outlined, size: 18, color: theme.primary),
            label: Text('TO DROPOFF',
                style: TextStyle(
                    color: theme.primary,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
            style: OutlinedButton.styleFrom(
                foregroundColor: theme.primary,
                side: BorderSide(color: theme.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            onPressed: () => _launchMapsUrl(
                delivery.dropOffLatitude, delivery.dropOffLongitude),
          ),
        ),
      );
      topRowButtons.add(const SizedBox(width: 8));
      topRowButtons.add(chatButton);

      mainAction = ElevatedButton.icon(
        icon: const Icon(Icons.check_circle_outline,
            size: 18, color: Colors.white),
        label: Text(isRide ? 'END RIDE' : 'CONFIRM COMPLETION',
            style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 14)),
        style: ElevatedButton.styleFrom(
            backgroundColor: theme.primary,
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: const Size(double.infinity, 48),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        onPressed: () =>
            _showCompleteDeliveryBottomSheet(delivery, isRide: isRide),
      );
    }

    bool canCancel = delivery.deliveryStatus == DeliveryStatus.ASSIGNED;

    List<Widget> allButtons = [];
    if (topRowButtons.isNotEmpty) {
      allButtons.add(Row(children: topRowButtons));
      allButtons.add(const SizedBox(height: 8));
    }
    if (mainAction != null) {
      allButtons.add(mainAction);
    }

    if (canCancel) {
      allButtons.add(const SizedBox(height: 8));
      allButtons.add(
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: Icon(Icons.cancel_outlined, size: 18, color: theme.error),
            label: Text('CANCEL DELIVERY',
                style: TextStyle(
                    color: theme.error,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
            style: OutlinedButton.styleFrom(
                foregroundColor: theme.error,
                side: BorderSide(color: theme.error),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            onPressed: () => _showCancelConfirmation(delivery),
          ),
        ),
      );
    }

    return Column(children: allButtons.isNotEmpty ? allButtons : [Container()]);
  }

  Widget _getVehicleIcon(VehicleType vehicleType, FlutterFlowTheme theme) {
    IconData iconData;
    Color iconColor;
    switch (vehicleType) {
      case VehicleType.CAR:
        iconData = Icons.directions_car;
        iconColor = Colors.blue.shade700;
        break;
      case VehicleType.BIKE:
        iconData = Icons.pedal_bike;
        iconColor = Colors.green.shade700;
        break;
      case VehicleType.TRUCK:
        iconData = Icons.local_shipping;
        iconColor = Colors.orange.shade800;
        break;
      case VehicleType.VAN:
        iconData = Icons.airport_shuttle;
        iconColor = Colors.purple.shade700;
        break;
      default:
        iconData = Icons.help_outline;
        iconColor = theme.secondaryText;
    }
    return Icon(iconData, size: 24, color: iconColor);
  }

  Color _getStatusColor(DeliveryStatus status, FlutterFlowTheme theme) {
    switch (status) {
      case DeliveryStatus.ASSIGNED:
        return theme.primary;
      case DeliveryStatus.PICKED_UP:
        return theme.warning;
      case DeliveryStatus.COMPLETED:
        return theme.success;
      case DeliveryStatus.CANCELLED:
        return theme.error;
      default:
        return theme.secondaryText;
    }
  }

  String _getStatusText(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.ASSIGNED:
        return 'Assigned';
      case DeliveryStatus.PICKED_UP:
        return 'Picked Up';
      case DeliveryStatus.COMPLETED:
        return 'Completed';
      case DeliveryStatus.CANCELLED:
        return 'Cancelled';
      case DeliveryStatus.OPEN:
        return 'Open';
      case DeliveryStatus.UNKNOWN:
      default:
        return 'Unknown';
    }
  }
}
