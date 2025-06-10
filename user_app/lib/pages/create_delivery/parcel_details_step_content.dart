import 'package:flutter/material.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_user/pages/create_delivery/form_widgets.dart';
import 'package:langas_user/util/apps_enums.dart';

class ParcelDetailsStepContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController parcelDescriptionController;
  final Sensitivity selectedSensitivity;
  final VehicleType selectedVehicleType;
  final Function(Sensitivity?) onSensitivityChanged;
  final Function(VehicleType?) onVehicleChanged;

  const ParcelDetailsStepContent({
    Key? key,
    required this.formKey,
    required this.parcelDescriptionController,
    required this.selectedSensitivity,
    required this.selectedVehicleType,
    required this.onSensitivityChanged,
    required this.onVehicleChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Please provide details about your parcel",
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    color: Colors.black54,
                    fontSize: 14.0,
                  ),
            ),
            const SizedBox(height: 20),
            FormWidgets.buildTextField(
              context: context,
              controller: parcelDescriptionController,
              labelText: 'Parcel Description',
              hintText: 'Deacribe your parcel in detail',
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Please enter parcel description";
                }
                return null;
              },
            ),
            FormWidgets.buildDropdown<Sensitivity>(
              context: context,
              value: selectedSensitivity,
              items: Sensitivity.values,
              onChanged: onSensitivityChanged,
              labelText: 'Sensitivity',
              prefixIcon: Icons.shield_outlined,
              itemText: (Sensitivity s) => s.name,
            ),
            const SizedBox(height: 16),
            FormWidgets.buildDropdown<VehicleType>(
              context: context,
              value: selectedVehicleType,
              items: VehicleType.values,
              onChanged: onVehicleChanged,
              labelText: 'Vehicle Type Needed',
              prefixIcon: Icons.delivery_dining,
              itemText: (VehicleType v) => v.name,
            ),
          ],
        ),
      ),
    );
  }
}
