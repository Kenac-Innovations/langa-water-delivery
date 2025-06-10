import 'package:flutter/material.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_user/pages/home_page/ui_componets.dart';

class MapWidgets {
  // Search bar widget
  static Widget buildSearchBar({
    required BuildContext context,
    required String location,
    required VoidCallback onTap,
  }) {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Card(
        color: Colors.white,
        elevation: 4,
        shadowColor: Colors.black38,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.search, color: FlutterFlowTheme.of(context).primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    location,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Poppins',
                          fontSize: 14.0,
                          color: Colors.black87,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Bottom card for delivery options
  static Widget buildBottomCard({
    required BuildContext context,
    required bool isSelected,
    required bool isSelected2,
    required bool isSelected3,
    required VoidCallback onInstantPressed,
  }) {
    return Align(
      alignment: const AlignmentDirectional(0.0, 1.0),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 24.0),
        child: Card(
          color: Colors.white,
          elevation: 4,
          shadowColor: Colors.black38,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(
              color: FlutterFlowTheme.of(context).primary,
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Fast delivery when you need it most send your package today ',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Poppins',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: FlutterFlowTheme.of(context).homebottomtext,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Delivery options with improved styling
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    UIComponents.buildDeliveryOptionButton(
                      context: context,
                      text: 'Create Delivery',
                      isActive: isSelected,
                      onPressed: onInstantPressed,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
