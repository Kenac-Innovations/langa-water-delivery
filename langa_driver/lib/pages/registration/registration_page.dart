import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart' as intl_phone;
import 'package:langas_driver/bloc/auth/driver_registration_bloc/driver_registration_bloc_bloc.dart';
import 'package:langas_driver/bloc/auth/driver_registration_bloc/driver_registration_bloc_event.dart';
import 'package:langas_driver/bloc/auth/driver_registration_bloc/driver_registration_bloc_state.dart';
import 'package:langas_driver/dto/auth_dto.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_driver/nav/nav.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DriverRegistrationScreen extends StatefulWidget {
  const DriverRegistrationScreen({super.key});

  @override
  _DriverRegistrationScreenState createState() =>
      _DriverRegistrationScreenState();
}

class _DriverRegistrationScreenState extends State<DriverRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _nationalIdController = TextEditingController();

  final _imagePicker = ImagePicker();
  File? _profileImage;
  File? _idImage;
  File? _licenseImage;

  String? _fullPhoneNumber;
  String _selectedGender = 'Male';
  final List<String> _genders = ['Male', 'Female'];
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _termsAccepted = false;
  final _unfocusNode = FocusNode();
  int _currentStep = 0;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _nationalIdController.dispose();
    _unfocusNode.dispose();
    super.dispose();
  }

  Future<File?> _compressImage(File file, int targetSizeKB,
      {int quality = 85, bool isProfile = false}) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetFileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final targetPath = '${tempDir.path}/$targetFileName';

      XFile? result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        format: CompressFormat.jpeg,
      );

      if (result == null) return null;

      File compressedFile = File(result.path);
      int fileSizeKB = await compressedFile.length() ~/ 1024;

      if (fileSizeKB > targetSizeKB && quality > 10 && !isProfile) {
        return _compressImage(compressedFile, targetSizeKB,
            quality: quality - 10);
      } else if (isProfile && fileSizeKB > targetSizeKB && quality > 10) {
        return _compressImage(compressedFile, targetSizeKB,
            quality: quality - 5);
      }
      return compressedFile;
    } catch (e) {
      Fluttertoast.showToast(msg: "Error compressing image: $e");
      return file;
    }
  }

  Future<void> _pickImage(ImageSource source, int imageType) async {
    final pickedFile = await _imagePicker.pickImage(
      source: source,
    );

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      File? compressedImage;

      int targetSizeKB = imageType == 0 ? 200 : 2048;
      bool isProfileImage = imageType == 0;

      setState(() => _isLoading = true);
      compressedImage = await _compressImage(imageFile, targetSizeKB,
          isProfile: isProfileImage);
      setState(() => _isLoading = false);

      if (compressedImage != null) {
        int finalSize = await compressedImage.length();
        print(
            "Compressed image size: ${finalSize / 1024} KB for type $imageType");
      }

      setState(() {
        switch (imageType) {
          case 0:
            _profileImage = compressedImage ?? imageFile;
            break;
          case 1:
            _idImage = compressedImage ?? imageFile;
            break;
          case 2:
            _licenseImage = compressedImage ?? imageFile;
            break;
        }
      });
    }
  }

  void _showImagePickerModal(int imageType) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Choose Image Source",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    icon: Icons.photo_library,
                    label: "Gallery",
                    onTap: () {
                      _pickImage(ImageSource.gallery, imageType);
                      Navigator.pop(context);
                    },
                  ),
                  _buildImageSourceOption(
                    icon: Icons.camera_alt,
                    label: "Camera",
                    onTap: () {
                      _pickImage(ImageSource.camera, imageType);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: FlutterFlowTheme.of(context).primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profile Photo',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: GestureDetector(
            onTap: () => _showImagePickerModal(0),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
                image: _profileImage != null
                    ? DecorationImage(
                        image: FileImage(_profileImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: _profileImage == null
                  ? Icon(
                      Icons.add_a_photo,
                      size: 40,
                      color: FlutterFlowTheme.of(context).primary,
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Center(
          child: TextButton(
            onPressed: () => _showImagePickerModal(0),
            child: Text(
              _profileImage == null ? 'Add Photo' : 'Change Photo',
              style: TextStyle(
                color: FlutterFlowTheme.of(context).primary,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentImageSelector(
      String title, String description, int imageType, File? currentImage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _showImagePickerModal(imageType),
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade300,
              ),
              image: currentImage != null
                  ? DecorationImage(
                      image: FileImage(currentImage),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: currentImage == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 50,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tap to upload',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : null,
          ),
        ),
      ],
    );
  }

  void _submitRegistration() {
    if (_formKey.currentState!.validate()) {
      if (_idImage == null || _licenseImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please upload National ID and Driver\'s License'),
              backgroundColor: Colors.red),
        );
        if (_currentStep != 1) {
          setState(() {
            _currentStep = 1;
          });
        }
        return;
      }

      if (_profileImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please upload a Profile Photo'),
              backgroundColor: Colors.red),
        );
        if (_currentStep != 2) {
          setState(() {
            _currentStep = 2;
          });
        }
        return;
      }

      if (!_termsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please accept terms and conditions'),
              backgroundColor: Colors.red),
        );
        if (_currentStep != 2) {
          setState(() {
            _currentStep = 2;
          });
        }
        return;
      }

      if (_fullPhoneNumber == null || _fullPhoneNumber!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please enter a valid phone number'),
              backgroundColor: Colors.red),
        );
        if (_currentStep != 0) {
          setState(() {
            _currentStep = 0;
          });
        }
        return;
      }

      final registrationDto = DriverRegistrationRequest(
          phoneNumber: _fullPhoneNumber!,
          email: _emailController.text.trim(),
          firstname: _firstNameController.text.trim(),
          lastname: _lastNameController.text.trim(),
          password: _passwordController.text,
          gender: _selectedGender,
          address: _addressController.text.trim(),
          nationalIdNumber: _nationalIdController.text.trim(),
          profilePhoto: _profileImage,
          nationalIdImage: _idImage,
          driversLicenseImage: _licenseImage);

      context
          .read<DriverRegistrationBloc>()
          .add(RegisterDriverSubmitted(request: registrationDto));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fix the errors in the form'),
            backgroundColor: Colors.red),
      );
    }
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text(
          'Personal Information',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        content: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration:
                        _buildInputDecoration(context, label: 'First Name'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration:
                        _buildInputDecoration(context, label: 'Last Name'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _buildInputDecoration(context,
                  label: 'Email', icon: Icons.email_outlined),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) return 'Please enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 20),
            IntlPhoneField(
              controller: _phoneController,
              decoration: _buildInputDecoration(context, label: 'Phone Number')
                  .copyWith(counterText: ''),
              initialCountryCode: 'ZW',
              keyboardType: TextInputType.phone,
              onChanged: (intl_phone.PhoneNumber phone) {
                setState(() {
                  _fullPhoneNumber = phone.completeNumber;
                });
              },
              validator: (intl_phone.PhoneNumber? phone) {
                if (phone == null || phone.number.isEmpty) {
                  return 'Please enter phone number';
                }
                return null;
              },
              dropdownTextStyle:
                  const TextStyle(fontFamily: 'Poppins', fontSize: 16),
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 16),
              flagsButtonPadding: const EdgeInsets.only(left: 12),
              dropdownIconPosition: IconPosition.trailing,
              dropdownIcon:
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nationalIdController,
              decoration: _buildInputDecoration(context,
                  label: 'National ID Number', icon: Icons.badge_outlined),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: _buildInputDecoration(context,
                  label: 'Gender', icon: Icons.person_outline),
              items: _genders
                  .map((gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(gender,
                            style: const TextStyle(fontFamily: 'Poppins')),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedGender = value;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _addressController,
              maxLines: 3,
              decoration: _buildInputDecoration(context,
                  label: 'Address',
                  icon: Icons.location_on_outlined,
                  alignLabel: true),
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter your address'
                  : null,
            ),
          ],
        ),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text(
          'Verification Documents',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),
        ),
        content: Column(
          children: [
            _buildDocumentImageSelector('National ID',
                'Upload a clear image of your national ID', 1, _idImage),
            const SizedBox(height: 24),
            _buildDocumentImageSelector(
                'Driver\'s License',
                'Upload a clear image of your driver\'s license',
                2,
                _licenseImage),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade100)),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                        'All documents must be valid and clearly visible.',
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontFamily: 'Poppins')),
                  ),
                ],
              ),
            ),
          ],
        ),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text(
          'Account Setup',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),
        ),
        content: Column(
          children: [
            _buildProfileImageSelector(),
            const SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: _buildInputDecoration(context,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible),
                  )),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              decoration: _buildInputDecoration(context,
                  label: 'Confirm Password',
                  icon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(_isConfirmPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () => setState(() =>
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                  )),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _termsAccepted,
                    onChanged: (value) =>
                        setState(() => _termsAccepted = value ?? false),
                    activeColor: FlutterFlowTheme.of(context).primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: Colors.grey),
                      children: [
                        const TextSpan(text: "I agree to the "),
                        TextSpan(
                            text: "Terms & Conditions",
                            style: TextStyle(
                                color: FlutterFlowTheme.of(context).primary,
                                fontWeight: FontWeight.w600)),
                        const TextSpan(text: " and "),
                        TextSpan(
                            text: "Privacy Policy",
                            style: TextStyle(
                                color: FlutterFlowTheme.of(context).primary,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      ),
    ];
  }

  InputDecoration _buildInputDecoration(BuildContext context,
      {required String label,
      IconData? icon,
      Widget? suffixIcon,
      bool alignLabel = false}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontFamily: 'Poppins'),
      prefixIcon: icon != null ? Icon(icon) : null,
      suffixIcon: suffixIcon,
      alignLabelWithHint: alignLabel,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: FlutterFlowTheme.of(context).primary)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Driver Registration',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: BlocListener<DriverRegistrationBloc, DriverRegistrationState>(
            listener: (context, state) {
              if (state is RegistrationLoading) {
                setState(() {
                  _isLoading = true;
                });
              } else if (state is RegistrationSuccess) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Registration successful! Please verify your account.'),
                        backgroundColor: Colors.green),
                  );
                  context.push('/otpScreen', extra: {
                    'email': state.responseData.email,
                    'phone': state.responseData.phoneNumber,
                  });
                }
              } else if (state is RegistrationFailure) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(state.failure.message),
                        backgroundColor: Colors.red),
                  );
                }
              } else {
                if (mounted && _isLoading) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            },
            child: Stack(
              children: [
                Form(
                  key: _formKey,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: FlutterFlowTheme.of(context).primary,
                        onPrimary: Colors.white,
                        background: Colors.white,
                        surface: Colors.white,
                        onSurface: Colors.grey.shade700,
                      ),
                      canvasColor: Colors.white,
                      scaffoldBackgroundColor: Colors.white,
                    ),
                    child: Stepper(
                      type: StepperType.vertical,
                      physics: const ClampingScrollPhysics(),
                      currentStep: _currentStep,
                      onStepContinue: () {
                        bool isLastStep =
                            _currentStep == _buildSteps().length - 1;
                        if (isLastStep) {
                          _submitRegistration();
                        } else {
                          setState(() {
                            _currentStep += 1;
                          });
                        }
                      },
                      onStepCancel: () {
                        if (_currentStep > 0) {
                          setState(() {
                            _currentStep -= 1;
                          });
                        }
                      },
                      onStepTapped: (step) =>
                          setState(() => _currentStep = step),
                      steps: _buildSteps(),
                      controlsBuilder: (context, details) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              if (_currentStep > 0)
                                Expanded(
                                  child: TextButton(
                                    onPressed: details.onStepCancel,
                                    child: const Text(
                                      'Back',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                ),
                              if (_currentStep == 0) const Spacer(),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: details.onStepContinue,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        FlutterFlowTheme.of(context).primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    _currentStep == _buildSteps().length - 1
                                        ? 'Submit'
                                        : 'Next',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (_isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
}
