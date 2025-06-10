import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_bloc.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_event.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';

class UIComponents {
  // Loading indicator for better user experience
  static Widget buildLoadingIndicator(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitSpinningLines(
            size: 60.0,
            color: FlutterFlowTheme.of(context).primary,
            lineWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Finding your location...',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Poppins',
                  fontSize: 16.0,
                  color: Colors.black54,
                ),
          ),
        ],
      ),
    );
  }

  // Progress overlay
  static Widget buildProgressOverlay(bool isVisible) {
    return Visibility(
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      visible: isVisible,
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: const Center(
          child: SpinKitSpinningLines(
            size: 60.0,
            color: Colors.white,
            lineWidth: 3,
          ),
        ),
      ),
    );
  }

  // Show alert dialog for logout confirmation
  static void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  'Logout',
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                        fontFamily: 'Poppins',
                        color: const Color(0xff333333),
                        fontSize: 24.0,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 20),

                // Message
                Text(
                  'Are you sure do you want to logout?',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodyMediumFamily,
                        color: const Color(0xff666666),
                        fontSize: 16.0,
                      ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Cancel button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        // Fix: Updated to match current Flutter version
                        backgroundColor:
                            FlutterFlowTheme.of(context).primaryBackground,
                        foregroundColor:
                            FlutterFlowTheme.of(context).primaryText,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        context.read<AuthBloc>().add(AuthLoggedOut());
                      },
                      child: Text(
                        'Cancel',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Logout button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        // Fix: Updated to match current Flutter version
                        backgroundColor: FlutterFlowTheme.of(context).primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Implement actual logout functionality
                      },
                      child: Text(
                        'Logout',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Improved delivery option buttons
  static Widget buildDeliveryOptionButton(
      {required BuildContext context,
      required String text,
      required bool isActive,
      required VoidCallback onPressed}) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          foregroundColor: isActive
              ? Colors.white
              : FlutterFlowTheme.of(context).homebuttontext,
          padding: const EdgeInsets.symmetric(vertical: 12),
          elevation: isActive ? 4 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(
              color: FlutterFlowTheme.of(context).primary,
              width: 1.0,
            ),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 15.0, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }
}
