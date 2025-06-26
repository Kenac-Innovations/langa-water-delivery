import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart' as intl_phone;
import 'package:langas_driver/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_driver/nav/nav.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _fullPhoneNumber;

  @override
  void dispose() {
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // Simulate a network call
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isLoading = false);
          context.go('/homePage');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 80),
                      Image.asset(
                        'assets/images/logo.png',
                        height: 150,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2451DC).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.local_shipping,
                              size: 80,
                              color: FlutterFlowTheme.of(context).primary,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      Text(
                        "Welcome, Driver",
                        style:
                            FlutterFlowTheme.of(context).headlineSmall.override(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Log in to continue",
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Poppins',
                              color: Colors.grey,
                            ),
                      ),
                      const SizedBox(height: 30),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildPhoneField(),
                            const SizedBox(height: 20),
                            _buildPasswordField(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            context.push('/forgotPassword');
                          },
                          style: TextButton.styleFrom(
                            foregroundColor:
                                FlutterFlowTheme.of(context).primary,
                          ),
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                FlutterFlowTheme.of(context).primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Log In",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Having trouble logging in? ",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.grey,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Could link to a support page or show a dialog
                            },
                            child: Text(
                              "Contact Support",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: FlutterFlowTheme.of(context).primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Container(
                        width: 60,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A1C40),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return IntlPhoneField(
      controller: _phoneController,
      decoration: _buildInputDecoration(
        hintText: 'Phone Number',
        icon: Icons.phone_outlined,
      ).copyWith(counterText: ''),
      initialCountryCode: 'ZW',
      keyboardType: TextInputType.phone,
      onChanged: (intl_phone.PhoneNumber phone) {
        if (mounted) {
          setState(() {
            _fullPhoneNumber = phone.completeNumber;
          });
        }
      },
      validator: (intl_phone.PhoneNumber? phone) {
        if (phone == null || phone.number.isEmpty) {
          return 'Please enter your phone number';
        }
        return null;
      },
      dropdownTextStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 16),
      style: const TextStyle(fontFamily: 'Poppins', fontSize: 16),
      flagsButtonPadding: const EdgeInsets.only(left: 16),
      dropdownIconPosition: IconPosition.trailing,
      dropdownIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: _buildInputDecoration(
        hintText: "Password",
        icon: Icons.lock_outline,
        suffixIconWidget: IconButton(
          icon: Icon(
            _isPasswordVisible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.grey,
          ),
          onPressed: () {
            if (mounted) {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            }
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your password";
        }
        return null;
      },
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    IconData? icon,
    Widget? suffixIconWidget,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontFamily: 'Poppins',
        color: Colors.grey,
      ),
      prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
      suffixIcon: suffixIconWidget,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: FlutterFlowTheme.of(context).primary,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
    );
  }
}
