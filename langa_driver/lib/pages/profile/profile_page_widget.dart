import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:langas_driver/bloc/auth/auth_bloc/auth_bloc_bloc.dart';
import 'package:langas_driver/bloc/auth/auth_bloc/auth_bloc_state.dart';
import 'package:langas_driver/bloc/driver_profile/driver_profile_bloc_bloc.dart';
import 'package:langas_driver/bloc/driver_profile/driver_profile_bloc_event.dart';
import 'package:langas_driver/bloc/driver_profile/driver_profile_bloc_state.dart';
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
  String? _driverId;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthDriverAuthenticated) {
      _driverId = authState.authData.driverProfile?.id.toString() ??
          authState.authData.userID.toString();
      // if (_driverId != null && _driverId!.isNotEmpty) {
      //   context
      //       .read<DriverProfileBloc>()
      //       .add(LoadDriverProfile(driverId: _driverId!));
      // }
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("User not authenticated or Driver ID missing."),
              backgroundColor: Colors.red),
        );
        if (context.canPop())
          context.pop();
        else
          context.go('/loginPage');
      });
    }
  }

  void _confirmDeleteAccount() {
    if (_driverId == null) return;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone.'),
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
                context
                    .read<DriverProfileBloc>()
                    .add(DeleteDriverProfile(driverId: _driverId!));
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
              if (_driverId != null && _driverId!.isNotEmpty) {
                context
                    .read<DriverProfileBloc>()
                    .add(LoadDriverProfile(driverId: _driverId!));
              }
            },
          ),
        ],
      ),
      backgroundColor: theme.secondaryBackground,
      body: BlocConsumer<DriverProfileBloc, DriverProfileState>(
        listener: (context, state) {
          if (state is DriverProfileDeleteSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.green),
            );
          } else if (state is DriverProfileDeleteFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      "Failed to delete profile: ${state.failure.message}"),
                  backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final authState = context.read<AuthBloc>().state;
          if (state is DriverProfileLoading ||
              state is DriverProfileDeleteInProgress) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DriverProfileLoadSuccess) {
            return _buildProfileView(context, theme, state.driverProfile);
          } else if (state is DriverProfileLoadFailure) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Failed to load profile: ${state.failure.message}'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_driverId != null && _driverId!.isNotEmpty) {
                      context
                          .read<DriverProfileBloc>()
                          .add(LoadDriverProfile(driverId: _driverId!));
                    }
                  },
                  child: const Text('Retry'),
                )
              ],
            ));
          } else {
            return Center(
                child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _driverId == null
                    ? 'Driver ID not found. Unable to load profile.'
                    : 'Profile data not available. Please try refreshing.',
                textAlign: TextAlign.center,
              ),
            ));
          }
        },
      ),
    );
  }

  Widget _buildProfileView(
      BuildContext context, FlutterFlowTheme theme, DriverProfile profile) {
    return RefreshIndicator(
      onRefresh: () async {
        if (_driverId != null && _driverId!.isNotEmpty) {
          context
              .read<DriverProfileBloc>()
              .add(LoadDriverProfile(driverId: _driverId!));
        }
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
