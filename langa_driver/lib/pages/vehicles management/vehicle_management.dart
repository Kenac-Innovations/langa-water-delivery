import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_driver/bloc/auth/auth_bloc/auth_bloc_bloc.dart';
import 'package:langas_driver/bloc/auth/auth_bloc/auth_bloc_state.dart';
import 'package:langas_driver/bloc/vehicles/vehicle_management/vehicle_management_bloc_bloc.dart';
import 'package:langas_driver/bloc/vehicles/vehicle_management/vehicle_management_bloc_event.dart';
import 'package:langas_driver/bloc/vehicles/vehicle_management/vehicle_management_bloc_state.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_driver/models/vehicle_model.dart';
import 'package:langas_driver/nav/nav.dart';
import 'package:langas_driver/utils/delivery_enums.dart';

class VehicleManagementScreen extends StatefulWidget {
  const VehicleManagementScreen({super.key});

  @override
  State<VehicleManagementScreen> createState() =>
      _VehicleManagementScreenState();
}

class _VehicleManagementScreenState extends State<VehicleManagementScreen> {
  String? _driverId;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthDriverAuthenticated) {
      _driverId = authState.authData.driverProfile?.id.toString();
      if (_driverId != null && _driverId!.isNotEmpty) {
        context
            .read<VehicleManagementBloc>()
            .add(LoadDriverVehicles(driverId: _driverId!));
      }
    } else {
      print("Error: Driver ID not found in Auth state for Vehicle Management.");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Authentication error. Please log in again."),
              backgroundColor: Colors.red),
        );
        context.go('/loginPage');
      });
    }
  }

  void _switchVehicle(String vehicleId) {
    if (_driverId != null && _driverId!.isNotEmpty) {
      context
          .read<VehicleManagementBloc>()
          .add(SetActiveVehicle(driverId: _driverId!, vehicleId: vehicleId));
    }
  }

  void _confirmDeleteVehicle(String vehicleId) {
    if (_driverId == null) return;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Vehicle'),
          content: const Text(
              'Are you sure you want to delete this vehicle? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<VehicleManagementBloc>().add(
                    DeleteVehicleRequested(
                        driverId: _driverId!, vehicleId: vehicleId));
              },
            ),
          ],
        );
      },
    );
  }

  IconData _getVehicleTypeIcon(VehicleType type) {
    switch (type) {
      case VehicleType.CAR:
        return Icons.directions_car_filled_outlined;
      case VehicleType.BIKE:
        return Icons.pedal_bike_outlined;
      case VehicleType.TRUCK:
        return Icons.fire_truck_outlined;
      case VehicleType.VAN:
        return Icons.airport_shuttle_outlined;
      default:
        return Icons.directions_car_outlined;
    }
  }

  Color _getVehicleStatusColor(VehicleStatus status, FlutterFlowTheme theme) {
    switch (status) {
      case VehicleStatus.APPROVED:
        return theme.success;
      case VehicleStatus.PENDING:
        return theme.warning;
      case VehicleStatus.REJECTED:
      case VehicleStatus.SUSPENDED:
        return theme.error;
      default:
        return theme.secondaryText;
    }
  }

  Widget _buildImageThumbnail(String? imageUrl, FlutterFlowTheme theme) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: 60,
        height: 40,
        decoration: BoxDecoration(
          color: theme.alternate.withOpacity(0.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(Icons.image_not_supported,
            color: theme.secondaryText, size: 20),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.network(
        imageUrl,
        width: 60,
        height: 40,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 60,
            height: 40,
            color: theme.alternate.withOpacity(0.5),
            child: Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.primary))),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 60,
            height: 40,
            color: theme.alternate.withOpacity(0.5),
            child: Icon(Icons.error_outline, color: theme.error, size: 20),
          );
        },
      ),
    );
  }

  Widget _buildVehicleCard(
      BuildContext context, Vehicle vehicle, FlutterFlowTheme theme) {
    bool isCurrentlyActiveByApi = vehicle.active;

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: Colors.white,
      elevation: 3.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(
            color:
                isCurrentlyActiveByApi ? theme.primary : Colors.grey.shade300,
            width: isCurrentlyActiveByApi ? 2.5 : 1,
          )),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getVehicleTypeIcon(vehicle.vehicleType),
                    color: theme.primary, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${vehicle.vehicleMake} ${vehicle.vehicleModel}',
                          style: theme.titleLarge.override(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: theme.primaryText)),
                      Text(
                        vehicle.licensePlateNo,
                        style: theme.bodyMedium.override(
                            fontFamily: 'Poppins',
                            color: theme.secondaryText,
                            fontSize: 14),
                      ),
                    ],
                  ),
                ),
                if (isCurrentlyActiveByApi)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: theme.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle,
                            color: theme.success, size: 16),
                        const SizedBox(width: 4),
                        Text("ACTIVE",
                            style: theme.bodySmall.override(
                                fontFamily: 'Poppins',
                                color: theme.success,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Color: ${vehicle.vehicleColor}',
                  style: theme.bodyMedium,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color:
                          _getVehicleStatusColor(vehicle.vehicleStatus, theme)
                              .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    'Approval: ${vehicle.vehicleStatus.name}',
                    style: theme.bodySmall.override(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: _getVehicleStatusColor(
                            vehicle.vehicleStatus, theme)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (vehicle.frontImageUrl != null ||
                vehicle.registrationBookUrl != null ||
                vehicle.backImageUrl != null ||
                vehicle.sideImageUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                child: Text("Vehicle Images:",
                    style:
                        theme.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
              ),
            if (vehicle.frontImageUrl != null ||
                vehicle.registrationBookUrl != null ||
                vehicle.backImageUrl != null ||
                vehicle.sideImageUrl != null)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (vehicle.frontImageUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Column(children: [
                          _buildImageThumbnail(vehicle.frontImageUrl, theme),
                          Text("Front", style: theme.bodySmall)
                        ]),
                      ),
                    if (vehicle.backImageUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Column(children: [
                          _buildImageThumbnail(vehicle.backImageUrl, theme),
                          Text("Back", style: theme.bodySmall)
                        ]),
                      ),
                    if (vehicle.sideImageUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Column(children: [
                          _buildImageThumbnail(vehicle.sideImageUrl, theme),
                          Text("Side", style: theme.bodySmall)
                        ]),
                      ),
                    if (vehicle.registrationBookUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Column(children: [
                          _buildImageThumbnail(
                              vehicle.registrationBookUrl, theme),
                          Text("Reg. Book", style: theme.bodySmall)
                        ]),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (!isCurrentlyActiveByApi &&
                    vehicle.vehicleStatus == VehicleStatus.APPROVED)
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.power_settings_new, size: 18),
                      label: const Text('SET AS ACTIVE',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold)),
                      onPressed: () =>
                          _switchVehicle(vehicle.vehicleId.toString()),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: theme.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                    ),
                  ),
                if (!isCurrentlyActiveByApi &&
                    vehicle.vehicleStatus == VehicleStatus.APPROVED)
                  const SizedBox(
                      width: 8), // Add space if switch button is visible
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.delete_outline,
                        size: 18, color: theme.error),
                    label: Text('DELETE',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: theme.error)),
                    onPressed: () =>
                        _confirmDeleteVehicle(vehicle.vehicleId.toString()),
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(color: theme.error),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primary,
        title: Text(
          'My Vehicles',
          style: theme.headlineMedium.override(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              if (_driverId != null && _driverId!.isNotEmpty) {
                context
                    .read<VehicleManagementBloc>()
                    .add(LoadDriverVehicles(driverId: _driverId!));
              }
            },
          ),
        ],
      ),
      backgroundColor: theme.secondaryBackground,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_driverId != null) {
            context.push('/addVehicle');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Cannot add vehicle: Driver ID missing.'),
                  backgroundColor: Colors.red),
            );
          }
        },
        backgroundColor: theme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("ADD VEHICLE"),
      ),
      body: BlocConsumer<VehicleManagementBloc, VehicleManagementState>(
        listener: (context, state) {
          if (state is VehicleActionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Error: ${state.failure.message}'),
                  backgroundColor: Colors.red),
            );
          } else if (state is VehicleCreateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('Vehicle added successfully! Awaiting approval.'),
                  backgroundColor: Colors.green),
            );
            if (_driverId != null) {
              context
                  .read<VehicleManagementBloc>()
                  .add(LoadDriverVehicles(driverId: _driverId!));
            }
          } else if (state is VehicleSwitchSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.successMessage),
                  backgroundColor: Colors.green),
            );
            if (_driverId != null) {
              context
                  .read<VehicleManagementBloc>()
                  .add(LoadDriverVehicles(driverId: _driverId!));
            }
          } else if (state is VehicleDeleteSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.green),
            );
            if (_driverId != null) {
              context
                  .read<VehicleManagementBloc>()
                  .add(LoadDriverVehicles(driverId: _driverId!));
            }
          }
        },
        builder: (context, state) {
          if (state is VehicleInitial ||
              (state is VehicleLoading && state.props.isEmpty)) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is VehicleListLoadFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Failed to load vehicles: ${state.failure.message}'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (_driverId != null) {
                        context
                            .read<VehicleManagementBloc>()
                            .add(LoadDriverVehicles(driverId: _driverId!));
                      }
                    },
                    child: const Text('Retry'),
                  )
                ],
              ),
            );
          } else if (state is VehicleListLoadSuccess ||
              state is VehicleActionFailure ||
              state is VehicleCreateSuccess ||
              state is VehicleSwitchSuccess ||
              state is VehicleDeleteSuccess ||
              state is VehicleActionInProgress) {
            List<Vehicle> allVehicles = [];
            bool showLoadingOverlay = state is VehicleActionInProgress;

            Vehicle? activeVehicleFromApiAttribute;
            List<Vehicle> otherVehiclesToList = [];

            if (state is VehicleListLoadSuccess) {
              allVehicles = state.vehicles;
            } else if (state is VehicleActionFailure) {
              allVehicles = state.lastKnownVehicles;
            } else if (state is VehicleCreateSuccess ||
                state is VehicleSwitchSuccess ||
                state is VehicleDeleteSuccess ||
                state is VehicleActionInProgress) {
              final currentState = context.read<VehicleManagementBloc>().state;
              if (currentState is VehicleListLoadSuccess) {
                allVehicles = currentState.vehicles;
              } else if (currentState is VehicleActionFailure) {
                allVehicles = currentState.lastKnownVehicles;
              }
            }

            try {
              activeVehicleFromApiAttribute =
                  allVehicles.firstWhere((v) => v.active);
              otherVehiclesToList =
                  allVehicles.where((v) => !v.active).toList();
            } catch (e) {
              activeVehicleFromApiAttribute = null;
              otherVehiclesToList = allVehicles;
            }

            if (allVehicles.isEmpty &&
                !(state is VehicleLoading) &&
                !(state is VehicleActionInProgress)) {
              return Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.no_transfer_outlined,
                      size: 80, color: theme.secondaryText.withOpacity(0.6)),
                  const SizedBox(height: 16),
                  Text('No vehicles found.', style: theme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the "+" button to add your first vehicle.',
                    style: theme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ));
            }

            return Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    if (_driverId != null) {
                      context
                          .read<VehicleManagementBloc>()
                          .add(LoadDriverVehicles(driverId: _driverId!));
                    }
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    children: [
                      if (activeVehicleFromApiAttribute != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text("ACTIVE VEHICLE",
                              style: theme.titleSmall.override(
                                  fontFamily: 'Poppins',
                                  color: theme.primary,
                                  fontWeight: FontWeight.bold)),
                        ),
                      if (activeVehicleFromApiAttribute != null)
                        _buildVehicleCard(
                            context, activeVehicleFromApiAttribute, theme),
                      if (activeVehicleFromApiAttribute != null &&
                          otherVehiclesToList.isNotEmpty)
                        const SizedBox(height: 24),
                      if (otherVehiclesToList.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                              activeVehicleFromApiAttribute != null
                                  ? "OTHER VEHICLES"
                                  : "AVAILABLE VEHICLES",
                              style: theme.titleSmall.override(
                                  fontFamily: 'Poppins',
                                  color: theme.secondaryText,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ...otherVehiclesToList
                          .map((vehicle) =>
                              _buildVehicleCard(context, vehicle, theme))
                          .toList(),
                      if (activeVehicleFromApiAttribute == null &&
                          allVehicles.isNotEmpty &&
                          !(state is VehicleLoading) &&
                          !(state is VehicleActionInProgress) &&
                          otherVehiclesToList.isEmpty) ...[
                        Text("AVAILABLE VEHICLES",
                            style: theme.titleSmall.override(
                                fontFamily: 'Poppins',
                                color: theme.secondaryText,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...allVehicles
                            .map((vehicle) =>
                                _buildVehicleCard(context, vehicle, theme))
                            .toList(),
                      ]
                    ],
                  ),
                ),
                if (showLoadingOverlay)
                  Container(
                      color: Colors.black.withOpacity(0.3),
                      child: Center(
                          child:
                              CircularProgressIndicator(color: theme.primary)))
              ],
            );
          } else {
            return const Center(child: Text('Manage your vehicles here.'));
          }
        },
      ),
    );
  }
}
