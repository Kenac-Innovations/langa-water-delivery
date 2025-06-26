import 'package:flutter/material.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_driver/nav/nav.dart';

class CustomDrawerWidget extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const CustomDrawerWidget({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    // Static user data
    const String accountName = 'Water Transporter';
    const String accountEmail = 'driver@watertransporter.com';
    const String? profileImageUrl = null; // Set to null for placeholder icon

    return Drawer(
      elevation: 16.0,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration:
                BoxDecoration(color: FlutterFlowTheme.of(context).primary),
            accountName: Text(
              accountName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),
            accountEmail: const Text(
              accountEmail,
              style: TextStyle(
                color: Colors.white70,
                fontFamily: 'Poppins',
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor:
                  FlutterFlowTheme.of(context).primary.withOpacity(0.5),
              child: const Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    _buildDrawerItem(
                      context,
                      icon: Icons.home_outlined,
                      title: 'Home',
                      onTap: () {
                        context.pop();
                        context.go('/homePage');
                      },
                    ),
                    _buildDivider(context),
                    _buildDrawerItem(
                      context,
                      icon: Icons.local_shipping,
                      title: 'Active Orders',
                      onTap: () {
                        context.pop();
                        context.push('/currentDeliveries');
                      },
                    ),
                    _buildDivider(context),
                    _buildDrawerItem(
                      context,
                      icon: Icons.history,
                      title: 'Delivery History',
                      onTap: () {
                        context.pop();
                        context.push('/deliveryHistory');
                      },
                    ),
                    _buildDivider(context),
                    _buildDrawerItem(
                      context,
                      icon: Icons.notifications,
                      title: 'Notifications',
                      onTap: () {
                        context.pop();
                        context.push('/notificationPage');
                      },
                    ),
                    _buildDivider(context),
                    _buildDrawerItem(
                      context,
                      icon: Icons.fire_truck,
                      title: 'Truck Management',
                      onTap: () {
                        context.pop();
                        context.push('/vehicles');
                      },
                    ),
                    _buildDivider(context),
                    _buildDrawerItem(
                      context,
                      icon: Icons.person,
                      title: 'Profile',
                      onTap: () {
                        context.pop();
                        context.push('/profile');
                      },
                    ),
                    _buildDivider(context),
                    _buildDrawerItem(
                      context,
                      icon: Icons.logout,
                      title: 'Logout',
                      onTap: () {
                        _showLogoutDialog(context);
                      },
                      color: FlutterFlowTheme.of(context).error,
                    ),
                    _buildDivider(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext buildContext) {
    showDialog(
      context: buildContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: FlutterFlowTheme.of(buildContext).titleMedium.override(
                  fontFamily: 'Poppins',
                  color: FlutterFlowTheme.of(buildContext).primaryText,
                ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: FlutterFlowTheme.of(buildContext).bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: FlutterFlowTheme.of(buildContext).secondaryText,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close dialog
                buildContext.pop(); // Close drawer
                buildContext.go('/loginPage'); // Navigate to login
              },
              child: Text(
                'Logout',
                style: TextStyle(
                  color: FlutterFlowTheme.of(buildContext).error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          backgroundColor:
              FlutterFlowTheme.of(buildContext).secondaryBackground,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 12.0, 20.0, 12.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        splashColor: theme.primary.withOpacity(0.1),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: color ?? theme.primary,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                    color: itemColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1.0,
      color: FlutterFlowTheme.of(context).alternate,
      indent: 20,
      endIndent: 20,
    );
  }
}
