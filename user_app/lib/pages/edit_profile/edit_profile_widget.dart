import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditProfileWidget extends StatefulWidget {
  const EditProfileWidget({super.key});

  @override
  State<EditProfileWidget> createState() => _EditProfileWidgetState();
}

class _EditProfileWidgetState extends State<EditProfileWidget> {
  bool _isLoading = false;
  String _selectedItem = '+91'; // Initialize with default value
  final List<String> _countryCodes = ['+91', '+54', '+42', '+86'];
  File? _image;
  final _picker = ImagePicker();

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Text controllers
  final companyName = TextEditingController(text: "TakeU Logistics");
  final UnitedStates = TextEditingController(text: "United States");
  final firstName = TextEditingController(text: "John");
  final lastName = TextEditingController(text: "Smith");
  final email = TextEditingController(text: "john.smith@example.com");
  final mobileNumber = TextEditingController(text: "1234567890");
  final houseNumber = TextEditingController(text: "42");
  final streetName = TextEditingController(text: "Main Street");
  final city = TextEditingController(text: "New York");
  final state = TextEditingController(text: "NY");
  final postCode = TextEditingController(text: "10001");

  @override
  void dispose() {
    companyName.dispose();
    UnitedStates.dispose();
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    mobileNumber.dispose();
    houseNumber.dispose();
    streetName.dispose();
    city.dispose();
    state.dispose();
    postCode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isiOS) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarBrightness: Theme.of(context).brightness,
          systemStatusBarContrastEnforced: true,
        ),
      );
    }

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30.0,
          borderWidth: 1.0,
          buttonSize: 60.0,
          icon: const Icon(
            Icons.chevron_left,
            color: Colors.white,
            size: 30.0,
          ),
          onPressed: () async {
            context.pop();
          },
        ),
        title: Text(
          'EDIT PROFILE',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        top: true,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Stack(
              children: [
                // Main content
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile header with image
                      _buildProfileHeader(),

                      // Personal Info Section
                      _buildSectionHeader('Personal Info'),
                      _buildPersonalInfoSection(),

                      // Address Section
                      _buildSectionHeader('Address Details'),
                      _buildAddressSection(),

                      // Submit Button
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: FFButtonWidget(
                          onPressed: _submitForm,
                          text: 'SUBMIT',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 50.0,
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                24.0, 0.0, 24.0, 0.0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                            elevation: 2.0,
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Loading Indicator
                if (_isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        children: [
          // Profile Image (Centered)
          Center(
            child: InkWell(
              onTap: () => _showImagePicker(context),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 100.0,
                    height: 100.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50.0),
                      border: Border.all(
                        color: Colors.white,
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: _image != null
                          ? Image.file(
                              _image!,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              'https://images.unsplash.com/photo-1599566150163-29194dcaad36?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwxNHx8cGVyc29ufGVufDB8fHx8MTcwNDgzNzE0NHww&ixlib=rb-4.0.3&q=80&w=1080',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2.0,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // User Info (Centered)
          Center(
            child: Column(
              children: [
                Text(
                  'Gift Mugaragumbo',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Poppins',
                        fontSize: 22.0,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  'gift@gmail.com',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Poppins',
                        color: FlutterFlowTheme.of(context).editProfiletext,
                        fontSize: 14.0,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'Poppins',
              color: FlutterFlowTheme.of(context).editProfileSmalltext,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      children: [
        // First and Last Name Row
        Row(
          children: [
            // First Name
            Expanded(
              child: _buildTextField(
                controller: firstName,
                hintText: 'Firstname',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required!';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10),

            // Last Name
            Expanded(
              child: _buildTextField(
                controller: lastName,
                hintText: 'Lastname',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required!';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),

        // Email
        _buildTextField(
          controller: email,
          hintText: 'Email',
          readOnly: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Enter email';
            } else if (!_isValidEmail(value)) {
              return 'Enter a valid email address';
            }
            return null;
          },
        ),

        // Phone Number Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Country Code Dropdown
            Container(
              height: 56,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFEBEBEB),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  value: _selectedItem,
                  items: _countryCodes
                      .map((code) => DropdownMenuItem<String>(
                            value: code,
                            child: Text(
                              code,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.black87,
                                fontSize: 15,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedItem = value!;
                    });
                  },
                  buttonStyleData: const ButtonStyleData(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    height: 56,
                    width: 85,
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    height: 40,
                  ),
                  dropdownStyleData: DropdownStyleData(
                    width: 85,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Phone Number
            Expanded(
              child: _buildTextField(
                controller: mobileNumber,
                hintText: 'Mobile Number',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter mobile number';
                  } else if (value.length < 10) {
                    return 'Mobile number must be at least 10 digits';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(
      children: [
        // House Number
        _buildTextField(
          controller: houseNumber,
          hintText: 'Flat no.',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Enter house number';
            }
            return null;
          },
        ),

        // Street Name
        _buildTextField(
          controller: streetName,
          hintText: 'Street',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Enter street name';
            }
            return null;
          },
        ),

        // City
        _buildTextField(
          controller: city,
          hintText: 'City',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Enter city';
            }
            return null;
          },
        ),

        // State and Postcode Row
        Row(
          children: [
            // State
            Expanded(
              child: _buildTextField(
                controller: state,
                hintText: 'State',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required!';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10),

            // Postcode
            Expanded(
              child: _buildTextField(
                controller: postCode,
                hintText: 'Postcode',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required!';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),

        // Country
        _buildTextField(
          controller: UnitedStates,
          hintText: 'Country',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Enter country';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        cursorColor: FlutterFlowTheme.of(context).primary,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Poppins',
                color: Colors.black54,
                fontSize: 15.0,
                fontWeight: FontWeight.normal,
              ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color(0xFFEBEBEB),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).primary,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).error,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).error,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          filled: true,
          fillColor: const Color(0xFFEBEBEB),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        ),
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'Poppins',
              color: Colors.black87,
              fontSize: 15.0,
            ),
        validator: validator,
      ),
    );
  }

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose Profile Photo',
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 30,
              color: FlutterFlowTheme.of(context).primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });

        // Show success message
        Fluttertoast.showToast(
          msg: "Profile updated successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        // Navigate back
        Navigator.pop(context);
      });
    }
  }

  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegExp.hasMatch(email);
  }
}
