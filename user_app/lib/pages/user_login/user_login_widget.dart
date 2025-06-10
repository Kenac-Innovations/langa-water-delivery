import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart'
    as intl_phone_field_phone_number;
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_bloc.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_event.dart';
import 'package:langas_user/bloc/auth/login_bloc/login_bloc_bloc.dart';
import 'package:langas_user/bloc/auth/login_bloc/login_bloc_event.dart';
import 'package:langas_user/bloc/auth/login_bloc/login_bloc_state.dart';
import 'package:langas_user/dto/auth_dto.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isPhoneSelected = true;
  late TabController _tabController;
  bool _isLoading = false;
  String? _fullPhoneNumber;
  String _lastAttemptedLoginId = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _emailController.clear();
        _phoneController.clear();
        _passwordController.clear();
        _formKey.currentState?.reset();
        _fullPhoneNumber = null;
        setState(() {
          _isPhoneSelected = _tabController.index == 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _dispatchLoginEvent() {
    if (_formKey.currentState!.validate()) {
      String loginId;
      if (_isPhoneSelected) {
        if (_fullPhoneNumber == null || _fullPhoneNumber!.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a valid phone number.')),
          );
          return;
        }
        loginId = _fullPhoneNumber!;
      } else {
        loginId = _emailController.text.trim();
      }
      _lastAttemptedLoginId = loginId;

      final password = _passwordController.text;

      if (password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your password.')),
        );
        return;
      }

      final loginDto = LoginRequestDto(
        loginId: loginId,
        password: password,
      );

      context
          .read<LoginBloc>()
          .add(LoginButtonPressed(loginRequestDto: loginDto));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginLoading) {
            setState(() {
              _isLoading = true;
            });
          } else if (state is LoginSuccess) {
            setState(() {
              _isLoading = false;
            });
            context
                .read<AuthBloc>()
                .add(AuthLoggedIn(authResult: state.authResult));
          } else if (state is LoginFailure) {
            setState(() {
              _isLoading = false;
            });
            final failureMessage = state.failure.message.toLowerCase();
            if (state.failure.statusCode == 403 &&
                (failureMessage.contains("verify your account") ||
                    failureMessage.contains("account is disabled"))) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.failure.message),
                  backgroundColor: Colors.orange,
                ),
              );
              context.pushNamed(
                'OtpVerificationScreen',
                extra: _lastAttemptedLoginId,
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.failure.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 80),
                        Image.asset(
                          'assets/images/logo2.png',
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
                              child: const Icon(
                                Icons.shield_outlined,
                                size: 80,
                                color: Color(0xFF2451DC),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  _tabController.animateTo(0);
                                },
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: _tabController.index == 0
                                        ? const Color(0xFF0A1C40)
                                        : Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Phone Number",
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        color: _tabController.index == 0
                                            ? Colors.white
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  _tabController.animateTo(1);
                                },
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: _tabController.index == 1
                                        ? const Color(0xFF0A1C40)
                                        : Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Email",
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        color: _tabController.index == 1
                                            ? Colors.white
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _isPhoneSelected
                                  ? _buildPhoneField()
                                  : _buildEmailField(),
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
                              context.pushNamed('ForgotPasswordRequestScreen');
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF2451DC),
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
                            onPressed: _isLoading ? null : _dispatchLoginEvent,
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
                                    "Log in",
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
                              "New to TakeU? ",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.grey,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                context.pushNamed('SignUpScreen');
                              },
                              child: const Text(
                                "Create Account",
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration:
          _buildInputDecoration(hintText: "Email", icon: Icons.email_outlined),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your email";
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return "Please enter a valid email";
        }
        return null;
      },
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
      onChanged: (intl_phone_field_phone_number.PhoneNumber phone) {
        setState(() {
          _fullPhoneNumber = phone.completeNumber;
        });
      },
      validator: (intl_phone_field_phone_number.PhoneNumber? phone) {
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
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
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
