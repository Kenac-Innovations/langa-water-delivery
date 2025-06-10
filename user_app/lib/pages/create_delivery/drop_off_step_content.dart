import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:langas_user/pages/create_delivery/form_widgets.dart';
import 'package:langas_user/pages/create_delivery/location_picker_page.dart';

class DropOffStepContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController dropOffContactNameController;
  final TextEditingController dropOffPhoneController;
  final TextEditingController instructionsController;
  final String dropOffLocationText;
  final LatLng? dropOffLatLng; // Need current LatLng to pass as initial center
  final String googleApikey;
  final Function(String, LatLng) onDropOffLocationChanged;

  const DropOffStepContent({
    super.key,
    required this.formKey,
    required this.dropOffContactNameController,
    required this.dropOffPhoneController,
    required this.instructionsController,
    required this.dropOffLocationText,
    this.dropOffLatLng, // Make LatLng available
    required this.googleApikey,
    required this.onDropOffLocationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormWidgets.buildLocationPickerCard(
              context: context,
              title: "DROP-OFF LOCATION",
              locationText: dropOffLocationText,
              onTap: () async {
                final result = await Navigator.push<LocationResult>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocationPickerPage(
                      initialCenter: dropOffLatLng,
                    ),
                  ),
                );
                if (result != null) {
                  onDropOffLocationChanged(result.address, result.coordinates);
                }
              },
            ),
            FormWidgets.buildTextField(
              context: context,
              controller: dropOffContactNameController,
              labelText: 'Drop Off Contact Name',
              hintText: 'Contact Name',
              prefixIcon:
                  Icon(Icons.person_outline, color: Colors.grey.shade600),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Enter drop off contact name";
                }
                return null;
              },
            ),
            FormWidgets.buildTextField(
              context: context,
              controller: dropOffPhoneController,
              labelText: 'Drop Off Contact Phone',
              hintText: '+2637123456789',
              prefixIcon:
                  Icon(Icons.phone_outlined, color: Colors.grey.shade600),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Enter drop off phone number";
                }
                return null;
              },
            ),
            FormWidgets.buildTextField(
              context: context,
              controller: instructionsController,
              hintText: 'Delivery Instructions (Optional)',
              labelText: 'Delivery Instructions',
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
