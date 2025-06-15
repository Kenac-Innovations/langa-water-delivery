import 'package:equatable/equatable.dart';
import 'package:langas_user/models/security_question_model.dart';
import 'package:langas_user/util/api_failure_models.dart';

abstract class PasswordResetState extends Equatable {
  const PasswordResetState();
  @override
  List<Object> get props => [];
}

class PasswordResetInitial extends PasswordResetState {}

class PasswordResetLoading extends PasswordResetState {}

class PasswordResetFailure extends PasswordResetState {
  final Failure failure;
  const PasswordResetFailure({required this.failure});
  @override
  List<Object> get props => [failure];
}

// State for when the initial OTP has been successfully sent
class PasswordResetOtpSent extends PasswordResetState {}

// State after OTP is verified, providing the security questions to the UI
class PasswordResetQuestionsLoaded extends PasswordResetState {
  final List<SecurityQuestion> questions;
  const PasswordResetQuestionsLoaded({required this.questions});
  @override
  List<Object> get props => [questions];
}

// State after security answers are verified, providing the final reset token
class PasswordResetTokenLoaded extends PasswordResetState {
  final String token;
  const PasswordResetTokenLoaded({required this.token});
  @override
  List<Object> get props => [token];
}

// Final success state after the password has been changed
class PasswordResetSuccess extends PasswordResetState {
  final String message;
  const PasswordResetSuccess({required this.message});
  @override
  List<Object> get props => [message];
}
