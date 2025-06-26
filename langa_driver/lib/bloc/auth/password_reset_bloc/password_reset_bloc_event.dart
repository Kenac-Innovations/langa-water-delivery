import 'package:equatable/equatable.dart';
import 'package:langas_driver/dto/auth_dto.dart';

abstract class PasswordResetEvent extends Equatable {
  const PasswordResetEvent();
  @override
  List<Object?> get props => [];
}

class RequestResetLink extends PasswordResetEvent {
  final String loginId;
  const RequestResetLink({required this.loginId});
  @override
  List<Object?> get props => [loginId];
}

class SubmitPasswordReset extends PasswordResetEvent {
  final ResetPasswordRequest request;
  const SubmitPasswordReset({required this.request});
  @override
  List<Object?> get props => [request];
}
