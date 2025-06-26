import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:langas_driver/bloc/auth/auth_bloc/auth_bloc_bloc.dart';
import 'package:langas_driver/bloc/auth/auth_bloc/auth_bloc_state.dart';
import 'package:langas_driver/bloc/delivery/confirm_delivery_bloc/confirm_delivery_bloc_bloc.dart';
import 'package:langas_driver/bloc/delivery/confirm_delivery_bloc/confirm_delivery_bloc_event.dart';
import 'package:langas_driver/bloc/delivery/confirm_delivery_bloc/confirm_delivery_bloc_state.dart';
import 'package:langas_driver/bloc/delivery/nearby_deliveries_bloc/nearby_deliveries_bloc_bloc.dart';
import 'package:langas_driver/bloc/delivery/nearby_deliveries_bloc/nearby_deliveries_bloc_event.dart';
import 'package:langas_driver/bloc/delivery/nearby_deliveries_bloc/nearby_deliveries_bloc_state.dart';
import 'package:langas_driver/bloc/driver_profile/driver_profile_bloc_bloc.dart';
import 'package:langas_driver/bloc/driver_profile/driver_profile_bloc_event.dart';
import 'package:langas_driver/bloc/driver_profile/driver_profile_bloc_state.dart';
import 'package:langas_driver/bloc/vehicles/vehicle_management/vehicle_management_bloc_bloc.dart';
import 'package:langas_driver/bloc/vehicles/vehicle_management/vehicle_management_bloc_state.dart';
import 'package:langas_driver/dto/delivery_dto.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_driver/models/auth_models.dart';
import 'package:langas_driver/models/firebase_delivery_model.dart';
import 'package:langas_driver/nav/nav.dart';
import 'package:langas_driver/services/geolocation.dart';
import 'package:langas_driver/utils/delivery_enums.dart';

class NearbyDeliveriesWidget extends StatefulWidget {
  const NearbyDeliveriesWidget({super.key});

  @override
  State<NearbyDeliveriesWidget> createState() => _NearbyDeliveriesWidgetState();
}

class _NearbyDeliveriesWidgetState extends State<NearbyDeliveriesWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String? _driverId;
  VehicleType? _activeVehicleType;
  Position? _currentPosition;
  bool _isDriverBusy = false;

  late GeolocationService _geolocationService;
  late NearbyDeliveriesBloc _nearbyDeliveriesBloc;
  late AuthBloc _authBloc;
  late VehicleManagementBloc _vehicleManagementBloc;
  late DriverProfileBloc _driverProfileBloc;

  @override
  void initState() {
    super.initState();
    _geolocationService = context.read<GeolocationService>();
    _nearbyDeliveriesBloc = context.read<NearbyDeliveriesBloc>();
    _authBloc = context.read<AuthBloc>();
    _vehicleManagementBloc = context.read<VehicleManagementBloc>();
    _driverProfileBloc = context.read<DriverProfileBloc>();
    _scrollController.addListener(_onScroll);
    _fetchInitialData();
  }

  Future<void> _fetchInitialData({bool isRefresh = false}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    _currentPosition = await _geolocationService.getCurrentLocation();
    if (!mounted) {
      setState(() => _isLoading = false);
      return;
    }

    final authState = _authBloc.state;
    if (authState is AuthDriverAuthenticated) {
      _driverId = authState.authData.driverProfile?.id.toString();

      if (_driverId != null) {
        _driverProfileBloc.add(LoadDriverProfile(driverId: _driverId!));
      }

      if (authState.authData.driverProfile?.activeVehicle != null) {
        _activeVehicleType =
            authState.authData.driverProfile!.activeVehicle!.vehicleType;
      } else {
        final vehicleState = _vehicleManagementBloc.state;
        if (vehicleState is VehicleListLoadSuccess &&
            vehicleState.vehicles.isNotEmpty) {
          if (vehicleState.activeVehicleId != null) {
            try {
              final activeVehicleFromList = vehicleState.vehicles.firstWhere(
                  (v) => v.vehicleId == vehicleState.activeVehicleId);
              _activeVehicleType = activeVehicleFromList.vehicleType;
            } catch (e) {
              _activeVehicleType = vehicleState.vehicles.first.vehicleType;
            }
          } else {
            _activeVehicleType = vehicleState.vehicles.first.vehicleType;
          }
        }
      }

      if (_driverId != null && _driverId!.isNotEmpty) {
        if (_activeVehicleType != null) {
          _nearbyDeliveriesBloc.add(LoadNearbyDeliveries(
              driverId: _driverId!,
              vehicleType: _activeVehicleType!,
              isRefresh: isRefresh));
        } else {
          _showError(
              'Active vehicle type not set. Please select an active vehicle from settings.');
          if (mounted) setState(() => _isLoading = false);
        }
      } else {
        _showError('Driver ID not available.');
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      _showError('User not authenticated.');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onScroll() {}

  void _refreshDeliveries() {
    _fetchInitialData(isRefresh: true);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: theme.primary,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: Colors.white, size: 24.0),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'NEARBY DELIVERIES',
          style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Colors.white, size: 24.0),
            onPressed: _refreshDeliveries,
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ConfirmDeliveryBloc, ConfirmDeliveryState>(
            listener: (context, state) {
              if (state is ConfirmDeliveryInProgress) {
                setState(() => _isLoading = true);
              } else {
                if (_isLoading) setState(() => _isLoading = false);
              }
              if (state is ConfirmDeliverySuccess) {
                if (_driverId != null) {
                  _driverProfileBloc
                      .add(LoadDriverProfile(driverId: _driverId!));
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
                context.go('/currentDeliveries');
              }
              if (state is ConfirmDeliveryFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.failure.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          BlocListener<DriverProfileBloc, DriverProfileState>(
            listener: (context, state) {
              if (state is DriverProfileLoadSuccess) {
                if (mounted) {
                  setState(() {
                    _isDriverBusy = state.driverProfile.isBusy;
                  });
                }
              }
            },
          ),
          BlocListener<NearbyDeliveriesBloc, NearbyDeliveriesState>(
            listener: (context, state) {
              if (mounted) {
                setState(() {
                  _isLoading = state is NearbyDeliveriesLoading ||
                      state is NearbyDeliveriesLoadingNextPage;
                });
              }
              if (state is NearbyDeliveriesLoadFailure) {
                _showError(
                    'Failed to load deliveries: ${state.failure.message}');
              } else if (state is NearbyDeliveriesNextPageError) {
                _showError(
                    'Failed to load more deliveries: ${state.failure.message}');
              }
            },
          ),
          BlocListener<VehicleManagementBloc, VehicleManagementState>(
              listener: (context, state) {
            if (state is VehicleListLoadSuccess) {
              bool foundActive = false;
              if (state.activeVehicleId != null) {
                try {
                  final activeVehicle = state.vehicles
                      .firstWhere((v) => v.vehicleId == state.activeVehicleId);
                  _activeVehicleType = activeVehicle.vehicleType;
                  foundActive = true;
                } catch (e) {}
              }
              if (!foundActive && state.vehicles.isNotEmpty) {
                _activeVehicleType = state.vehicles.first.vehicleType;
              }

              if (_driverId != null &&
                  _activeVehicleType != null &&
                  (_nearbyDeliveriesBloc.state is NearbyDeliveriesInitial ||
                      _nearbyDeliveriesBloc.state
                          is NearbyDeliveriesLoadFailure)) {
                _nearbyDeliveriesBloc.add(LoadNearbyDeliveries(
                    driverId: _driverId!,
                    vehicleType: _activeVehicleType!,
                    isRefresh: true));
              } else if (_activeVehicleType == null && _driverId != null) {
                _showError(
                    "Please set an active vehicle to see nearby deliveries.");
                if (mounted) setState(() => _isLoading = false);
              }
            } else if (state is VehicleSwitchSuccess) {
              final vehicleState = _vehicleManagementBloc.state;
              if (vehicleState is VehicleListLoadSuccess &&
                  vehicleState.activeVehicleId != null) {
                try {
                  final activeVehicle = vehicleState.vehicles.firstWhere(
                      (v) => v.vehicleId == vehicleState.activeVehicleId);
                  _activeVehicleType = activeVehicle.vehicleType;
                  if (_driverId != null) {
                    _nearbyDeliveriesBloc.add(LoadNearbyDeliveries(
                        driverId: _driverId!,
                        vehicleType: _activeVehicleType!,
                        isRefresh: true));
                  }
                } catch (e) {}
              }
            }
          }),
        ],
        child: SafeArea(
          child: BlocBuilder<NearbyDeliveriesBloc, NearbyDeliveriesState>(
              builder: (context, state) {
            if (state is NearbyDeliveriesLoading &&
                state is! NearbyDeliveriesLoadingNextPage) {
              return Center(
                  child: SpinKitSpinningLines(
                      color: theme.primary, size: 50.0, lineWidth: 2));
            }
            if (state is NearbyDeliveriesLoadFailure) {
              return Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.failure.message}'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                      onPressed: _refreshDeliveries, child: const Text('Retry'))
                ],
              ));
            }
            if (state is NearbyDeliveriesLoadSuccess) {
              if (state.deliveries.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off,
                          size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text('No nearby deliveries found',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700])),
                      const SizedBox(height: 8),
                      Text(
                        _activeVehicleType == null
                            ? 'Please select an active vehicle.'
                            : 'Check back later or try a different vehicle type.',
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                itemCount:
                    state.deliveries.length + (state.hasReachedMax ? 0 : 1),
                itemBuilder: (context, index) {
                  if (index >= state.deliveries.length) {
                    if (state is NearbyDeliveriesLoadingNextPage) {
                      return const Center(
                          child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator()));
                    } else if (state is NearbyDeliveriesNextPageError) {
                      return Center(
                          child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                  'Error loading more: ${state.failure.message}')));
                    } else {
                      if (!state.hasReachedMax &&
                          _driverId != null &&
                          _activeVehicleType != null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted &&
                              state is! NearbyDeliveriesLoadingNextPage) {
                            _nearbyDeliveriesBloc.add(LoadMoreNearbyDeliveries(
                                driverId: _driverId!,
                                vehicleType: _activeVehicleType!));
                          }
                        });
                      }
                      return const SizedBox.shrink();
                    }
                  }
                  return _buildDeliveryCard(
                      state.deliveries[index], theme, _isDriverBusy);
                },
              );
            }
            return Center(
                child: Text(_activeVehicleType == null
                    ? 'Please set an active vehicle to view nearby deliveries.'
                    : 'Loading deliveries...'));
          }),
        ),
      ),
    );
  }

  Widget _buildDeliveryCard(
      FirebaseDelivery delivery, FlutterFlowTheme theme, bool isDriverBusy) {
    return FutureBuilder<List<double>>(
      future: Future.wait([
        _currentPosition != null
            ? _geolocationService.calculateDistance(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
                delivery.pickupLatitude,
                delivery.pickupLongitude)
            : Future.value(0.0),
        _geolocationService.calculateDistance(
            delivery.pickupLatitude,
            delivery.pickupLongitude,
            delivery.dropOffLatitude,
            delivery.dropOffLongitude),
      ]),
      builder: (context, snapshot) {
        String distanceToPickupKm = "...";
        String totalDeliveryDistanceKm = "...";

        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          distanceToPickupKm = (snapshot.data![0] / 1000).toStringAsFixed(1);
          totalDeliveryDistanceKm =
              (snapshot.data![1] / 1000).toStringAsFixed(1);
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          elevation: 3,
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildUserProfileSection(delivery, theme, distanceToPickupKm),
              const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLocationSection(delivery, theme),
                    _buildDetailsSection(
                        delivery, totalDeliveryDistanceKm, theme),
                    const SizedBox(height: 16),
                    _buildActionButtons(delivery, theme, isDriverBusy),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailsSection(FirebaseDelivery delivery,
      String totalDeliveryDistanceKm, FlutterFlowTheme theme) {
    bool isRide = delivery.deliveryType == 'RIDE';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEEF3FF)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildDetailItem(
              theme,
              "Earnings",
              '\$${delivery.priceAmount.toStringAsFixed(2)}',
              Icons.attach_money),
          if (isRide)
            _buildDetailItem(theme, "Seats", delivery.numberOfSeats.toString(),
                Icons.airline_seat_recline_normal_outlined)
          else
            _buildDetailItem(theme, "Vehicle", delivery.vehicleType.name,
                _getVehicleIconData(delivery.vehicleType),
                capitalize: true),
          _buildDetailItem(theme, "Distance", '$totalDeliveryDistanceKm km',
              Icons.map_outlined),
          _buildDetailItem(
              theme, "Payment", delivery.paymentMethod.name, Icons.credit_card,
              capitalize: true),
        ],
      ),
    );
  }

  IconData _getVehicleIconData(VehicleType vehicleType) {
    switch (vehicleType) {
      case VehicleType.CAR:
        return Icons.directions_car;
      case VehicleType.BIKE:
        return Icons.pedal_bike;
      case VehicleType.TRUCK:
        return Icons.local_shipping;
      case VehicleType.VAN:
        return Icons.airport_shuttle;
      default:
        return Icons.directions_car;
    }
  }

  Widget _buildDetailItem(
      FlutterFlowTheme theme, String label, String value, IconData icon,
      {bool capitalize = false}) {
    String displayValue = capitalize
        ? value.characters.first.toUpperCase() +
            value.substring(1).toLowerCase()
        : value;

    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: theme.primary, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.bodySmall
                .override(fontFamily: 'Poppins', color: Colors.grey[700]),
          ),
          Text(
            displayValue,
            style: theme.bodyMedium
                .override(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  Widget _buildUserProfileSection(FirebaseDelivery delivery,
      FlutterFlowTheme theme, String distanceToPickupKm) {
    bool isRide = delivery.deliveryType == 'RIDE';
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Color(0xFFEEF3FF),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.0), topRight: Radius.circular(12.0)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              isRide ? Icons.person_outline : Icons.inventory_2_outlined,
              color: Colors.grey[600],
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${delivery.client?.firstname} ${delivery.client?.lastname}'
                      .trim(),
                  style: theme.bodyLarge.override(
                      fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentPosition == null && distanceToPickupKm == "..."
                      ? 'Calculating distance...'
                      : '$distanceToPickupKm km away',
                  style: theme.bodyMedium
                      .override(fontFamily: 'Poppins', color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: theme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.0)),
            child: Text(
              delivery.deliveryType,
              style: theme.bodySmall.override(
                  fontFamily: 'Poppins',
                  color: theme.primary,
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLocationSection(
      FirebaseDelivery delivery, FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                  child: const Icon(Icons.location_on,
                      color: Colors.white, size: 16)),
              Container(
                  width: 2,
                  height: 40,
                  color: Colors.grey.shade300,
                  margin: const EdgeInsets.symmetric(vertical: 4)),
              Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                      color: Colors.blue, shape: BoxShape.circle),
                  child: const Icon(Icons.flag, color: Colors.white, size: 16)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pickup Location',
                    style: theme.bodyMedium.override(
                        fontFamily: 'Poppins',
                        color: Colors.red,
                        fontWeight: FontWeight.w500)),
                Text(delivery.pickupLocation,
                    style: theme.bodySmall.override(
                        fontFamily: 'Poppins', color: Colors.grey[800]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 16),
                Text('Drop-off Location',
                    style: theme.bodyMedium.override(
                        fontFamily: 'Poppins',
                        color: Colors.blue,
                        fontWeight: FontWeight.w500)),
                Text(delivery.dropOffLocation,
                    style: theme.bodySmall.override(
                        fontFamily: 'Poppins', color: Colors.grey[800]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      FirebaseDelivery delivery, FlutterFlowTheme theme, bool isDriverBusy) {
    if (delivery.autoDispatch) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
            color: theme.alternate.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: theme.secondaryText, size: 18),
            const SizedBox(width: 8),
            Text(
              "Dispatcher will assign this delivery",
              style: theme.bodyMedium.copyWith(color: theme.secondaryText),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: Icon(Icons.map_outlined, size: 18, color: theme.primary),
            label: Text('VIEW ROUTE',
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
                    borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              context.push('/deliveryRoute', extra: delivery.id.toString());
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (delivery.isScheduled || !isDriverBusy) {
                if (_driverId != null && delivery.client?.clientId != null) {
                  final request = SelectDeliveryRequest(
                    deliveryId: delivery.id,
                    driverId: int.parse(_driverId!),
                  );
                  context.read<ConfirmDeliveryBloc>().add(
                        ConfirmDeliveryRequested(
                          clientId: delivery.client!.clientId.toString(),
                          request: request,
                        ),
                      );
                } else {
                  _showError("Cannot confirm: Missing driver or client ID.");
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text("First complete your active delivery or ride."),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: (delivery.isScheduled || !isDriverBusy)
                    ? theme.primary
                    : Colors.grey,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12)),
            child: const Text('CONFIRM',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
          ),
        ),
      ],
    );
  }
}
