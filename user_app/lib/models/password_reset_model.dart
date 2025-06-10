class PasswordResetRequest {
  final String loginId;

  PasswordResetRequest({required this.loginId});

  Map<String, dynamic> toJson() {
    return {'login_id': loginId};
  }
}

class EmailPasswordResetRequest {
  final String token;
  final String newPassword;

  EmailPasswordResetRequest({
    required this.token,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'new_password': newPassword,
    };
  }
}

class PhonePasswordResetRequest {
  final String otpToken;
  final String newPassword;

  PhonePasswordResetRequest({
    required this.otpToken,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'otp_token': otpToken,
      'new_password': newPassword,
    };
  }
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'current_password': currentPassword,
      'new_password': newPassword,
    };
  }
}