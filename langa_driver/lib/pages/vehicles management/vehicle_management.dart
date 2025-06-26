import 'package:flutter/material.dart';
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
  // Hardcoded list of available water delivery trucks
  final List<Vehicle> _availableVehicles = [
    Vehicle(
      vehicleId: 1,
      vehicleModel: 'H-100',
      vehicleColor: 'White',
      vehicleMake: 'Hyundai',
      licensePlateNo: 'AGE 1234',
      active: false,
      vehicleType: VehicleType.TRUCK,
      vehicleStatus: VehicleStatus.APPROVED,
      frontImageUrl: 'https://placehold.co/600x400/FFFFFF/000000?text=Front',
      backImageUrl: 'https://placehold.co/600x400/FFFFFF/000000?text=Back',
      sideImageUrl: 'https://placehold.co/600x400/FFFFFF/000000?text=Side',
    ),
    Vehicle(
      vehicleId: 2,
      vehicleModel: 'Canter',
      vehicleColor: 'Blue',
      vehicleMake: 'Mitsubishi',
      licensePlateNo: 'ACF 5678',
      active: true, // Example of an active vehicle
      vehicleType: VehicleType.TRUCK,
      vehicleStatus: VehicleStatus.APPROVED,
      frontImageUrl: 'https://placehold.co/600x400/FFFFFF/000000?text=Front',
      backImageUrl: 'https://placehold.co/600x400/FFFFFF/000000?text=Back',
      sideImageUrl: 'https://placehold.co/600x400/FFFFFF/000000?text=Side',
    ),
    Vehicle(
      vehicleId: 3,
      vehicleModel: 'Dyna',
      vehicleColor: 'Red',
      vehicleMake: 'Toyota',
      licensePlateNo: 'ADE 9012',
      active: false,
      vehicleType: VehicleType.TRUCK,
      vehicleStatus: VehicleStatus.PENDING,
    ),
  ];

  void _requestVehicle(Vehicle vehicle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Request sent for ${vehicle.vehicleMake} ${vehicle.vehicleModel}.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  IconData _getVehicleTypeIcon(VehicleType type) {
    switch (type) {
      case VehicleType.TRUCK:
        return Icons.local_shipping;
      case VehicleType.VAN:
        return Icons.airport_shuttle;
      default:
        return Icons.directions_car;
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
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: Colors.white,
      elevation: 3.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(
            color: vehicle.active ? theme.primary : Colors.grey.shade300,
            width: vehicle.active ? 2.5 : 1,
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
                if (vehicle.active)
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
                    'Status: ${vehicle.vehicleStatus.name}',
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
                  ],
                ),
              ),
            const SizedBox(height: 16),
            if (!vehicle.active)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('REQUEST VEHICLE',
                      style: TextStyle(
                          fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                  onPressed: () => _requestVehicle(vehicle),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
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
          'Available Delivery Trucks',
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
              // Can be used for future refresh logic if needed
            },
          ),
        ],
      ),
      backgroundColor: theme.secondaryBackground,
      body: _availableVehicles.isEmpty
          ? Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.no_transfer_outlined,
                    size: 80, color: theme.secondaryText.withOpacity(0.6)),
                const SizedBox(height: 16),
                Text('No vehicles available.', style: theme.titleMedium),
              ],
            ))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: _availableVehicles.length,
              itemBuilder: (context, index) {
                final vehicle = _availableVehicles[index];
                return _buildVehicleCard(context, vehicle, theme);
              },
            ),
    );
  }
}
