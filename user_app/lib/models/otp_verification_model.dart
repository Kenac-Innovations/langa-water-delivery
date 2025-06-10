class OtpVerificationRequest {
  final String phoneNumber;
  final String otpCode;

  OtpVerificationRequest({
    required this.phoneNumber,
    required this.otpCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'otp_code': otpCode,
    };
  }
}
