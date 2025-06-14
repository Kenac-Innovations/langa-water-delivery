import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_bloc.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_event.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_state.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_user/models/user_model.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        User? currentUser;
        if (state is Authenticated) {
          currentUser = state.user;
        }

        String displayName = currentUser != null
            ? '${currentUser.firstName} ${currentUser.lastName}'.trim()
            : 'Guest User';
        String displayEmail = currentUser?.email ?? 'Not logged in';

        return Drawer(
          elevation: 16.0,
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration:
                    BoxDecoration(color: FlutterFlowTheme.of(context).primary),
                accountName: Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                accountEmail: Text(
                  displayEmail,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey.shade400,
                    ),
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
                          'assets/images/truck_(1)_1_(traced).png',
                          'Current Deliveries',
                          () {
                            context.pop();
                            context.pushNamed('Current_Deliveries');
                          },
                        ),
                        _buildDivider(context),
                        _buildDrawerItem(
                          context,
                          'assets/images/history_1_(traced).png',
                          'Delivery History',
                          () {
                            context.pop();
                            context.pushNamed('Delivery_History');
                          },
                        ),
                        _buildDivider(context),
                        _buildDrawerItem(
                          context,
                          'assets/images/active_1_(traced).png',
                          'Notification',
                          () {
                            context.pop();
                            context.pushNamed('Notification');
                          },
                        ),
                        _buildDivider(context),
                        _buildDrawerItem(
                          context,
                          'assets/images/user_(2)_1_(traced).png',
                          'Profile',
                          () {
                            context.pop();
                            context.pushNamed('Edit_Profile');
                          },
                        ),
                        // _buildDivider(context),
                        // _buildDrawerItem(
                        //   context,
                        //   'assets/images/settings_(1)_1_(traced).png',
                        //   'Change Password',
                        //   () {
                        //     context.pop();
                        //     context.pushNamed('Change_Password');
                        //   },
                        // ),
                        _buildDivider(context),
                        _buildDrawerItem(
                          context,
                          'assets/images/logout_(3)_1_(traced).png',
                          'Logout',
                          () {
                            _showLogoutConfirmationDialog(context);
                          },
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
      },
    );
  }

  Widget _buildDrawerItem(BuildContext context, String imagePath, String title,
      VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 12.0, 20.0, 12.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        splashColor: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            children: [
              _buildIconWithFallback(context, imagePath),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                    color: FlutterFlowTheme.of(context).primaryText,
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

  Widget _buildIconWithFallback(BuildContext context, String imagePath) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Image.asset(
        imagePath,
        width: 24.0,
        height: 24.0,
        color: FlutterFlowTheme.of(context).primary,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.error_outline,
            size: 24.0,
            color: FlutterFlowTheme.of(context).primary,
          );
        },
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

  void _showLogoutConfirmationDialog(BuildContext context) {
    final authBloc = context.read<AuthBloc>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: FlutterFlowTheme.of(context).titleMedium,
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: FlutterFlowTheme.of(context).bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text('Cancel',
                  style: TextStyle(
                      color: FlutterFlowTheme.of(context).secondaryText)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                authBloc.add(AuthLoggedOut());
              },
              child: Text('Logout',
                  style: TextStyle(
                      color: FlutterFlowTheme.of(context).error,
                      fontWeight: FontWeight.bold)),
            ),
          ],
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        );
      },
    );
  }
}
