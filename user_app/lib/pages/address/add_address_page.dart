import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_user/pages/create_delivery/location_picker_page.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _addressController = TextEditingController();
  LatLng? _selectedLatLng;

  @override
  void dispose() {
    _nicknameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickLocationFromMap() async {
    final result = await Navigator.push<LocationResult>(
      context,
      MaterialPageRoute(builder: (context) => const LocationPickerPage()),
    );

    if (result != null && mounted) {
      setState(() {
        _addressController.text = result.address;
        _selectedLatLng = result.coordinates;
      });
    }
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      Fluttertoast.showToast(
        msg: "Address Saved Successfully!",
        backgroundColor: Colors.green,
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: theme.primary,
        elevation: 1,
        foregroundColor: Colors.white,
        title: const Text('Add New Address',
            style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nicknameController,
                decoration:
                    _buildInputDecoration(label: 'Nickname (e.g., Home)'),
                validator: (v) => v!.isEmpty ? 'Please enter a nickname' : null,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _addressController,
                decoration: _buildInputDecoration(label: 'Full Street Address'),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Please enter an address' : null,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickLocationFromMap,
                icon: const Icon(Icons.map_outlined),
                label: const Text('Pick location from Map'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  foregroundColor: theme.primaryText,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _saveAddress,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  backgroundColor: theme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Address',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String label}) {
    return InputDecoration(
      labelText: label,
      alignLabelWithHint: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
