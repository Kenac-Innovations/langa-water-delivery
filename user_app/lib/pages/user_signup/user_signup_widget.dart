import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_user/pages/create_delivery/location_picker_page.dart';
import 'package:pinput/pinput.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  final _personalDetailsFormKey = GlobalKey<FormState>();
  final _addressFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _securityQuestionsFormKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _securityQuestion1Controller = TextEditingController();
  final _securityQuestion2Controller = TextEditingController();
  final _securityQuestion3Controller = TextEditingController();

  String? _fullPhoneNumber;
  LatLng? _selectedLatLng;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _termsAccepted = false;
  bool _isNextEnabled = false;

  Timer? _otpTimer;
  int _otpTimeLeft = 60;
  bool _canResendOtp = false;

  @override
  void initState() {
    super.initState();
    _addListeners();
  }

  void _addListeners() {
    // Add listeners to all controllers to check step validity in real-time
    _fullNameController.addListener(_updateStepValidity);
    _emailController.addListener(_updateStepValidity);
    _phoneController.addListener(_updateStepValidity);
    _otpController.addListener(_updateStepValidity);
    _addressController.addListener(_updateStepValidity);
    _passwordController.addListener(_updateStepValidity);
    _confirmPasswordController.addListener(_updateStepValidity);
    _securityQuestion1Controller.addListener(_updateStepValidity);
    _securityQuestion2Controller.addListener(_updateStepValidity);
    _securityQuestion3Controller.addListener(_updateStepValidity);
  }

  @override
  void dispose() {
    _otpTimer?.cancel();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _securityQuestion1Controller.dispose();
    _securityQuestion2Controller.dispose();
    _securityQuestion3Controller.dispose();
    super.dispose();
  }

  void _updateStepValidity() {
    bool isValid = false;
    switch (_currentStep) {
      case 0:
        isValid = _fullNameController.text.isNotEmpty &&
            _emailController.text.isNotEmpty &&
            _phoneController.text.isNotEmpty;
        break;
      case 1:
        isValid = _otpController.text.length == 6;
        break;
      case 2:
        isValid = _addressController.text.isNotEmpty && _selectedLatLng != null;
        break;
      case 3:
        isValid = _passwordController.text.length >= 6 &&
            _confirmPasswordController.text == _passwordController.text;
        break;
      case 4:
        isValid = _securityQuestion1Controller.text.isNotEmpty &&
            _securityQuestion2Controller.text.isNotEmpty &&
            _securityQuestion3Controller.text.isNotEmpty;
        break;
      case 5:
        isValid = _termsAccepted;
        break;
    }
    if (mounted && isValid != _isNextEnabled) {
      setState(() {
        _isNextEnabled = isValid;
      });
    }
  }

  void _startOtpTimer() {
    _otpTimer?.cancel();
    setState(() {
      _otpTimeLeft = 60;
      _canResendOtp = false;
    });
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_otpTimeLeft > 0) {
        setState(() => _otpTimeLeft--);
      } else {
        setState(() => _canResendOtp = true);
        timer.cancel();
      }
    });
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<LocationResult>(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationPickerPage(),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedLatLng = result.coordinates;
      });
      _updateStepValidity();
      Fluttertoast.showToast(msg: "Location coordinates captured!");
    }
  }

  void _handleSignUp() {
    if (!_termsAccepted) {
      Fluttertoast.showToast(
          msg: "Please accept the terms and conditions.",
          backgroundColor: Colors.red);
      return;
    }
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(
          msg: "Registration Successful!", backgroundColor: Colors.green);
      context.go('/homePage');
    });
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text("Personal Details"),
        content: Form(
          key: _personalDetailsFormKey,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              children: [
                TextFormField(
                  controller: _fullNameController,
                  decoration: _buildInputDecoration(label: "Full Name"),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: _buildInputDecoration(label: "Email Address"),
                  style: const TextStyle(fontSize: 16),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                IntlPhoneField(
                    controller: _phoneController,
                    decoration: _buildInputDecoration(label: "Phone Number")
                        .copyWith(counterText: ''),
                    initialCountryCode: 'ZW',
                    style: const TextStyle(fontSize: 16),
                    onChanged: (phone) {
                      _fullPhoneNumber = phone.completeNumber;
                      _updateStepValidity();
                    }),
              ],
            ),
          ),
        ),
        isActive: _currentStep >= 0,
      ),
      Step(
        title: const Text("Verify Phone"),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            children: [
              Text(
                "Enter the 6-digit code sent to\n$_fullPhoneNumber",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 30),
              Pinput(
                length: 6,
                controller: _otpController,
              ),
              const SizedBox(height: 30),
              _canResendOtp
                  ? TextButton(
                      onPressed: _startOtpTimer,
                      child: const Text("Resend OTP"))
                  : Text(
                      "Resend code in ${_otpTimeLeft}s",
                      style: const TextStyle(color: Colors.grey),
                    ),
            ],
          ),
        ),
        isActive: _currentStep >= 1,
      ),
      Step(
        title: const Text("Set Address"),
        content: Form(
          key: _addressFormKey,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: _buildInputDecoration(label: "Full Address"),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  icon: Icon(
                      _selectedLatLng != null ? Icons.check_circle : Icons.map,
                      color: _selectedLatLng != null ? Colors.green : null),
                  label: Text(_selectedLatLng != null
                      ? "Location Captured"
                      : "Capture Lat/Lng on Map"),
                  onPressed: _pickLocation,
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                ),
              ],
            ),
          ),
        ),
        isActive: _currentStep >= 2,
      ),
      Step(
        title: const Text("Create Password"),
        content: Form(
          key: _passwordFormKey,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              children: [
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  style: const TextStyle(fontSize: 16),
                  decoration: _buildInputDecoration(
                    label: "Password",
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  style: const TextStyle(fontSize: 16),
                  decoration: _buildInputDecoration(
                    label: "Confirm Password",
                    suffixIcon: IconButton(
                      icon: Icon(_isConfirmPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => setState(() =>
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        isActive: _currentStep >= 3,
      ),
      Step(
        title: const Text("Security Questions"),
        content: Form(
          key: _securityQuestionsFormKey,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              children: [
                TextFormField(
                  controller: _securityQuestion1Controller,
                  decoration: _buildInputDecoration(
                      label: "What city were you born in?"),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _securityQuestion2Controller,
                  decoration: _buildInputDecoration(
                      label: "What is your mother's maiden name?"),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _securityQuestion3Controller,
                  decoration: _buildInputDecoration(
                      label: "What was the name of your first pet?"),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        isActive: _currentStep >= 4,
      ),
      Step(
        title: const Text("Terms & Conditions"),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: CheckboxListTile(
            activeColor: FlutterFlowTheme.of(context).primary,
            checkColor: Colors.white,
            title: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 16),
                children: [
                  const TextSpan(text: "I have read and agree to the "),
                  TextSpan(
                      text: "Terms & Conditions",
                      style: TextStyle(
                          color: FlutterFlowTheme.of(context).primary,
                          fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()..onTap = () {}),
                ],
              ),
            ),
            value: _termsAccepted,
            onChanged: (val) {
              setState(() => _termsAccepted = val ?? false);
              _updateStepValidity();
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        isActive: _currentStep >= 5,
      ),
    ];
  }

  void _onStepContinue() {
    bool isFormValid = false;
    // Use form keys for validation on button press
    switch (_currentStep) {
      case 0:
        isFormValid = _personalDetailsFormKey.currentState!.validate();
        if (isFormValid) _startOtpTimer();
        break;
      case 1:
        isFormValid = _otpController.text.length == 6;
        if (!isFormValid) Fluttertoast.showToast(msg: "Invalid OTP");
        break;
      case 2:
        isFormValid =
            _addressFormKey.currentState!.validate() && _selectedLatLng != null;
        if (!isFormValid)
          Fluttertoast.showToast(
              msg: "Please enter address and capture location");
        break;
      case 3:
        isFormValid = _passwordFormKey.currentState!.validate();
        break;
      case 4:
        isFormValid = _securityQuestionsFormKey.currentState!.validate();
        break;
      case 5:
        isFormValid = _termsAccepted;
        if (isFormValid) _handleSignUp();
        break;
    }

    if (isFormValid && _currentStep < _buildSteps().length - 1) {
      setState(() {
        _currentStep++;
        _updateStepValidity(); // Check validity for the new step
      });
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _updateStepValidity(); // Check validity for the previous step
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Your Account"),
        backgroundColor: FlutterFlowTheme.of(context).primary,
        foregroundColor: Colors.white,
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
              ColorScheme.light(primary: FlutterFlowTheme.of(context).primary),
        ),
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          steps: _buildSteps(),
          onStepContinue: _onStepContinue,
          onStepCancel: _onStepCancel,
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                        child: OutlinedButton(
                      onPressed: details.onStepCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Back", style: TextStyle(fontSize: 16)),
                    )),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isNextEnabled ? details.onStepContinue : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FlutterFlowTheme.of(context).primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child:
                          _isLoading && _currentStep == _buildSteps().length - 1
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 3))
                              : Text(
                                  _currentStep == _buildSteps().length - 1
                                      ? 'Submit'
                                      : 'Next',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
      {required String label, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      suffixIcon: suffixIcon,
      labelStyle: const TextStyle(fontSize: 16, color: Colors.black54),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).primary, width: 2)),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
    );
  }
}
