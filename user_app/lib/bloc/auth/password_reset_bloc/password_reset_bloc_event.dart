import 'package:equatable/equatable.dart';
import 'package:langas_user/dto/auth_dto.dart';

abstract class PasswordResetEvent extends Equatable {
  const PasswordResetEvent();
  @override
  List<Object> get props => [];
}

class PasswordResetOtpRequested extends PasswordResetEvent {
  final PasswordResetRequestOtpDto dto;
  const PasswordResetOtpRequested({required this.dto});
}

class PasswordResetOtpVerified extends PasswordResetEvent {
  final VerifyPasswordResetOtpDto dto;
  const PasswordResetOtpVerified({required this.dto});
}

class PasswordResetAnswersVerified extends PasswordResetEvent {
  final VerifySecurityAnswersDto dto;
  const PasswordResetAnswersVerified({required this.dto});
}

class PasswordResetSubmitted extends PasswordResetEvent {
  final ResetPasswordWithTokenDto dto;
  const PasswordResetSubmitted({required this.dto});
}
