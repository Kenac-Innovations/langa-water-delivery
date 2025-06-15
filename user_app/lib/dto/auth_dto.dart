import 'package:langas_user/models/security_question_model.dart';

// --- OTP & Registration DTOs ---

class RequestOtpDto {
  final String email;
  final String phoneNumber;
  final String fullName;

  RequestOtpDto({
    required this.email,
    required this.phoneNumber,
    required this.fullName,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'phoneNumber': phoneNumber,
        'fullName': fullName,
      };
}

class ValidateOtpDto {
  final String otp;
  final String phoneOrEmail;

  ValidateOtpDto({required this.otp, required this.phoneOrEmail});

  Map<String, dynamic> toJson() => {
        'otp': otp,
        'phoneOrEmail': phoneOrEmail,
      };
}

class SecurityAnswerDto {
  final int questionId;
  final String answer;

  SecurityAnswerDto({required this.questionId, required this.answer});

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'answer': answer,
      };
}

class AddressDto {
  final String addressEntered;
  final double latitude;
  final double longitude;
  final String addressFormatted;
  final String geohash;
  final int? clientId;

  AddressDto({
    required this.addressEntered,
    required this.latitude,
    required this.longitude,
    required this.addressFormatted,
    required this.geohash,
    this.clientId,
  });

  Map<String, dynamic> toJson() => {
        'addressEntered': addressEntered,
        'latitude': latitude,
        'longitude': longitude,
        'addressFormatted': addressFormatted,
        'geohash': geohash,
        'clientId': clientId,
      };
}

class RegisterRequestDto {
  final String phoneNumber;
  final String email;
  final String fullName;
  final String password;
  final List<String> commChannels;
  final AddressDto address;
  final List<SecurityAnswerDto> securityAnswers;

  RegisterRequestDto({
    required this.phoneNumber,
    required this.email,
    required this.fullName,
    required this.password,
    this.commChannels = const ['SMS'],
    required this.address,
    required this.securityAnswers,
  });

  Map<String, dynamic> toJson() => {
        'phoneNumber': phoneNumber,
        'email': email,
        'fullName': fullName,
        'password': password,
        'commChannels': commChannels,
        'address': address.toJson(),
        'securityAnswers': securityAnswers.map((a) => a.toJson()).toList(),
      };
}

// --- Login DTO ---

class LoginRequestDto {
  final String loginId;
  final String password;

  LoginRequestDto({required this.loginId, required this.password});

  Map<String, dynamic> toJson() => {
        'loginId': loginId,
        'password': password,
      };
}

// --- Password Reset DTOs ---

class PasswordResetRequestOtpDto {
  final String email;
  PasswordResetRequestOtpDto({required this.email});
  Map<String, dynamic> toJson() => {'email': email};
}

class VerifyPasswordResetOtpDto {
  final String email;
  final String otp;
  VerifyPasswordResetOtpDto({required this.email, required this.otp});
  Map<String, dynamic> toJson() => {'email': email, 'otp': otp};
}

class VerifySecurityAnswersDto {
  final String email;
  final List<SecurityAnswerDto> answers;
  VerifySecurityAnswersDto({required this.email, required this.answers});
  Map<String, dynamic> toJson() => {
        'email': email,
        'answers': answers.map((a) => a.toJson()).toList(),
      };
}

class ResetPasswordWithTokenDto {
  final String token;
  final String newPassword;
  ResetPasswordWithTokenDto({required this.token, required this.newPassword});
  Map<String, dynamic> toJson() => {'token': token, 'newPassword': newPassword};
}

// --- Response DTOs ---

class VerifyPasswordResetOtpResponseDto {
  final List<SecurityQuestion> securityQuestions;
  VerifyPasswordResetOtpResponseDto({required this.securityQuestions});

  factory VerifyPasswordResetOtpResponseDto.fromJson(
      Map<String, dynamic> json) {
    var questions = (json['securityQuestions'] as List)
        .map((q) => SecurityQuestion.fromJson(q))
        .toList();
    return VerifyPasswordResetOtpResponseDto(securityQuestions: questions);
  }
}
