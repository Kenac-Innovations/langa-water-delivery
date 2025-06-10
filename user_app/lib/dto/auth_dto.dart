class RegisterResponseDataDto {
  final int userId;
  final String email;
  final String phoneNumber;

  RegisterResponseDataDto({
    required this.userId,
    required this.email,
    required this.phoneNumber,
  });

  factory RegisterResponseDataDto.fromJson(Map<String, dynamic> json) {
    return RegisterResponseDataDto(
      userId: json['userId'] ?? 0,
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
    );
  }
}

class RegisterRequestDto {
  final String phoneNumber;
  final String email;
  final String firstname;
  final String lastname;
  final String password;

  RegisterRequestDto({
    required this.phoneNumber,
    required this.email,
    required this.firstname,
    required this.lastname,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'email': email,
      'firstname': firstname,
      'lastname': lastname,
      'password': password,
    };
  }
}

class VerifyAccountRequestDto {
  final String loginID;
  final String otp;

  VerifyAccountRequestDto({
    required this.loginID,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'loginID': loginID,
      'otp': otp,
    };
  }
}

class LoginRequestDto {
  final String loginId;
  final String password;

  LoginRequestDto({
    required this.loginId,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'loginId': loginId,
      'password': password,
    };
  }
}

class ResetPasswordRequestDto {
  final String loginId;
  final String token;
  final String password;

  ResetPasswordRequestDto({
    required this.loginId,
    required this.token,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'loginId': loginId,
      'token': token,
      'password': password,
    };
  }
}


