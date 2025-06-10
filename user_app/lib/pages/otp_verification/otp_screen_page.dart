import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:langas_user/bloc/auth/verify_account_bloc/verify_account_bloc_bloc.dart';
import 'package:langas_user/bloc/auth/verify_account_bloc/verify_account_bloc_event.dart';
import 'package:langas_user/bloc/auth/verify_account_bloc/verify_account_bloc_state.dart';
import 'package:langas_user/dto/auth_dto.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String loginId;

  const OtpVerificationScreen({
    super.key,
    required this.loginId,
  });

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const int otpLength = 6;

  final List<TextEditingController> _otpControllers = List.generate(
    otpLength,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    otpLength,
    (index) => FocusNode(),
  );

  int _timerSeconds = 60;
  Timer? _timer;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timerSeconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_timerSeconds > 0) {
          _timerSeconds--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  void _resendOtp() {
    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP resent successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _dispatchVerifyOtpEvent() {
    String otp = _otpControllers.map((controller) => controller.text).join();

    if (otp.length != otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the complete 6-digit OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final verifyDto = VerifyAccountRequestDto(
      loginID: widget.loginId,
      otp: otp,
    );

    context
        .read<VerifyAccountBloc>()
        .add(VerifyAccountSubmitted(verifyAccountRequestDto: verifyDto));
  }

  void _onOtpDigitChanged(int index, String value) {
    if (value.length == 1 && index < otpLength - 1) {
      _focusNodes[index].unfocus();
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index].unfocus();
      _focusNodes[index - 1].requestFocus();
    } else if (value.length == 1 && index == otpLength - 1) {
      _focusNodes[index].unfocus();
      _dispatchVerifyOtpEvent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ffTheme = FlutterFlowTheme.of(context);
    final primaryColor = ffTheme.primary;
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - (24.0 * 2);
    const spacing = 10.0 * (otpLength - 1);
    final boxWidth = (availableWidth - spacing) / otpLength;
    final constrainedBoxWidth = boxWidth.clamp(45.0, 60.0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Verify Account',
          style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<VerifyAccountBloc, VerifyAccountState>(
        listener: (context, state) {
          if (state is VerifyAccountLoading) {
            setState(() {
              _isVerifying = true;
            });
          } else if (state is VerifyAccountSuccess) {
            setState(() {
              _isVerifying = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            context.goNamed('LoginScreen');
          } else if (state is VerifyAccountFailure) {
            setState(() {
              _isVerifying = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure.message),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            if (_isVerifying) {
              setState(() {
                _isVerifying = false;
              });
            }
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Icon(
                    Icons.phonelink_lock_outlined,
                    size: 80,
                    color: primaryColor,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Enter Verification Code',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Enter the 6-digit code sent to\n${widget.loginId}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontFamily: 'Poppins',
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      otpLength,
                      (index) => SizedBox(
                        width: constrainedBoxWidth,
                        height: constrainedBoxWidth * 1.1,
                        child: TextFormField(
                          controller: _otpControllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          onChanged: (value) =>
                              _onOtpDigitChanged(index, value),
                          style: TextStyle(
                            fontSize: constrainedBoxWidth * 0.4,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.grey.shade300, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryColor,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Didn\'t receive code? ',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      _timerSeconds > 0
                          ? Text(
                              'Resend in ${_timerSeconds}s',
                              style: TextStyle(
                                fontSize: 15,
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            )
                          : GestureDetector(
                              onTap: _timerSeconds == 0 ? _resendOtp : null,
                              child: Text(
                                'Resend OTP',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isVerifying ? null : _dispatchVerifyOtpEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isVerifying
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Text(
                              'Verify & Proceed',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'Please check your spam folder if you don\'t see the code.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
}
