import 'package:flutter/material.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_user/util/apps_enums.dart';

class FormWidgets {
  static Widget buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String hintText,
    required String labelText,
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

  static Widget buildLocationPickerCard({
    required BuildContext context,
    required String title,
    required String locationText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              color: FlutterFlowTheme.of(context).primary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: FlutterFlowTheme.of(context).labelMedium.override(
                          fontFamily: 'Poppins',
                          color: Colors.black54,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    locationText,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Poppins',
                          color: locationText.contains("Search") ||
                                  locationText.contains("Loading")
                              ? Colors.black38
                              : Colors.black87,
                          fontSize: 15.0,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildSameAsMeOption({
    required BuildContext context,
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (newValue) {
              onChanged(newValue!);
            },
            activeColor: FlutterFlowTheme.of(context).primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    color: Colors.black87,
                    fontSize: 14.0,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildSameAsLocationMeOption({
    required BuildContext context,
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return buildSameAsMeOption(
        context: context, label: label, value: value, onChanged: onChanged);
  }

  static Widget buildDropdown<T>({
    required BuildContext context,
    required T value,
    required List<T> items,
    required Function(T?) onChanged,
    required String labelText,
    required IconData prefixIcon,
    required String Function(T) itemText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                fontFamily: 'Poppins',
                color: Colors.black54,
                fontSize: 14.0,
              ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: FlutterFlowTheme.of(context).primary, width: 2.0),
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          prefixIcon: Icon(prefixIcon, color: Colors.grey.shade600),
        ),
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'Poppins',
              color: Colors.black87,
              fontSize: 15.0,
            ),
        dropdownColor: Colors.white,
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(itemText(item)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  static Widget buildPaymentOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required PaymentMethod value,
    required PaymentMethod groupValue,
    required Function(PaymentMethod?) onChanged,
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
            Radio<PaymentMethod>(
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

  static Widget buildToggleSwitch({
    required BuildContext context,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile.adaptive(
      title: Text(
        title,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'Poppins',
              color: Colors.black87,
              fontSize: 15.0,
              fontWeight: FontWeight.w500,
            ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.white,
      activeTrackColor: FlutterFlowTheme.of(context).primary,
      inactiveThumbColor: Colors.grey.shade400,
      inactiveTrackColor: Colors.grey.shade300,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      dense: true,
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
                  fontSize: 16.0,
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
