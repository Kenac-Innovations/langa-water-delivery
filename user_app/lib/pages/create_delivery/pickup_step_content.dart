import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:langas_user/pages/create_delivery/form_widgets.dart';
import 'package:langas_user/pages/create_delivery/location_picker_page.dart';

class PickupStepContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController pickupContactNameController;
  final TextEditingController pickupPhoneController;
  final TextEditingController deliveryDateController;
  final TextEditingController deliveryTimeController;
  final String pickUpLocationText;
  final LatLng? pickupLatLng; // Need current LatLng to pass as initial center
  final bool isPickupSameAsMe;
  final bool isPickupLocationSameAsMe;
  final bool isImmediateDelivery;
  final String googleApikey;
  final Function(String, LatLng) onPickupLocationChanged;
  final Function(bool) onSameAsMeChanged;
  final Function(bool) onSameAsMeLocationChanged;
  final Function(bool) onDeliveryTypeChanged;
  final VoidCallback pickDate;
  final VoidCallback pickTime;

  const PickupStepContent({
    Key? key,
    required this.formKey,
    required this.pickupContactNameController,
    required this.pickupPhoneController,
    required this.deliveryDateController,
    required this.deliveryTimeController,
    required this.pickUpLocationText,
    this.pickupLatLng, // Make LatLng available
    required this.isPickupSameAsMe,
    required this.isPickupLocationSameAsMe,
    required this.isImmediateDelivery,
    required this.googleApikey,
    required this.onPickupLocationChanged,
    required this.onSameAsMeChanged,
    required this.onSameAsMeLocationChanged,
    required this.onDeliveryTypeChanged,
    required this.pickDate,
    required this.pickTime,
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
            FormWidgets.buildDeliveryTypeToggle(
              context: context,
              isImmediate: isImmediateDelivery,
              onChanged: onDeliveryTypeChanged,
            ),
            if (!isImmediateDelivery) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FormWidgets.buildTextField(
                      context: context,
                      controller: deliveryDateController,
                      hintText: 'Date',
                      labelText: 'Date',
                      readOnly: true,
                      onTap: pickDate,
                      validator: (value) {
                        if (!isImmediateDelivery &&
                            (value == null || value.trim().isEmpty)) {
                          return "Select delivery date";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FormWidgets.buildTextField(
                      context: context,
                      controller: deliveryTimeController,
                      hintText: 'Time',
                      labelText: 'Time',
                      readOnly: true,
                      onTap: pickTime,
                      validator: (value) {
                        if (!isImmediateDelivery &&
                            (value == null || value.trim().isEmpty)) {
                          return "Select delivery time";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            FormWidgets.buildSameAsLocationMeOption(
              context: context,
              label: "Use my current location for pickup",
              value: isPickupLocationSameAsMe,
              onChanged: onSameAsMeLocationChanged,
            ),
            if (!isPickupLocationSameAsMe)
              FormWidgets.buildLocationPickerCard(
                context: context,
                title: "PICKUP LOCATION",
                locationText: pickUpLocationText,
                onTap: () async {
                  final result = await Navigator.push<LocationResult>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LocationPickerPage(
                        initialCenter: pickupLatLng,
                      ),
                    ),
                  );
                  if (result != null) {
                    onPickupLocationChanged(result.address, result.coordinates);
                  }
                },
              ),
            FormWidgets.buildSameAsMeOption(
              context: context,
              label: "Use my contact details for pickup",
              value: isPickupSameAsMe,
              onChanged: onSameAsMeChanged,
            ),
            if (!isPickupSameAsMe) ...[
              FormWidgets.buildTextField(
                context: context,
                controller: pickupContactNameController,
                labelText: 'Pickup Contact Name',
                hintText: 'Contact Name',
                prefixIcon:
                    Icon(Icons.person_outline, color: Colors.grey.shade600),
                validator: (value) {
                  if (!isPickupSameAsMe &&
                      (value == null || value.trim().isEmpty)) {
                    return "Enter pickup contact name";
                  }
                  return null;
                },
              ),
              FormWidgets.buildTextField(
                context: context,
                controller: pickupPhoneController,
                labelText: 'Pickup Contact Phone',
                hintText: '+2637123456789',
                prefixIcon:
                    Icon(Icons.phone_outlined, color: Colors.grey.shade600),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (!isPickupSameAsMe &&
                      (value == null || value.trim().isEmpty)) {
                    return "Enter pickup phone number";
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
