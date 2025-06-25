import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_bloc.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_state.dart';
import 'package:langas_user/bloc/client_address/client_address_bloc.dart';
import 'package:langas_user/bloc/client_address/client_address_event.dart';
import 'package:langas_user/bloc/client_address/client_address_state.dart';
import 'package:langas_user/dto/client_address_dto.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:langas_user/pages/create_water_order/location_picker_page.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _addressController = TextEditingController();
  String _pickedAddressFormatted = '';
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
        _pickedAddressFormatted = result.address;
        _addressController.text = result.address.split(',').first;
        _selectedLatLng = result.coordinates;
      });
    }
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      if (_selectedLatLng == null) {
        Fluttertoast.showToast(
            msg: "Please pick a location from the map.",
            backgroundColor: Colors.red);
        return;
      }

      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        const String defaultGeohash = "default_geohash";
        final dto = CreateClientAddressDto(
          clientId: authState.user.userId,
          title: _nicknameController.text,
          addressEntered: _addressController.text,
          latitude: _selectedLatLng!.latitude,
          longitude: _selectedLatLng!.longitude,
          addressFormatted: _pickedAddressFormatted,
          geohash: defaultGeohash,
        );
        context.read<ClientAddressBloc>().add(CreateClientAddress(dto));
      } else {
        Fluttertoast.showToast(
            msg: "You must be logged in to save an address.",
            backgroundColor: Colors.red);
      }
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
      body: BlocConsumer<ClientAddressBloc, ClientAddressState>(
        listener: (context, state) {
          if (state is ClientAddressOperationSuccess) {
            Fluttertoast.showToast(
                msg: state.message, backgroundColor: Colors.green);
            Navigator.of(context).pop(true);
          }
          if (state is ClientAddressFailure) {
            Fluttertoast.showToast(
                msg: state.failure.message, backgroundColor: Colors.red);
          }
        },
        builder: (context, state) {
          final isLoading = state is ClientAddressLoading;

          return SingleChildScrollView(
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
                    validator: (v) =>
                        v!.isEmpty ? 'Please enter a nickname' : null,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _addressController,
                    decoration: _buildInputDecoration(
                        label: 'House Number & Street Name'),
                    maxLines: 2,
                    validator: (v) =>
                        v!.isEmpty ? 'Please enter address details' : null,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _pickLocationFromMap,
                    icon: Icon(
                        _selectedLatLng != null
                            ? Icons.check_circle
                            : Icons.map_outlined,
                        color: _selectedLatLng != null ? Colors.green : null),
                    label: Text(_selectedLatLng != null
                        ? 'Location Picked!'
                        : 'Pick location on Map'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      foregroundColor: theme.primaryText,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  if (_pickedAddressFormatted.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child:
                          Text(_pickedAddressFormatted, style: theme.bodySmall),
                    ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: isLoading ? null : _saveAddress,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      backgroundColor: theme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child:
                                CircularProgressIndicator(color: Colors.white))
                        : const Text('Save Address',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String label}) {
    return InputDecoration(
      labelText: label,
      focusColor: FlutterFlowTheme.of(context).primary,
      fillColor: FlutterFlowTheme.of(context).primary,
      alignLabelWithHint: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
