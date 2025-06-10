import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:langas_user/bloc/auth/register_bloc/register_bloc_bloc.dart';
import 'package:langas_user/bloc/auth/register_bloc/register_bloc_event.dart';
import 'package:langas_user/bloc/auth/register_bloc/register_bloc_state.dart';
import 'package:langas_user/dto/auth_dto.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String? _fullPhoneNumber;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _dispatchRegisterEvent() {
    if (_formKey.currentState!.validate()) {
      if (_fullPhoneNumber == null || _fullPhoneNumber!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid phone number.')),
        );
        return;
      }

      final registerDto = RegisterRequestDto(
        firstname: _firstNameController.text.trim(),
        lastname: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _fullPhoneNumber!,
        password: _passwordController.text,
      );

      context
          .read<RegisterBloc>()
          .add(RegisterSubmitted(registerRequestDto: registerDto));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state is RegisterLoading) {
            setState(() {
              _isLoading = true;
            });
          } else if (state is RegisterSuccess) {
            setState(() {
              _isLoading = false;
            });
            final loginId = state.registerResponseDataDto.email.isNotEmpty
                ? state.registerResponseDataDto.email
                : state.registerResponseDataDto.phoneNumber;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Registration successful! Please verify your account.'),
                backgroundColor: Colors.green,
              ),
            );

            // Use GoRouter for navigation
            context.pushReplacementNamed(
              'OtpVerificationScreen', // Use the route name defined in nav.dart
              extra: loginId, // Pass loginId as extra data
            );
          } else if (state is RegisterFailure) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure.message),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            if (_isLoading) {
              setState(() {
                _isLoading = false;
              });
            }
          }
        },
        child: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // const SizedBox(height: 60),
                          // Image.asset(
                          //   'assets/images/logo2.png',
                          //   height: 120,
                          //   fit: BoxFit.contain,
                          //   errorBuilder: (context, error, stackTrace) {
                          //     return Container(
                          //       height: 120,
                          //       width: 120,
                          //       decoration: BoxDecoration(
                          //         color:
                          //             const Color(0xFF2451DC).withOpacity(0.1),
                          //         shape: BoxShape.circle,
                          //       ),
                          //       child: const Icon(
                          //         Icons.shield_outlined,
                          //         size: 60,
                          //         color: Color(0xFF2451DC),
                          //       ),
                          //     );
                          //   },
                          // ),
                          const SizedBox(height: 30),
                          const Text(
                            "Create Account",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A1C40),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Enter your details to sign up",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 30),
                          _buildTextField(
                            controller: _firstNameController,
                            hintText: "First Name",
                            icon: Icons.person_outline,
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                    ? "Please enter your first name"
                                    : null,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _lastNameController,
                            hintText: "Last Name",
                            icon: Icons.person_outline,
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                    ? "Please enter your last name"
                                    : null,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _emailController,
                            hintText: "Email",
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your email";
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return "Please enter a valid email";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildPhoneField(),
                          const SizedBox(height: 20),
                          _buildPasswordField(
                            controller: _passwordController,
                            hintText: "Password",
                            isPasswordVisible: _isPasswordVisible,
                            onVisibilityToggle: () => setState(
                                () => _isPasswordVisible = !_isPasswordVisible),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter a password";
                              }
                              if (value.length < 6) {
                                return "Password must be at least 6 characters";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildPasswordField(
                            controller: _confirmPasswordController,
                            hintText: "Confirm Password",
                            isPasswordVisible: _isConfirmPasswordVisible,
                            onVisibilityToggle: () => setState(() =>
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please confirm your password";
                              }
                              if (value != _passwordController.text) {
                                return "Passwords do not match";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed:
                                  _isLoading ? null : _dispatchRegisterEvent,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0A1C40),
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
                                      "Create Account",
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
                                "Already have an account? ",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.grey,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Use GoRouter pop/goNamed
                                  if (context.canPop()) {
                                    context.pop();
                                  } else {
                                    context.goNamed('LoginScreen');
                                  }
                                },
                                child: const Text(
                                  "Log In",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Color(0xFF2451DC),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    IconData? icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _buildInputDecoration(
        hintText: hintText,
        icon: icon,
      ),
      validator: validator,
    );
  }

  Widget _buildPhoneField() {
    return IntlPhoneField(
      controller: _phoneController,
      decoration: _buildInputDecoration(
        hintText: 'Phone Number',
      ).copyWith(counterText: ''),
      initialCountryCode: 'ZW',
      keyboardType: TextInputType.phone,
      onChanged: (PhoneNumber phone) {
        setState(() {
          _fullPhoneNumber = phone.completeNumber;
        });
      },
      validator: (PhoneNumber? phone) {
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isPasswordVisible,
    required VoidCallback onVisibilityToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isPasswordVisible,
      decoration: _buildInputDecoration(
        hintText: hintText,
        icon: Icons.lock_outline,
        suffixIconWidget: IconButton(
          icon: Icon(
            isPasswordVisible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.grey,
          ),
          onPressed: onVisibilityToggle,
        ),
      ),
      validator: validator,
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
        borderSide: const BorderSide(
          color: Color(0xFF2451DC),
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
