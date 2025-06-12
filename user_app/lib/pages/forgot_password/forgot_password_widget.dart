import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:pinput/pinput.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgotPasswordRequestScreen extends StatefulWidget {
  const ForgotPasswordRequestScreen({super.key});

  @override
  _ForgotPasswordRequestScreenState createState() =>
      _ForgotPasswordRequestScreenState();
}

class _ForgotPasswordRequestScreenState
    extends State<ForgotPasswordRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      Future.delayed(const Duration(seconds: 1), () {
        setState(() => _isLoading = false);
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) =>
              PasswordResetStepperPage(loginId: _emailController.text.trim()),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ffTheme = FlutterFlowTheme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: ffTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 40),
              Icon(Icons.lock_reset_outlined, size: 80, color: ffTheme.primary),
              const SizedBox(height: 20),
              const Text('Reset Your Password',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text(
                'Enter your email address to receive password reset instructions.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v!.isEmpty || !v.contains('@')
                    ? "Enter a valid email"
                    : null,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ffTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Send Instructions',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PasswordResetStepperPage extends StatefulWidget {
  final String loginId;
  const PasswordResetStepperPage({super.key, required this.loginId});

  @override
  _PasswordResetStepperPageState createState() =>
      _PasswordResetStepperPageState();
}

class _PasswordResetStepperPageState extends State<PasswordResetStepperPage> {
  int _currentStep = 0;
  Timer? _otpTimer;
  int _otpTimeLeft = 900;

  final _otpController = TextEditingController();
  final _q1AnswerController = TextEditingController();
  final _q2AnswerController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final Map<String, String> _securityQuestions = {
    "Childhood best friend's name": "michael",
    "First pet's name": "fluffy",
    "Mother's maiden name": "smith"
  };
  late List<String> _presentedQuestions;

  @override
  void initState() {
    super.initState();
    _startOtpTimer();
    _presentRandomQuestions();
  }

  void _presentRandomQuestions() {
    final keys = _securityQuestions.keys.toList()..shuffle();
    _presentedQuestions = keys.take(2).toList();
  }

  void _startOtpTimer() {
    _otpTimer?.cancel();
    setState(() => _otpTimeLeft = 900);
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_otpTimeLeft > 0) {
        setState(() => _otpTimeLeft--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _otpTimer?.cancel();
    _otpController.dispose();
    _q1AnswerController.dispose();
    _q2AnswerController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onStepContinue() {
    bool isValid = false;
    switch (_currentStep) {
      case 0:
        isValid = _otpController.text == "123456";
        if (!isValid) Fluttertoast.showToast(msg: "Invalid OTP");
        break;
      case 1:
        final answer1 = _q1AnswerController.text.trim().toLowerCase();
        final answer2 = _q2AnswerController.text.trim().toLowerCase();
        isValid = _securityQuestions[_presentedQuestions[0]] == answer1 &&
            _securityQuestions[_presentedQuestions[1]] == answer2;
        if (!isValid) Fluttertoast.showToast(msg: "Answers are incorrect.");
        break;
      case 2:
        isValid = _passwordController.text.isNotEmpty &&
            _passwordController.text == _confirmPasswordController.text;
        if (isValid) {
          Fluttertoast.showToast(
              msg: "Password updated successfully!",
              backgroundColor: Colors.green);
          context.go('/user_login');
        } else {
          Fluttertoast.showToast(msg: "Passwords do not match.");
        }
        break;
    }

    if (isValid && _currentStep < 2) {
      setState(() => _currentStep++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: FlutterFlowTheme.of(context).primary,
        foregroundColor: Colors.white,
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel:
            _currentStep > 0 ? () => setState(() => _currentStep--) : null,
        steps: [
          Step(
            title: const Text('Enter OTP'),
            content: Column(
              children: [
                const Text(
                    "An OTP has been sent to your email. It will expire soon."),
                const SizedBox(height: 20),
                Pinput(length: 6, controller: _otpController),
                const SizedBox(height: 20),
                Text(
                    "Expires in: ${(_otpTimeLeft ~/ 60).toString().padLeft(2, '0')}:${(_otpTimeLeft % 60).toString().padLeft(2, '0')}"),
              ],
            ),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Answer Security Questions'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_presentedQuestions[0],
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(controller: _q1AnswerController),
                const SizedBox(height: 20),
                Text(_presentedQuestions[1],
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(controller: _q2AnswerController),
              ],
            ),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Set New Password'),
            content: Column(
              children: [
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "New Password"),
                  onChanged: (s) => setState(() {}),
                ),
                const SizedBox(height: 10),
                PasswordStrengthMeter(password: _passwordController.text),
                const SizedBox(height: 10),
                TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration:
                        const InputDecoration(labelText: "Confirm Password")),
              ],
            ),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }
}

class PasswordStrengthMeter extends StatelessWidget {
  final String password;
  const PasswordStrengthMeter({super.key, required this.password});

  Tuple<int, String, Color> _getPasswordStrength() {
    if (password.isEmpty) return const Tuple(0, "", Colors.transparent);
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;

    switch (score) {
      case 1:
        return const Tuple(1, "Weak", Colors.red);
      case 2:
        return const Tuple(2, "Medium", Colors.orange);
      case 3:
      case 4:
        return Tuple(score, "Strong", Colors.green);
      default:
        return const Tuple(0, "Very Weak", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strength = _getPasswordStrength();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: strength.item1 / 4.0,
          backgroundColor: Colors.grey[300],
          color: strength.item3,
          minHeight: 8,
        ),
        const SizedBox(height: 4),
        Text(strength.item2, style: TextStyle(color: strength.item3)),
      ],
    );
  }
}

class Tuple<T1, T2, T3> {
  final T1 item1;
  final T2 item2;
  final T3 item3;
  const Tuple(this.item1, this.item2, this.item3);
}
