import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:langas_user/bloc/auth/password_reset_bloc/password_reset_bloc_bloc.dart';
import 'package:langas_user/bloc/auth/password_reset_bloc/password_reset_bloc_event.dart';
import 'package:langas_user/bloc/auth/password_reset_bloc/password_reset_bloc_state.dart';
import 'package:langas_user/dto/auth_dto.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_user/models/security_question_model.dart';
import 'package:pinput/pinput.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgotPasswordRequestScreen extends StatefulWidget {
  const ForgotPasswordRequestScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordRequestScreenState createState() =>
      _ForgotPasswordRequestScreenState();
}

class _ForgotPasswordRequestScreenState
    extends State<ForgotPasswordRequestScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  final _emailFormKey = GlobalKey<FormState>();
  final _securityQuestionsFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late List<TextEditingController> _securityAnswerControllers;

  List<SecurityQuestion> _securityQuestions = [];
  String? _resetToken;

  // State for password visibility
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _securityAnswerControllers = [];
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
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

  void _handleNextStep() {
    final bloc = context.read<PasswordResetBloc>();
    switch (_currentStep) {
      case 0:
        if (_emailFormKey.currentState!.validate()) {
          bloc.add(PasswordResetOtpRequested(
              dto: PasswordResetRequestOtpDto(email: _emailController.text)));
        }
        break;
      case 1:
        if (_otpController.text.length == 6) {
          bloc.add(PasswordResetOtpVerified(
              dto: VerifyPasswordResetOtpDto(
                  email: _emailController.text, otp: _otpController.text)));
        } else {
          _showToast("OTP must be 6 digits.", isError: true);
        }
        break;
      case 2:
        if (_securityQuestionsFormKey.currentState!.validate()) {
          final answers = <SecurityAnswerDto>[];
          for (int i = 0; i < _securityQuestions.length; i++) {
            answers.add(SecurityAnswerDto(
              questionId: _securityQuestions[i].id,
              answer: _securityAnswerControllers[i].text.trim().toLowerCase(),
            ));
          }
          bloc.add(PasswordResetAnswersVerified(
              dto: VerifySecurityAnswersDto(
                  email: _emailController.text, answers: answers)));
        }
        break;
      case 3:
        if (_passwordFormKey.currentState!.validate()) {
          bloc.add(PasswordResetSubmitted(
              dto: ResetPasswordWithTokenDto(
                  token: _resetToken!, newPassword: _passwordController.text)));
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ffTheme = FlutterFlowTheme.of(context);
    final primaryColor = ffTheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Password Reset'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<PasswordResetBloc, PasswordResetState>(
        listener: (context, state) {
          setState(() => _isLoading = state is PasswordResetLoading);

          if (state is PasswordResetFailure) {
            _showToast(state.failure.message, isError: true);
          } else if (state is PasswordResetOtpSent) {
            _showToast("An OTP has been sent to your email.");
            setState(() => _currentStep = 1);
          } else if (state is PasswordResetQuestionsLoaded) {
            _showToast("OTP Verified. Please answer your questions.");
            setState(() {
              _securityQuestions = state.questions;
              _securityAnswerControllers = List.generate(
                  state.questions.length, (_) => TextEditingController());
              _currentStep = 2;
            });
          } else if (state is PasswordResetTokenLoaded) {
            _showToast("Security questions verified.");
            setState(() {
              _resetToken = state.token;
              _currentStep = 3;
            });
          } else if (state is PasswordResetSuccess) {
            _showToast(state.message);
            context.go('/userLogin');
          }
        },
        child: Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
                Theme.of(context).colorScheme.copyWith(primary: primaryColor),
          ),
          child: Stepper(
            type: StepperType.vertical,
            currentStep: _currentStep,
            onStepTapped: (step) {
              if (step < _currentStep) {
                setState(() => _currentStep = step);
              }
            },
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : details.onStepCancel,
                          child: const Text('Back'),
                          style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              side: BorderSide(color: Colors.grey.shade300)),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleNextStep,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 3))
                            : Text(_currentStep == 3
                                ? 'Reset Password'
                                : 'Continue'),
                      ),
                    ),
                  ],
                ),
              );
            },
            steps: [
              _buildStep(
                title: 'Enter Your Email',
                stepIndex: 0,
                content: Form(
                  key: _emailFormKey,
                  child: TextFormField(
                    controller: _emailController,
                    decoration: _buildInputDecoration(
                        label: 'Email Address', context: context),
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) => val!.isEmpty || !val.contains('@')
                        ? 'Enter a valid email'
                        : null,
                  ),
                ),
              ),
              _buildStep(
                  title: 'Verify OTP',
                  stepIndex: 1,
                  content: Column(
                    children: [
                      Text(
                          "Enter the 6-digit code sent to ${_emailController.text}",
                          textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      Pinput(
                        controller: _otpController,
                        length: 6,
                        defaultPinTheme:
                            _buildPinTheme(ffTheme.primary.withOpacity(0.1)),
                        focusedPinTheme:
                            _buildPinTheme(ffTheme.primary.withOpacity(0.3))
                                .copyWith(
                          decoration:
                              _buildPinTheme(ffTheme.primary.withOpacity(0.3))
                                  .decoration!
                                  .copyWith(
                                    border: Border.all(color: ffTheme.primary),
                                  ),
                        ),
                      ),
                    ],
                  )),
              _buildStep(
                  title: 'Answer Security Questions',
                  stepIndex: 2,
                  content: Form(
                      key: _securityQuestionsFormKey,
                      child: _securityQuestions.isEmpty
                          ? const Center(
                              child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text("Verifying OTP...")))
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _securityQuestions.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 20),
                              itemBuilder: (context, index) => TextFormField(
                                controller: _securityAnswerControllers[index],
                                decoration: _buildInputDecoration(
                                    label: _securityQuestions[index].question,
                                    context: context),
                                validator: (val) => val!.isEmpty
                                    ? 'Please provide an answer'
                                    : null,
                              ),
                            ))),
              _buildStep(
                  title: 'Set New Password',
                  stepIndex: 3,
                  content: Form(
                      key: _passwordFormKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isNewPasswordVisible,
                            decoration: _buildInputDecoration(
                              label: 'New Password',
                              context: context,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isNewPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey.shade600,
                                ),
                                onPressed: () => setState(() =>
                                    _isNewPasswordVisible =
                                        !_isNewPasswordVisible),
                              ),
                            ),
                            validator: (val) => val!.length < 6
                                ? 'Password must be at least 6 characters'
                                : null,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: !_isConfirmPasswordVisible,
                            decoration: _buildInputDecoration(
                              label: 'Confirm New Password',
                              context: context,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey.shade600,
                                ),
                                onPressed: () => setState(() =>
                                    _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible),
                              ),
                            ),
                            validator: (val) => val != _passwordController.text
                                ? 'Passwords do not match'
                                : null,
                          ),
                        ],
                      ))),
            ],
          ),
        ),
      ),
    );
  }

  Step _buildStep(
      {required String title,
      required int stepIndex,
      required Widget content}) {
    final ffTheme = FlutterFlowTheme.of(context);
    return Step(
      title: Text(title,
          style: TextStyle(
              color:
                  _currentStep == stepIndex ? ffTheme.primary : Colors.black87,
              fontWeight: _currentStep == stepIndex
                  ? FontWeight.bold
                  : FontWeight.normal)),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: content,
      ),
      isActive: _currentStep >= stepIndex,
      state: _currentStep > stepIndex ? StepState.complete : StepState.indexed,
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required BuildContext context,
    Widget? suffixIcon,
  }) {
    final ffTheme = FlutterFlowTheme.of(context);
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade600),
      alignLabelWithHint: true,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ffTheme.primary, width: 2)),
    );
  }

  PinTheme _buildPinTheme(Color fillColor) {
    return PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.transparent),
      ),
    );
  }
}
