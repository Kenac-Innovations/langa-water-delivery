import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_user/models/user_model.dart';

import 'package:langas_user/pages/create_water_order/create_water_order_page.dart';
import 'package:langas_user/pages/create_water_order/form_widgets.dart';
import 'package:langas_user/pages/create_water_order/location_picker_page.dart';

class DeliveryCard extends StatefulWidget {
  final DeliveryModel delivery;
  final int index;
  final bool showRemoveButton;
  final VoidCallback onRemove;
  final Function(LatLng?, String) onLocationUpdate;
  final User? currentUser;

  const DeliveryCard({
    super.key,
    required this.delivery,
    required this.index,
    required this.showRemoveButton,
    required this.onRemove,
    required this.onLocationUpdate,
    this.currentUser,
  });

  @override
  _DeliveryCardState createState() => _DeliveryCardState();
}

class _DeliveryCardState extends State<DeliveryCard> {
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null && mounted) {
      setState(() {
        widget.delivery.dateController.text =
            DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickTime() async {
    final picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null && mounted) {
      setState(() {
        final timeFormat = DateFormat("HH:mm:00");
        final now = DateTime.now();
        final dt =
            DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
        widget.delivery.timeController.text = timeFormat.format(dt);
      });
    }
  }

  void _handleUseMyDetails(bool? value) {
    setState(() {
      widget.delivery.useMyDetails = value ?? false;
      if (widget.delivery.useMyDetails && widget.currentUser != null) {
        widget.delivery.contactNameController.text =
            '${widget.currentUser!.firstName} ${widget.currentUser!.lastName}';
        widget.delivery.contactPhoneController.text =
            widget.currentUser!.phoneNumber;
      } else {
        widget.delivery.contactNameController.clear();
        widget.delivery.contactPhoneController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Delivery #${widget.index + 1}',
                    style: theme.titleMedium.override(fontFamily: 'Poppins')),
                if (widget.showRemoveButton)
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: theme.error),
                    onPressed: widget.onRemove,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  )
              ],
            ),
            const Divider(height: 24),
            FormWidgets.buildTextField(
              context: context,
              controller: widget.delivery.manualAddressController,
              labelText: 'Address Details (Required)',
              hintText: 'e.g., House 123, Main Street',
              maxLines: 2,
            ),
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push<LocationResult>(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LocationPickerPage(
                          initialCenter: widget.delivery.latLng)),
                );
                if (result != null) {
                  widget.onLocationUpdate(result.coordinates, result.address);
                }
              },
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300)),
                child: Row(
                  children: [
                    Icon(
                      Icons.pin_drop_outlined,
                      color: theme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.delivery.pickedAddressDisplay,
                        style: TextStyle(
                          color: widget.delivery.latLng == null
                              ? theme.secondaryText
                              : theme.primaryText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.delivery.latLng != null)
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 20),
                  ],
                ),
              ),
            ),
            if (widget.delivery.latLng == null)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Disclaimer: Without a map pin, we cannot determine if your address is in our service area.',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ),
            const SizedBox(height: 16),
            if (widget.currentUser != null)
              CheckboxListTile(
                title: const Text("Use my details for this delivery"),
                value: widget.delivery.useMyDetails,
                onChanged: _handleUseMyDetails,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: theme.primary,
              ),
            FormWidgets.buildTextField(
              context: context,
              controller: widget.delivery.contactNameController,
              labelText: 'Contact Name',
              hintText: 'e.g., John Moyo',
            ),
            FormWidgets.buildTextField(
                context: context,
                controller: widget.delivery.contactPhoneController,
                labelText: 'Contact Phone',
                hintText: 'e.g., +263771234567',
                keyboardType: TextInputType.phone),
            FormWidgets.buildTextField(
                context: context,
                controller: widget.delivery.quantityController,
                labelText: 'Quantity (Litres)',
                hintText: 'e.g., 20',
                keyboardType: TextInputType.number),
            FormWidgets.buildDeliveryTypeToggle(
                context: context,
                isImmediate: !widget.delivery.isScheduled,
                onChanged: (isImmediate) {
                  setState(() => widget.delivery.isScheduled = !isImmediate);
                }),
            if (widget.delivery.isScheduled)
              Row(
                children: [
                  Expanded(
                    child: FormWidgets.buildTextField(
                      context: context,
                      controller: widget.delivery.dateController,
                      labelText: 'Date',
                      hintText: 'YYYY-MM-DD',
                      readOnly: true,
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FormWidgets.buildTextField(
                      context: context,
                      controller: widget.delivery.timeController,
                      labelText: 'Time',
                      hintText: 'HH:MM:SS',
                      readOnly: true,
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
            FormWidgets.buildTextField(
                context: context,
                maxLines: 2,
                controller: widget.delivery.instructionsController,
                labelText: 'Delivery Instructions (Optional)',
                hintText: 'e.g., Leave at the front door'),
          ],
        ),
      ),
    );
  }
}
