import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_bloc.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_state.dart';
import 'package:langas_user/bloc/deliveries/select_driver_bloc/select_driver_bloc_bloc.dart';
import 'package:langas_user/bloc/deliveries/select_driver_bloc/select_driver_bloc_event.dart';
import 'package:langas_user/bloc/deliveries/select_driver_bloc/select_driver_bloc_state.dart';
import 'package:langas_user/bloc/deliveries/single_delivery_bloc/single_delivery_bloc_bloc.dart';
import 'package:langas_user/bloc/deliveries/single_delivery_bloc/single_delivery_bloc_event.dart';
import 'package:langas_user/bloc/deliveries/single_delivery_bloc/single_delivery_bloc_state.dart';
import 'package:langas_user/bloc/drivers/active_drivers/available_drivers_bloc_bloc.dart';
import 'package:langas_user/bloc/drivers/active_drivers/available_drivers_bloc_event.dart';
import 'package:langas_user/bloc/drivers/active_drivers/available_drivers_bloc_state.dart';
import 'package:langas_user/dto/delivery_dto.dart';
import 'package:langas_user/models/driver_model.dart';
import 'package:langas_user/services/geolocation.dart';
import 'package:langas_user/util/apps_enums.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:langas_user/services/firebase_driver_service.dart';
import 'package:firebase_database/firebase_database.dart'; // Import for Firebase Database

class ActiveDriversWidget extends StatefulWidget {
  final int deliveryId;

  const ActiveDriversWidget({
    super.key,
    required this.deliveryId,
  });

  @override
  State<ActiveDriversWidget> createState() => _ActiveDriversWidgetState();
}

class _ActiveDriversWidgetState extends State<ActiveDriversWidget>
    with TickerProviderStateMixin {
  final unfocusNode = FocusNode();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String? _clientId;
  LatLng? _pickupLocation;
  bool _isLoadingDeliveryDetails = true;
  bool _isLoadingDistances = false;
  late GeolocationService _geolocationService;
  late FirebaseDriverService _firebaseDriverService;

  List<Driver> _originalDrivers = [];
  List<Driver> _displayedDrivers = [];
  Map<int, double> _driverDistances = {};

  bool _sortDistanceAscending = true;

  static const String RTDB_LIVE_TRACKING_PATH =
      "detailed_live_tracking"; // Define the RTDB path constant

  @override
  void initState() {
    super.initState();
    _geolocationService = context.read<GeolocationService>();
    print("========> get firebase to work");
    _firebaseDriverService = context.read<FirebaseDriverService>();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _clientId = authState.user.userId.toString();
      _fetchDeliveryDetails();
    } else {
      print("Error: User not authenticated in ActiveDriversWidget");
      _showToast("User not authenticated. Please login again.", success: false);
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
    print("========> get firebase to work");
  }

  void _fetchDeliveryDetails() {
    if (_clientId != null) {
      setState(() {
        _isLoadingDeliveryDetails = true;
      });
      context.read<SingleDeliveryBloc>().add(FetchSingleDeliveryRequested(
          clientId: _clientId!, deliveryId: widget.deliveryId));

      // Start Firebase listening with the desired status filter
      // You can define the status string you want to filter by here or as a class member
      const String desiredStatus = "OPEN"; // <-- Define the status here
      _firebaseDriverService.startListeningForProposals(widget.deliveryId,
          statusFilter: desiredStatus);
    } else if (_pickupLocation == null) {
      // Keep this check or adjust logic if pickup location is not strictly required to start Firebase listener
      print("Error: Pickup location not available to fetch drivers.");
      if (mounted) {
        setState(() {
          _isLoadingDeliveryDetails = false; // Ensure loading state is updated
        });
      }
    } else {
      // Add an else block for clarity if _clientId is null
      print(
          "Error: Client ID is null. Cannot fetch delivery details or start Firebase listener.");
      if (mounted) {
        setState(() {
          _isLoadingDeliveryDetails = false; // Ensure loading state is updated
        });
      }
    }
  }

  void _fetchDrivers() {
    if (_clientId != null && _pickupLocation != null) {
      context
          .read<AvailableDriversBloc>()
          .add(FetchAvailableDrivers(deliveryId: widget.deliveryId.toString()));
    } else if (_pickupLocation == null) {
      print("Error: Pickup location not available to fetch drivers.");
      if (mounted) {
        setState(() {
          _isLoadingDeliveryDetails = false;
        });
      }
    }
  }

  Future<void> _calculateAllDistances(List<Driver> drivers) async {
    if (_pickupLocation == null || !mounted) return;
    setState(() {
      _isLoadingDistances = true;
    });

    Map<int, double> distances = {};
    for (var driver in drivers) {
      if (driver.latitude != null && driver.longitude != null) {
        try {
          final dist = await _geolocationService.calculateDistance(
              _pickupLocation!.latitude,
              _pickupLocation!.longitude,
              driver.latitude!,
              driver.longitude!);
          distances[driver.driverId] = dist / 1000.0;
        } catch (e) {
          print("Error calculating distance for driver ${driver.driverId}: $e");
          distances[driver.driverId] = double.infinity;
        }
      } else {
        distances[driver.driverId] = double.infinity;
      }
    }
    if (!mounted) return;
    setState(() {
      _driverDistances = distances;
      _isLoadingDistances = false;
      _applySort();
    });
  }

  void _applySort() {
    List<Driver> sortedList = List.from(_originalDrivers);

    sortedList.sort((a, b) {
      int comparisonResult = (_driverDistances[a.driverId] ?? double.infinity)
          .compareTo(_driverDistances[b.driverId] ?? double.infinity);
      return _sortDistanceAscending ? comparisonResult : -comparisonResult;
    });

    if (!mounted) return;
    setState(() {
      _displayedDrivers = sortedList;
    });
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarBrightness: Theme.of(context).brightness,
          systemStatusBarContrastEnforced: true,
        ),
      );
    }

    return GestureDetector(
      onTap: () => unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: _buildAppBar(),
        body: SafeArea(
          top: true,
          child: MultiBlocListener(
            listeners: [
              BlocListener<SelectDriverBloc, SelectDriverState>(
                listener: (context, state) {
                  if (state is SelectDriverSuccess) {
                    _showToast(state.message, success: true);
                    if (mounted && Navigator.canPop(context)) {
                      Navigator.pop(context, true);
                    }
                  } else if (state is SelectDriverFailure) {
                    _showToast(
                        "Failed to select driver: ${state.failure.message}",
                        success: false);
                  }
                },
              ),
              BlocListener<SingleDeliveryBloc, SingleDeliveryState>(
                listener: (context, state) {
                  if (state is SingleDeliverySuccess) {
                    if (!mounted) return;
                    setState(() {
                      _pickupLocation = LatLng(state.delivery.pickupLatitude,
                          state.delivery.pickupLongitude);
                      _isLoadingDeliveryDetails = false;
                    });
                    _fetchDrivers();
                  } else if (state is SingleDeliveryFailure) {
                    if (!mounted) return;
                    setState(() {
                      _isLoadingDeliveryDetails = false;
                    });
                    _showToast(
                        "Error fetching delivery details: ${state.failure.message}",
                        success: false);
                  }
                },
              ),
            ],
            child: _isLoadingDeliveryDetails
                ? _buildLoadingIndicator(message: "Loading delivery details...")
                : Column(
                    children: [
                      _buildSortControls(),
                      Expanded(
                        child: BlocConsumer<AvailableDriversBloc,
                            AvailableDriversState>(listener: (context, state) {
                          if (state is AvailableDriversSuccess) {
                            _originalDrivers = List.from(state.drivers);
                            _calculateAllDistances(state.drivers);
                          }
                        }, builder: (context, state) {
                          if (state is AvailableDriversLoading ||
                              (_isLoadingDeliveryDetails &&
                                  _pickupLocation == null) ||
                              _isLoadingDistances) {
                            return _buildLoadingIndicator(
                                message: _isLoadingDeliveryDetails
                                    ? "Fetching pickup location..."
                                    : _isLoadingDistances
                                        ? "Calculating distances..."
                                        : "Finding available drivers...");
                          } else if (state is AvailableDriversSuccess) {
                            if (_pickupLocation == null &&
                                !_isLoadingDeliveryDetails) {
                              return _buildErrorState(
                                  "Pickup location not available.");
                            }
                            return _displayedDrivers.isEmpty &&
                                    !_isLoadingDistances
                                ? _buildEmptyState()
                                : _buildDriversList(_displayedDrivers);
                          } else if (state is AvailableDriversFailure) {
                            return _buildErrorState(state.failure.message);
                          } else {
                            return _buildLoadingIndicator(
                                message: "Initializing...");
                          }
                        }),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            icon: Icon(
              _sortDistanceAscending
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              color: FlutterFlowTheme.of(context).primary,
              size: 20,
            ),
            label: Text(
              "Sort by Distance",
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                    color: FlutterFlowTheme.of(context).primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            onPressed: (_originalDrivers.isEmpty || _isLoadingDistances)
                ? null
                : () {
                    setState(() {
                      _sortDistanceAscending = !_sortDistanceAscending;
                      _applySort();
                    });
                  },
            style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                        color: FlutterFlowTheme.of(context)
                            .primary
                            .withOpacity(0.5)))),
          ),
        ],
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
        buttonSize: 60.0,
        icon: Icon(
          Icons.arrow_back_rounded,
          color: FlutterFlowTheme.of(context).info,
          size: 24.0,
        ),
        onPressed: () async {
          if (mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
      ),
      title: Text(
        "AVAILABLE DRIVERS",
        style: FlutterFlowTheme.of(context).headlineMedium.override(
              fontFamily: FlutterFlowTheme.of(context).headlineMediumFamily,
              color: FlutterFlowTheme.of(context).info,
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
            icon: Icon(
              Icons.refresh_rounded,
              color: FlutterFlowTheme.of(context).info,
              size: 24.0,
            ),
            onPressed: () {
              if (!_isLoadingDeliveryDetails && _pickupLocation != null) {
                _fetchDrivers();
              } else if (_isLoadingDeliveryDetails) {
                _fetchDeliveryDetails();
              } else {
                _showToast("Still loading delivery information.",
                    success: false);
              }
            }),
      ],
      centerTitle: true,
      elevation: 0,
    );
  }

  List<Driver> _filterDrivers(List<Driver> allDrivers) {
    return allDrivers.where((driver) {
      return true;
    }).toList();
  }

  Widget _buildLoadingIndicator({String message = "Loading..."}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitSpinningLines(
            color: FlutterFlowTheme.of(context).primary,
            size: 50.0,
            lineWidth: 2,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              message,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade300, size: 60),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error: $message',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            onPressed: _isLoadingDeliveryDetails
                ? _fetchDeliveryDetails
                : _fetchDrivers,
            style: ElevatedButton.styleFrom(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              foregroundColor: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDriversList(List<Driver> drivers) {
    return RefreshIndicator(
      onRefresh: () async => _fetchDrivers(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
        child: ListView.builder(
            padding: EdgeInsets.zero,
            scrollDirection: Axis.vertical,
            itemCount: drivers.length,
            itemBuilder: (context, index) {
              return _buildDriverCard(drivers[index]);
            }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search,
            color: FlutterFlowTheme.of(context).secondaryText.withOpacity(0.6),
            size: 80,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              'No Drivers Found',
              style: FlutterFlowTheme.of(context).titleLarge.override(
                    fontFamily: FlutterFlowTheme.of(context).titleLargeFamily,
                    color: FlutterFlowTheme.of(context).primaryText,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Text(
            'No drivers match your criteria currently.',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: Icon(Icons.refresh, color: FlutterFlowTheme.of(context).info),
            label: Text('Refresh',
                style: TextStyle(color: FlutterFlowTheme.of(context).info)),
            style: ElevatedButton.styleFrom(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _fetchDrivers,
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(Driver driver) {
    String distanceText = "N/A";
    if (_driverDistances.containsKey(driver.driverId) &&
        _driverDistances[driver.driverId] != double.infinity) {
      distanceText =
          "${_driverDistances[driver.driverId]!.toStringAsFixed(1)} km away";
    } else if (_driverDistances.containsKey(driver.driverId) &&
        _driverDistances[driver.driverId] == double.infinity) {
      distanceText = "Location N/A";
    } else if (_isLoadingDistances) {
      distanceText = "Calculating...";
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        color: FlutterFlowTheme.of(context).secondaryBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 70.0,
                        height: 70.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(35.0),
                          boxShadow: [
                            BoxShadow(
                              color: FlutterFlowTheme.of(context)
                                  .primaryText
                                  .withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(35.0),
                          child: (driver.profilePhotoUrl != null &&
                                  driver.profilePhotoUrl!.isNotEmpty)
                              ? Image.network(
                                  driver.profilePhotoUrl!,
                                  width: 70.0,
                                  height: 70.0,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildPlaceholderAvatar(context),
                                )
                              : _buildPlaceholderAvatar(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${driver.firstname ?? ''} ${driver.lastname ?? ''}'
                              .trim(),
                          style: FlutterFlowTheme.of(context)
                              .titleMedium
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .titleMediumFamily,
                                fontWeight: FontWeight.w600,
                                color: FlutterFlowTheme.of(context).primaryText,
                                fontSize: 16.0,
                              ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          distanceText,
                          style: FlutterFlowTheme.of(context)
                              .bodySmall
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .bodySmallFamily,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        if (driver.rating != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              children: [
                                Icon(Icons.star,
                                    size: 14,
                                    color:
                                        FlutterFlowTheme.of(context).warning),
                                const SizedBox(width: 2),
                                Text(
                                  driver.rating!.toStringAsFixed(1),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .bodyMediumFamily,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (driver.activeVehicle != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        FlutterFlowTheme.of(context).alternate.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: FlutterFlowTheme.of(context).alternate),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Icon(
                                _getVehicleIcon(
                                    driver.activeVehicle!.vehicleType),
                                color:
                                    FlutterFlowTheme.of(context).secondaryText),
                            const SizedBox(height: 4),
                            Text(
                              "${driver.activeVehicle!.vehicleMake ?? ''} ${driver.activeVehicle!.vehicleModel ?? ''} (${driver.activeVehicle!.vehicleType.name})\n${driver.activeVehicle!.licensePlateNo ?? 'N/A'}"
                                  .trim(),
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodySmallFamily,
                                      fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                      Container(
                          height: 40,
                          width: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: FlutterFlowTheme.of(context).alternate),
                      Expanded(
                        child: Column(
                          children: [
                            Icon(Icons.archive,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText),
                            const SizedBox(height: 4),
                            Text(
                              '${driver.totalDeliveries ?? 0} Deliveries',
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodySmallFamily,
                                      fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _selectDriver(driver),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  foregroundColor: FlutterFlowTheme.of(context).info,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: BlocBuilder<SelectDriverBloc, SelectDriverState>(
                    builder: (context, state) {
                  bool isLoadingThisDriver = state is SelectDriverLoading &&
                      state.props.isNotEmpty &&
                      (state.props[0] is SelectDriverRequestDto) &&
                      (state.props[0] as SelectDriverRequestDto).driverId ==
                          driver.driverId;

                  return isLoadingThisDriver
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(
                          'SELECT DRIVER',
                          style: FlutterFlowTheme.of(context)
                              .labelLarge
                              .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .labelLargeFamily,
                                  color: FlutterFlowTheme.of(context).info,
                                  fontWeight: FontWeight.bold),
                        );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderAvatar(BuildContext context) {
    return Container(
      width: 70.0,
      height: 70.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).alternate,
        borderRadius: BorderRadius.circular(35.0),
      ),
      child: Icon(
        Icons.person,
        size: 35,
        color: FlutterFlowTheme.of(context).secondaryText,
      ),
    );
  }

  IconData _getVehicleIcon(VehicleType vehicleType) {
    switch (vehicleType) {
      case VehicleType.CAR:
        return Icons.directions_car_outlined;
      case VehicleType.BIKE:
        return Icons.directions_bike_outlined;
      case VehicleType.TRUCK:
        return Icons.local_shipping_outlined;
      default:
        return Icons.directions_car_outlined;
    }
  }

  void _selectDriver(Driver driver) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Confirm Driver Selection',
              style: FlutterFlowTheme.of(context).titleMedium),
          content: Text(
              'Assign delivery #${widget.deliveryId} to ${driver.firstname ?? 'this driver'}?',
              style: FlutterFlowTheme.of(context).bodyMedium),
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel',
                  style: TextStyle(
                      color: FlutterFlowTheme.of(context).secondaryText)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _confirmDriverSelection(driver);
              },
              child: Text('Confirm',
                  style: TextStyle(
                      color: FlutterFlowTheme.of(context).primary,
                      fontWeight: FontWeight.bold)),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        );
      },
    );
  }

  void _confirmDriverSelection(Driver driver) {
    if (_clientId == null) {
      _showToast("Error: Client ID not found.", success: false);
      return;
    }
    final selectDto = SelectDriverRequestDto(
        deliveryId: widget.deliveryId, driverId: driver.driverId);

    context.read<SelectDriverBloc>().add(
        SelectDriverSubmitted(clientId: _clientId!, requestDto: selectDto));
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
}
