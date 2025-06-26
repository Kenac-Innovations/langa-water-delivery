import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart' as intl_phone;
import 'package:langas_driver/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_driver/nav/nav.dart';

class ForgotPasswordWidget extends StatefulWidget {
  const ForgotPasswordWidget({Key? key}) : super(key: key);

  @override
  _ForgotPasswordWidgetState createState() => _ForgotPasswordWidgetState();
}

class _ForgotPasswordWidgetState extends State<ForgotPasswordWidget>
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
        if (mounted) {
          setState(() {
            _isPhoneSelected = _tabController.index == 0;
          });
        }
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

  void _handleForgotPassword() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      String loginId;
      if (_isPhoneSelected) {
        if (_fullPhoneNumber == null || _fullPhoneNumber!.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a valid phone number.'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isLoading = false);
          return;
        }
        loginId = _fullPhoneNumber!;
      } else {
        loginId = _emailController.text.trim();
      }

      // Simulate a network call
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset instructions sent successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          context.push('/resetPassword', extra: {'loginId': loginId});
        }
      });
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
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
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
                  Text(
                    'Reset Your Password',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: FlutterFlowTheme.of(context).primary,
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
                                  ? FlutterFlowTheme.of(context).primary
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
                                  ? FlutterFlowTheme.of(context).primary
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
                  _isPhoneSelected
                      ? _buildPhoneField(context)
                      : _buildEmailField(context),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleForgotPassword,
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
    );
  }

  Widget _buildEmailField(BuildContext context) {
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
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

  Widget _buildPhoneField(BuildContext context) {
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ).copyWith(counterText: ''),
      initialCountryCode: 'ZW',
      keyboardType: TextInputType.phone,
      onChanged: (intl_phone.PhoneNumber phone) {
        setState(() {
          _fullPhoneNumber = phone.completeNumber;
        });
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
}
