import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:langas_user/bloc/auth/password_reset_request/password_reset_request_bloc_bloc.dart';
import 'package:langas_user/bloc/auth/password_reset_request/password_reset_request_bloc_event.dart';
import 'package:langas_user/bloc/auth/password_reset_request/password_reset_request_bloc_state.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_user/pages/reset_password/reset_password_page.dart';

class ForgotPasswordRequestScreen extends StatefulWidget {
  const ForgotPasswordRequestScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordRequestScreenState createState() =>
      _ForgotPasswordRequestScreenState();
}

class _ForgotPasswordRequestScreenState
    extends State<ForgotPasswordRequestScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  bool _isPhoneSelected = true;
  late TabController _tabController;
  String? _fullPhoneNumber;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _emailController.clear();
        _phoneController.clear();
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
    _phoneController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _dispatchRequestLinkEvent() {
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

      context
          .read<PasswordResetRequestBloc>()
          .add(PasswordResetLinkRequested(loginId: loginId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ffTheme = FlutterFlowTheme.of(context);
    final primaryColor = ffTheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          'Forgot Password',
          style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<PasswordResetRequestBloc, PasswordResetRequestState>(
        listener: (context, state) {
          if (state is PasswordResetRequestLoading) {
            setState(() {
              _isLoading = true;
            });
          } else if (state is PasswordResetRequestSuccess) {
            setState(() {
              _isLoading = false;
            });

            // Get the loginId used for the request
            final loginId = _isPhoneSelected
                ? _fullPhoneNumber!
                : _emailController.text.trim();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message), // Show confirmation message
                backgroundColor: Colors.green,
              ),
            );

            // Navigate to ResetPasswordScreen, passing only the loginId
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) =>
                  ResetPasswordScreen(loginId: loginId), // Pass loginId
            ));
          } else if (state is PasswordResetRequestFailure) {
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Icon(
                      Icons.lock_reset_outlined,
                      size: 80,
                      color: primaryColor,
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Reset Your Password',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Color(0xFF0A1C40),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Select Email or Phone Number to receive your password reset instructions.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontFamily: 'Poppins',
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 30),
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
                    _isPhoneSelected ? _buildPhoneField() : _buildEmailField(),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed:
                            _isLoading ? null : _dispatchRequestLinkEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Text(
                                'Send Instructions',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                      ),
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    final primaryColor = FlutterFlowTheme.of(context).primary;
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email Address',
        hintText: 'Enter your email',
        prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
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
    final primaryColor = FlutterFlowTheme.of(context).primary;
    return IntlPhoneField(
      controller: _phoneController,
      decoration: InputDecoration(
        labelText: 'Phone Number',
        hintText: 'Enter your phone number',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
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
}
