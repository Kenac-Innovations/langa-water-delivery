import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_widgets.dart';
import 'package:langas_driver/models/auth_models.dart';
import 'package:langas_driver/models/vehicle_model.dart';
import 'package:langas_driver/nav/nav.dart';
import 'package:langas_driver/utils/delivery_enums.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  // Hardcoded sample data for the driver profile
  final DriverProfile _driverProfile = const DriverProfile(
    id: 1,
    firstname: 'John',
    lastname: 'Doe',
    gender: 'Male',
    mobileNumber: '+263 777 123 456',
    email: 'john.doe.driver@watertransporter.com',
    address: '123 Samora Machel Ave, Harare',
    nationalIdNo: '63-1234567-A01',
    driverLicenseNo: 'D1234567',
    approvalStatus: 'APPROVED',
    approvedBy: 'Admin',
    dateApproved: '2023-10-26T10:00:00Z',
    profilePhotoUrl: 'https://placehold.co/200x200/2451DC/FFFFFF?text=JD',
    userId: 101,
    walletId: 501,
    activeVehicle: Vehicle(
      vehicleId: 2,
      vehicleModel: 'Canter',
      vehicleColor: 'Blue',
      vehicleMake: 'Mitsubishi',
      licensePlateNo: 'ACF 5678',
      active: true,
      vehicleType: VehicleType.TRUCK,
      vehicleStatus: VehicleStatus.APPROVED,
    ),
    rating: 4.8,
    walletBalance: 75.50,
    onlineStatus: true,
    isBusy: false,
    numberOfDeliveries: 42,
  );

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
              'This is a static page. The delete functionality is disabled.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primary,
        title: Text(
          'My Profile',
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("This is a static page.")),
              );
            },
          ),
        ],
      ),
      backgroundColor: theme.secondaryBackground,
      body: _buildProfileView(context, theme, _driverProfile),
    );
  }

  Widget _buildProfileView(
      BuildContext context, FlutterFlowTheme theme, DriverProfile profile) {
    return RefreshIndicator(
      onRefresh: () async {
        // No action needed for a static page
      },
      child: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          _buildHeader(theme, profile),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildSectionTitle(theme, "Personal Information"),
          ),
          _buildInfoCard(theme, [
            _buildInfoRow(
                theme, Icons.person_outline, 'First Name', profile.firstname),
            _buildInfoRow(
                theme, Icons.person_outline, 'Last Name', profile.lastname),
            if (profile.middleName != null && profile.middleName!.isNotEmpty)
              _buildInfoRow(theme, Icons.person_outline, 'Middle Name',
                  profile.middleName!),
            _buildInfoRow(theme, Icons.email_outlined, 'Email', profile.email),
            _buildInfoRow(
                theme, Icons.phone_outlined, 'Phone', profile.mobileNumber),
            _buildInfoRow(
                theme, Icons.transgender_outlined, 'Gender', profile.gender),
            _buildInfoRow(
                theme, Icons.location_on_outlined, 'Address', profile.address,
                maxLines: 3),
          ]),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildSectionTitle(theme, "Identity & Verification"),
          ),
          _buildInfoCard(theme, [
            _buildInfoRow(theme, Icons.badge_outlined, 'National ID No.',
                profile.nationalIdNo),
            if (profile.driverLicenseNo != null &&
                profile.driverLicenseNo!.isNotEmpty)
              _buildInfoRow(theme, Icons.drive_eta_outlined, 'License No.',
                  profile.driverLicenseNo!),
            _buildInfoRow(theme, Icons.verified_user_outlined,
                'Approval Status', profile.approvalStatus ?? 'N/A',
                valueColor:
                    _getApprovalStatusColor(theme, profile.approvalStatus)),
            if (profile.approvedBy != null && profile.approvedBy!.isNotEmpty)
              _buildInfoRow(theme, Icons.admin_panel_settings_outlined,
                  'Approved By', profile.approvedBy!),
            if (profile.dateApproved != null &&
                profile.dateApproved!.isNotEmpty)
              _buildInfoRow(theme, Icons.event_available_outlined,
                  'Date Approved', _formatDate(profile.dateApproved)),
          ]),
          if (profile.activeVehicle != null) ...[
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildSectionTitle(theme, "Active Vehicle"),
            ),
            _buildActiveVehicleCard(theme, profile.activeVehicle!),
          ],
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildSectionTitle(theme, "Account Details"),
          ),
          _buildInfoCard(theme, [
            _buildInfoRow(theme, Icons.star_outline, 'Rating',
                profile.rating?.toStringAsFixed(1) ?? 'N/A'),
            _buildInfoRow(
                theme,
                Icons.account_balance_wallet_outlined,
                'Wallet Balance',
                profile.walletBalance != null
                    ? '\$${profile.walletBalance!.toStringAsFixed(2)}'
                    : 'N/A'),
            _buildInfoRow(
                theme, Icons.vpn_key, 'User ID', profile.userId.toString()),
            if (profile.walletId != null)
              _buildInfoRow(theme, Icons.wallet_membership, 'Wallet ID',
                  profile.walletId.toString()),
          ]),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: FFButtonWidget(
              onPressed: _confirmDeleteAccount,
              text: 'DELETE ACCOUNT',
              options: FFButtonOptions(
                width: double.infinity,
                height: 50,
                color: theme.error,
                textStyle: theme.titleSmall.override(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
                elevation: 2,
                borderSide: const BorderSide(
                  color: Colors.transparent,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHeader(FlutterFlowTheme theme, DriverProfile profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      decoration:
          BoxDecoration(color: theme.primaryBackground, boxShadow: const [
        BoxShadow(
          blurRadius: 4,
          color: Color(0x33000000),
          offset: Offset(0, 2),
        )
      ]),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: theme.primary.withOpacity(0.1),
            backgroundImage: profile.profilePhotoUrl != null &&
                    profile.profilePhotoUrl!.isNotEmpty
                ? NetworkImage(profile.profilePhotoUrl!)
                : null,
            child: profile.profilePhotoUrl == null ||
                    profile.profilePhotoUrl!.isEmpty
                ? Icon(Icons.person, size: 70, color: theme.primary)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            '${profile.firstname} ${profile.lastname}',
            style: theme.headlineSmall.override(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: theme.primaryText),
          ),
          const SizedBox(height: 4),
          Text(
            profile.email,
            style: theme.bodyMedium
                .override(fontFamily: 'Poppins', color: theme.secondaryText),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: _getApprovalStatusColor(theme, profile.approvalStatus)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(20)),
            child: Text(
              profile.approvalStatus ?? 'Pending',
              style: theme.bodySmall.override(
                  fontFamily: 'Poppins',
                  color: _getApprovalStatusColor(theme, profile.approvalStatus),
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(FlutterFlowTheme theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Text(
        title,
        style: theme.titleMedium.override(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: theme.primaryText.withOpacity(0.8)),
      ),
    );
  }

  Widget _buildInfoCard(FlutterFlowTheme theme, List<Widget> children) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: Colors.white,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          int idx = entry.key;
          Widget widget = entry.value;
          return Column(
            children: [
              widget,
              if (idx < children.length - 1)
                Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                    color: theme.alternate.withOpacity(0.5)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfoRow(
      FlutterFlowTheme theme, IconData icon, String label, String value,
      {Color? valueColor, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.primary, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.bodySmall.override(
                      fontFamily: 'Poppins',
                      color: theme.secondaryText,
                      fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : '-',
                  style: theme.bodyLarge.override(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: valueColor ?? theme.primaryText),
                  maxLines: maxLines,
                  overflow: maxLines == 1
                      ? TextOverflow.ellipsis
                      : TextOverflow.visible,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveVehicleCard(FlutterFlowTheme theme, Vehicle vehicle) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: Colors.white,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getVehicleIcon(vehicle.vehicleType),
                    color: theme.primary, size: 28),
                const SizedBox(width: 12),
                Text("${vehicle.vehicleMake} ${vehicle.vehicleModel}",
                    style: theme.titleMedium.override(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailItem(theme, "Color", vehicle.vehicleColor),
            _buildDetailItem(theme, "License Plate", vehicle.licensePlateNo),
            _buildDetailItem(theme, "Type", vehicle.vehicleType.name),
            _buildDetailItem(theme, "Status", vehicle.vehicleStatus.name,
                valueColor:
                    _getVehicleStatusColor(theme, vehicle.vehicleStatus)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(FlutterFlowTheme theme, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.bodyMedium
                .override(fontFamily: 'Poppins', color: theme.secondaryText),
          ),
          Text(
            value,
            style: theme.bodyMedium.override(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: valueColor ?? theme.primaryText),
          ),
        ],
      ),
    );
  }

  IconData _getVehicleIcon(VehicleType vehicleType) {
    switch (vehicleType) {
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

  Color _getApprovalStatusColor(FlutterFlowTheme theme, String? status) {
    status = status?.toUpperCase();
    if (status == 'APPROVED') return theme.success;
    if (status == 'REJECTED' || status == 'SUSPENDED') return theme.error;
    return theme.warning; // For PENDING or N/A
  }

  Color _getVehicleStatusColor(FlutterFlowTheme theme, VehicleStatus? status) {
    if (status == null) return theme.secondaryText;
    switch (status) {
      case VehicleStatus.APPROVED:
        return theme.success;
      case VehicleStatus.REJECTED:
      case VehicleStatus.SUSPENDED:
        return theme.error;
      case VehicleStatus.PENDING:
        return theme.warning;
      default:
        return theme.secondaryText;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('MMM d, yyyy').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }
}
