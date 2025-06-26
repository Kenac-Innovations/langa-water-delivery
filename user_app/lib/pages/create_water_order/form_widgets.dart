import 'package:flutter/material.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_user/util/apps_enums.dart';

class FormWidgets {
  static InputDecoration buildInputDecoration(BuildContext context,
      {required String labelText, String? hintText}) {
    final theme = FlutterFlowTheme.of(context);
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: theme.labelMedium,
      hintStyle: theme.labelMedium,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: theme.alternate,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: theme.primary,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: theme.error,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: theme.error,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

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
    final theme = FlutterFlowTheme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: buildInputDecoration(context,
                labelText: labelText, hintText: hintText)
            .copyWith(prefixIcon: prefixIcon),
        style: theme.bodyMedium,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }

  static Widget buildDeliveryTypeToggle({
    required BuildContext context,
    required bool isScheduled,
    required Function(bool) onChanged,
  }) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Delivery Time",
            style: theme.titleSmall,
          ),
          Row(
            children: [
              Text(
                "Immediate",
                style: TextStyle(
                  color: !isScheduled ? theme.primary : Colors.grey,
                  fontWeight:
                      !isScheduled ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
              Switch.adaptive(
                value: isScheduled,
                onChanged: onChanged,
                activeColor: Colors.white,
                activeTrackColor: theme.primary,
                inactiveThumbColor: Colors.grey.shade400,
                inactiveTrackColor: Colors.grey.shade300,
              ),
              Text(
                "Scheduled",
                style: TextStyle(
                  color: isScheduled ? theme.primary : Colors.grey,
                  fontWeight: isScheduled ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
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
    final theme = FlutterFlowTheme.of(context);
    bool isSelected = groupValue == value;

    return GestureDetector(
      onTap: () {
        onChanged(value);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.primary : Colors.grey.shade300,
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
                    ? theme.primary.withOpacity(0.1)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? theme.primary : Colors.grey.shade700,
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
                    style: theme.bodyMedium.override(
                      fontFamily: 'Poppins',
                      color: Colors.black87,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.bodyMedium.override(
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
              activeColor: theme.primary,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
