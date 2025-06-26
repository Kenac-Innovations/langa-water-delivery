import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_driver/bloc/auth/auth_bloc/auth_bloc_bloc.dart';
import 'package:langas_driver/bloc/auth/auth_bloc/auth_bloc_event.dart';
import 'package:langas_driver/bloc/auth/auth_bloc/auth_bloc_state.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_driver/nav/nav.dart';

class CustomDrawerWidget extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const CustomDrawerWidget({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              String accountName = 'Driver Name';
              String accountEmail = 'driver@example.com';
              String? profileImageUrl;

              if (state is AuthDriverAuthenticated) {
                final profile = state.authData.driverProfile;
                if (profile != null) {
                  accountName =
                      '${profile.firstname} ${profile.lastname}'.trim();
                  accountEmail = profile.email.isNotEmpty
                      ? profile.email
                      : profile.mobileNumber;
                  profileImageUrl = profile.profilePhotoUrl;
                }
              }

              return UserAccountsDrawerHeader(
                decoration:
                    BoxDecoration(color: FlutterFlowTheme.of(context).primary),
                accountName: Text(
                  accountName,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'Poppins'),
                ),
                accountEmail: Text(
                  accountEmail,
                  style: const TextStyle(
                      color: Colors.white, fontFamily: 'Poppins'),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: profileImageUrl != null && profileImageUrl.isNotEmpty
                        ? Image.network(
                            profileImageUrl,
                            fit: BoxFit.cover,
                            width: 90,
                            height: 90,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                  color: FlutterFlowTheme.of(context).primary,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey.shade400,
                              );
                            },
                          )
                        : Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey.shade400,
                          ),
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  // Optional: Add Home if needed
                  context,
                  icon: Icons.home_outlined,
                  title: 'Home',
                  onTap: () {
                    context.pop();
                    context.go('/homePage');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.local_shipping,
                  title: 'Active Orders',
                  onTap: () {
                    context.pop();
                    context.push('/currentDeliveries');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.history,
                  title: 'Delivery History',
                  onTap: () {
                    context.pop();
                    context.push('/deliveryHistory');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.notifications,
                  title: 'Notifications',
                  onTap: () {
                    context.pop();
                    context.push('/notificationPage');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.directions_car, // Icon for vehicles
                  title: 'Vehicle Management', // New Item
                  onTap: () {
                    context.pop();
                    context.push('/vehicles'); // Navigate to vehicles screen
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.person,
                  title: 'Profile',
                  onTap: () {
                    context.pop();
                    context
                        .push('/profile'); // Updated path for read-only profile
                  },
                ),
                // _buildDrawerItem(
                //   context,
                //   icon: Icons.monetization_on,
                //   title: 'My Earnings',
                //   onTap: () {
                //     context.pop();
                //     context.push('/driverEarnings');
                //   },
                // ),
                _buildDrawerItem(
                  context,
                  icon: Icons.payment,
                  title: 'Wallet',
                  onTap: () {
                    context.pop();
                    context.push('/wallet');
                  },
                ),
                // _buildDrawerItem(
                //   context,
                //   icon: Icons.lock,
                //   title: 'Change Password',
                //   onTap: () {
                //     context.pop();
                //     context.push('/changePassword');
                //   },
                // ),
                _buildDrawerItem(
                  context,
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () {
                    context.pop();
                    final authBloc = BlocProvider.of<AuthBloc>(context);
                    _showLogoutDialog(context, authBloc);
                  },
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext buildContext, AuthBloc authBloc) {
    showDialog(
      context: buildContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Logout',
              style: TextStyle(
                  fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
          content: const Text('Are you sure you want to log out?',
              style: TextStyle(fontFamily: 'Poppins')),
          actions: [
            TextButton(
              child: const Text('Cancel',
                  style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                authBloc.add(AuthDriverLoggedOut());
              },
              child:
                  const Text('Logout', style: TextStyle(fontFamily: 'Poppins')),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = FlutterFlowTheme.of(context);
    final itemColor = color ?? theme.primaryText;

    return ListTile(
      leading: Icon(
        icon,
        color: itemColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: itemColor,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
      ),
      onTap: onTap,
    );
  }
}
