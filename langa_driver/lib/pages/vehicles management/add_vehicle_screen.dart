import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:langas_driver/bloc/auth/auth_bloc/auth_bloc_bloc.dart';
import 'package:langas_driver/bloc/auth/auth_bloc/auth_bloc_state.dart';
import 'package:langas_driver/bloc/vehicles/vehicle_management/vehicle_management_bloc_bloc.dart';
import 'package:langas_driver/bloc/vehicles/vehicle_management/vehicle_management_bloc_event.dart';
import 'package:langas_driver/bloc/vehicles/vehicle_management/vehicle_management_bloc_state.dart';
import 'package:langas_driver/dto/vehicle_dto.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_driver/nav/nav.dart';
import 'package:langas_driver/utils/delivery_enums.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();
  final _makeController = TextEditingController();
  final _plateController = TextEditingController();

  VehicleType _selectedVehicleType = VehicleType.CAR;
  bool _isLoading = false;
  String? _driverId;

  // New state variables for image files
  File? _registrationBookFile;
  File? _frontImageFile;
  File? _backImageFile;
  File? _sideImageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthDriverAuthenticated) {
      _driverId = authState.authData.driverProfile?.id.toString();
    }
  }

  @override
  void dispose() {
    _modelController.dispose();
    _colorController.dispose();
    _makeController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(
      ImageSource source, Function(File) onImagePicked) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        onImagePicked(File(pickedFile.path));
      });
    }
  }

  Widget _buildImagePicker(
      String label, File? imageFile, Function(File) onImagePicked) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.bodyMedium),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
                context: context,
                builder: (BuildContext bc) {
                  return SafeArea(
                    child: Wrap(
                      children: <Widget>[
                        ListTile(
                            leading: const Icon(Icons.photo_library),
                            title: const Text('Gallery'),
                            onTap: () {
                              _pickImage(ImageSource.gallery, onImagePicked);
                              Navigator.of(context).pop();
                            }),
                        ListTile(
                          leading: const Icon(Icons.photo_camera),
                          title: const Text('Camera'),
                          onTap: () {
                            _pickImage(ImageSource.camera, onImagePicked);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  );
                });
          },
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.primaryBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.alternate, width: 1),
            ),
            child: imageFile != null
                ? Image.file(imageFile, fit: BoxFit.cover)
                : Icon(Icons.add_a_photo, color: theme.secondaryText, size: 50),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _submitAddVehicle() {
    if (_driverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error: Driver ID not found.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final request = CreateVehicleRequest(
        vehicleModel: _modelController.text.trim(),
        vehicleColor: _colorController.text.trim(),
        vehicleMake: _makeController.text.trim(),
        licensePlateNo: _plateController.text.trim(),
        vehicleType: _selectedVehicleType,
        registrationBookFile: _registrationBookFile,
        frontImageFile: _frontImageFile,
        backImageFile: _backImageFile,
        sideImageFile: _sideImageFile,
      );

      context
          .read<VehicleManagementBloc>()
          .add(AddVehicle(driverId: _driverId!, request: request));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primary,
        title: Text(
          'Add New Vehicle',
          style: theme.headlineMedium.override(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: theme.secondaryBackground,
      body: BlocListener<VehicleManagementBloc, VehicleManagementState>(
        listener: (context, state) {
          if (state is VehicleLoading || state is VehicleActionInProgress) {
            if (mounted) setState(() => _isLoading = true);
          } else if (state is VehicleCreateSuccess) {
            if (mounted) setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('Vehicle added successfully! Awaiting approval.'),
                  backgroundColor: Colors.green),
            );
            context.pop();
          } else if (state is VehicleActionFailure) {
            if (mounted) setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('Failed to add vehicle: ${state.failure.message}'),
                  backgroundColor: Colors.red),
            );
          } else {
            if (mounted && _isLoading) {
              setState(() => _isLoading = false);
            }
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _makeController,
                  decoration: _buildInputDecoration(context,
                      label: 'Vehicle Make', hint: 'e.g., Toyota'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter vehicle make'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _modelController,
                  decoration: _buildInputDecoration(context,
                      label: 'Vehicle Model', hint: 'e.g., Corolla'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter vehicle model'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _colorController,
                  decoration: _buildInputDecoration(context,
                      label: 'Vehicle Color', hint: 'e.g., White'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter vehicle color'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _plateController,
                  decoration: _buildInputDecoration(context,
                      label: 'License Plate No.', hint: 'e.g., ABC123'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter license plate'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<VehicleType>(
                  value: _selectedVehicleType,
                  items: VehicleType.values.map((VehicleType type) {
                    return DropdownMenuItem<VehicleType>(
                      value: type,
                      child: Text(type.name,
                          style: const TextStyle(fontFamily: 'Poppins')),
                    );
                  }).toList(),
                  onChanged: (VehicleType? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedVehicleType = newValue;
                      });
                    }
                  },
                  decoration:
                      _buildInputDecoration(context, label: 'Vehicle Type'),
                  validator: (value) =>
                      value == null ? 'Please select vehicle type' : null,
                ),
                const SizedBox(height: 24),
                _buildImagePicker('Registration Book', _registrationBookFile,
                    (file) {
                  setState(() => _registrationBookFile = file);
                }),
                _buildImagePicker('Front Image', _frontImageFile, (file) {
                  setState(() => _frontImageFile = file);
                }),
                _buildImagePicker('Back Image', _backImageFile, (file) {
                  setState(() => _backImageFile = file);
                }),
                _buildImagePicker('Side Image', _sideImageFile, (file) {
                  setState(() => _sideImageFile = file);
                }),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitAddVehicle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 3, color: Colors.white))
                      : const Text('Add Vehicle',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(BuildContext context,
      {required String label, String? hint, IconData? icon}) {
    final theme = FlutterFlowTheme.of(context);
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(fontFamily: 'Poppins'),
      hintStyle: const TextStyle(fontFamily: 'Poppins', color: Colors.grey),
      prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.primary)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.error)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.error)),
      filled: true,
      fillColor: theme.secondaryBackground,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
    );
  }
}
