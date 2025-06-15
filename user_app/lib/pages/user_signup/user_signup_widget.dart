import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_bloc.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_event.dart';
import 'package:langas_user/bloc/auth/register_bloc/register_bloc_bloc.dart';
import 'package:langas_user/bloc/auth/register_bloc/register_bloc_event.dart';
import 'package:langas_user/bloc/auth/register_bloc/register_bloc_state.dart';
import 'package:langas_user/dto/auth_dto.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_user/models/security_question_model.dart';
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

  // Dynamic controllers for security questions
  late List<TextEditingController> _securityAnswerControllers;
  List<SecurityQuestion> _securityQuestions = [];

  String? _fullPhoneNumber;
  LatLng? _selectedLatLng;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _termsAccepted = false;

  Timer? _otpTimer;
  int _otpTimeLeft = 60;
  bool _canResendOtp = false;

  @override
  void initState() {
    super.initState();
    _securityAnswerControllers = [];
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
    for (var controller in _securityAnswerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
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

  void _requestOtp() {
    if (_personalDetailsFormKey.currentState!.validate()) {
      context.read<RegisterBloc>().add(
            RegisterOtpRequested(
              dto: RequestOtpDto(
                email: _emailController.text,
                phoneNumber: _fullPhoneNumber!,
                fullName: _fullNameController.text,
              ),
            ),
          );
    }
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
        _addressController.text = result.address;
        _selectedLatLng = result.coordinates;
      });
    }
  }

  void _onStepContinue() {
    switch (_currentStep) {
      case 0:
        if (_personalDetailsFormKey.currentState!.validate()) {
          _requestOtp();
        }
        break;
      case 1:
        if (_otpController.text.length == 6) {
          context.read<RegisterBloc>().add(
                RegisterOtpValidated(
                  dto: ValidateOtpDto(
                    otp: _otpController.text,
                    phoneOrEmail: _fullPhoneNumber!,
                  ),
                ),
              );
        } else {
          _showToast("Invalid OTP", isError: true);
        }
        break;
      case 2:
        if (_addressFormKey.currentState!.validate() &&
            _selectedLatLng != null) {
          setState(() => _currentStep++);
        } else {
          _showToast("Please enter address and capture location",
              isError: true);
        }
        break;
      case 3:
        if (_passwordFormKey.currentState!.validate()) {
          setState(() => _currentStep++);
        }
        break;
      case 4:
        if (_securityQuestionsFormKey.currentState!.validate()) {
          setState(() => _currentStep++);
        }
        break;
      case 5:
        if (_termsAccepted) {
          final securityAnswers = <SecurityAnswerDto>[];
          for (int i = 0; i < _securityQuestions.length; i++) {
            securityAnswers.add(SecurityAnswerDto(
              questionId: _securityQuestions[i].id,
              answer: _securityAnswerControllers[i].text,
            ));
          }
          if (_securityQuestions.isEmpty) {
            _showToast("Please answer the security questions.", isError: true);
            return;
          }
          // implement geohash generation logic here
          final geohash = 'werewr';

          context.read<RegisterBloc>().add(
                RegisterSubmitted(
                  dto: RegisterRequestDto(
                    phoneNumber: _fullPhoneNumber!,
                    email: _emailController.text,
                    fullName: _fullNameController.text,
                    password: _passwordController.text,
                    address: AddressDto(
                      addressEntered: _addressController.text,
                      latitude: _selectedLatLng!.latitude,
                      longitude: _selectedLatLng!.longitude,
                      addressFormatted: _addressController
                          .text, // Or format it differently if needed
                      geohash: geohash,
                    ),
                    securityAnswers: securityAnswers,
                  ),
                ),
              );
        } else {
          _showToast("Please accept the terms and conditions.", isError: true);
        }
        break;
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
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
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your full name' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: _buildInputDecoration(label: "Email Address"),
                  style: const TextStyle(fontSize: 16),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value!.isEmpty || !value.contains('@')
                      ? 'Enter a valid email'
                      : null,
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
                  },
                  validator: (phone) => phone == null || phone.number.isEmpty
                      ? 'Please enter a phone number'
                      : null,
                ),
              ],
            ),
          ),
        ),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
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
                      onPressed: _requestOtp, child: const Text("Resend OTP"))
                  : Text(
                      "Resend code in ${_otpTimeLeft}s",
                      style: const TextStyle(color: Colors.grey),
                    ),
            ],
          ),
        ),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
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
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter an address' : null,
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
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
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
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
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
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        isActive: _currentStep >= 3,
        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text("Security Questions"),
        content: Form(
          key: _securityQuestionsFormKey,
          child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: _securityQuestions.isEmpty
                  ? const Center(
                      child: Text("Complete previous step to load questions."))
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _securityQuestions.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        return TextFormField(
                          controller: _securityAnswerControllers[index],
                          decoration: _buildInputDecoration(
                              label: _securityQuestions[index].question),
                          style: const TextStyle(fontSize: 16),
                          validator: (value) => value!.isEmpty
                              ? 'Please provide an answer'
                              : null,
                        );
                      },
                    )),
        ),
        isActive: _currentStep >= 4,
        state: _currentStep > 4 ? StepState.complete : StepState.indexed,
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
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        isActive: _currentStep >= 5,
        state: _currentStep > 5 ? StepState.complete : StepState.indexed,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Your Account"),
        backgroundColor: FlutterFlowTheme.of(context).primary,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<RegisterBloc, RegisterState>(
        listener: (context, state) {
          setState(() => _isLoading = false);

          if (state is RegisterOtpLoading ||
              state is RegisterOtpValidationLoading ||
              state is RegisterLoading) {
            setState(() => _isLoading = true);
          } else if (state is RegisterOtpFailure) {
            _showToast(state.failure.message, isError: true);
          } else if (state is RegisterOtpSuccess) {
            _showToast("OTP sent successfully!");
            _startOtpTimer();
            setState(() => _currentStep++);
          } else if (state is RegisterOtpValidationFailure) {
            _showToast(state.failure.message, isError: true);
          } else if (state is RegisterOtpValidationSuccess) {
            _showToast("OTP Validated!");
            setState(() {
              _securityQuestions = state.questions;
              _securityAnswerControllers = List.generate(
                state.questions.length,
                (_) => TextEditingController(),
              );
              _currentStep++;
            });
          } else if (state is RegisterFailure) {
            _showToast(state.failure.message, isError: true);
          } else if (state is RegisterSuccess) {
            _showToast("Registration Successful!");
            context
                .read<AuthBloc>()
                .add(AuthLoggedIn(authResult: state.authResult));
            context.go('/homePage');
          }
        },
        child: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
                primary: FlutterFlowTheme.of(context).primary),
          ),
          child: Stepper(
            type: StepperType.vertical,
            currentStep: _currentStep,
            steps: _buildSteps(),
            onStepContinue: _isLoading ? null : _onStepContinue,
            onStepCancel: _isLoading ? null : _onStepCancel,
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
                        child:
                            const Text("Back", style: TextStyle(fontSize: 16)),
                      )),
                    if (_currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FlutterFlowTheme.of(context).primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
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
                                    fontSize: 16, fontWeight: FontWeight.bold),
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
