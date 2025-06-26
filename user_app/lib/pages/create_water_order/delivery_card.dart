import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_user/models/user_model.dart';
import 'package:langas_user/pages/create_water_order/create_water_order_page.dart';
import 'package:langas_user/pages/create_water_order/form_widgets.dart';
import 'package:langas_user/pages/create_water_order/location_picker_page.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static const separator = ',';

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String a = newValue.text.replaceAll(separator, '');
    var formatter = NumberFormat('###,###,###,###');
    String newText = formatter.format(int.parse(a));

    return newValue.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length));
  }
}

class DeliveryCard extends StatefulWidget {
  final DeliveryModel delivery;
  final int index;
  final bool showRemoveButton;
  final VoidCallback onRemove;
  final Function(LatLng?, String) onLocationUpdate;
  final User? currentUser;
  final Function(bool isImmediate) onDeliveryTypeChange;

  const DeliveryCard({
    super.key,
    required this.delivery,
    required this.index,
    required this.showRemoveButton,
    required this.onRemove,
    required this.onLocationUpdate,
    required this.currentUser,
    required this.onDeliveryTypeChange,
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
    final now = DateTime.now();
    DateTime selectedDate;
    try {
      selectedDate =
          DateFormat('yyyy-MM-dd').parse(widget.delivery.dateController.text);
    } catch (e) {
      selectedDate = now; // Default to now if parsing fails
    }

    TimeOfDay initialTime =
        TimeOfDay.fromDateTime(now.add(const Duration(hours: 2)));

    // If selected date is today, ensure initial time is in the future
    if (selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day) {
      if (now.hour + 2 > 23) {
        // Cannot select a time today, handle this case if necessary
      }
    }

    final picked =
        await showTimePicker(context: context, initialTime: initialTime);
    if (picked != null && mounted) {
      final selectedDateTime = DateTime(selectedDate.year, selectedDate.month,
          selectedDate.day, picked.hour, picked.minute);
      final twoHoursFromNow = now.add(const Duration(hours: 2));

      // Validate time if the selected date is today
      if (selectedDateTime.isBefore(twoHoursFromNow) &&
          selectedDate
              .isAtSameMomentAs(DateTime(now.year, now.month, now.day))) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Scheduled time must be at least 2 hours from now."),
          backgroundColor: Colors.orange,
        ));
        return;
      }

      final timeFormat = DateFormat("HH:mm:ss");
      setState(() => widget.delivery.timeController.text =
          timeFormat.format(selectedDateTime));
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
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Disclaimer: Without a map pin, we cannot determine if your address is in our service area.',
                  style: theme.bodySmall
                      .override(color: theme.secondaryText, fontSize: 12),
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
            TextFormField(
              controller: widget.delivery.quantityController,
              decoration: FormWidgets.buildInputDecoration(context,
                  labelText: 'Quantity (Litres)',
                  hintText: 'Minimum 5,000 Litres'),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandsSeparatorInputFormatter(),
              ],
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Please enter a quantity';
                }
                final quantity = int.tryParse(val.replaceAll(',', ''));
                if (quantity == null || quantity < 5000) {
                  return 'Minimum 5,000 Litres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            FormWidgets.buildDeliveryTypeToggle(
                context: context,
                isScheduled: widget.delivery.isScheduled,
                onChanged: (isScheduled) {
                  setState(() => widget.delivery.isScheduled = isScheduled);
                  widget.onDeliveryTypeChange(!isScheduled);
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
