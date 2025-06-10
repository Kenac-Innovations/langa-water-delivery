class LoginRequest {
  final String loginId;
  final String password;

  LoginRequest({
    required this.loginId,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'login_id': loginId,
      'password': password,
    };
  }
}
