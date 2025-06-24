import 'package:flutter/material.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_user/util/apps_enums.dart';

class FormWidgets {
  static Widget buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    Widget? prefixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                fontFamily: 'Poppins',
                color: Colors.black54,
                fontSize: 14.0,
                fontWeight: FontWeight.normal,
              ),
          hintText: hintText,
          hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Poppins',
                color: Colors.black38,
                fontSize: 14.0,
                fontWeight: FontWeight.w300,
              ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.shade300,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).primary,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).error,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).error,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          prefixIcon: prefixIcon,
        ),
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'Poppins',
              color: Colors.black87,
              fontSize: 15.0,
            ),
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }

  static Widget buildPaymentOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required WaterPaymentType value,
    required WaterPaymentType groupValue,
    required Function(WaterPaymentType?) onChanged,
  }) {
    bool isSelected = groupValue == value;

    return GestureDetector(
      onTap: () {
        onChanged(value);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? FlutterFlowTheme.of(context).primary.withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? FlutterFlowTheme.of(context).primary
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? FlutterFlowTheme.of(context).primary.withOpacity(0.1)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? FlutterFlowTheme.of(context).primary
                    : Colors.grey.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Poppins',
                          color: Colors.black87,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Poppins',
                          color: Colors.black54,
                          fontSize: 13.0,
                        ),
                  ),
                ],
              ),
            ),
            Radio<WaterPaymentType>(
              value: value,
              groupValue: groupValue,
              activeColor: FlutterFlowTheme.of(context).primary,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildDeliveryTypeToggle({
    required BuildContext context,
    required bool isImmediate,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Delivery Time",
            style: FlutterFlowTheme.of(context).titleSmall.override(
                  fontFamily: 'Poppins',
                  color: Colors.black87,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                ),
          ),
          Row(
            children: [
              Text(
                "Scheduled",
                style: TextStyle(
                  color: !isImmediate
                      ? FlutterFlowTheme.of(context).primary
                      : Colors.grey,
                  fontWeight:
                      !isImmediate ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
              Switch.adaptive(
                value: isImmediate,
                onChanged: onChanged,
                activeColor: Colors.white,
                activeTrackColor: FlutterFlowTheme.of(context).primary,
                inactiveThumbColor: Colors.grey.shade400,
                inactiveTrackColor: Colors.grey.shade300,
              ),
              Text(
                "Immediate",
                style: TextStyle(
                  color: isImmediate
                      ? FlutterFlowTheme.of(context).primary
                      : Colors.grey,
                  fontWeight: isImmediate ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget buildCostItem({
    required BuildContext context,
    required String label,
    required String value,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Poppins',
                  color: isTotal ? Colors.black87 : Colors.black54,
                  fontSize: isTotal ? 16.0 : 14.0,
                  fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
                ),
          ),
          Text(
            value,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Poppins',
                  color: isTotal
                      ? FlutterFlowTheme.of(context).primary
                      : Colors.black87,
                  fontSize: isTotal ? 16.0 : 14.0,
                  fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
