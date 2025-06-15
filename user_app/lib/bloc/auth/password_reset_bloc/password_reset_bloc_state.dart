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
}

class PasswordResetOtpSent extends PasswordResetState {}

class PasswordResetQuestionsLoaded extends PasswordResetState {
  final List<SecurityQuestion> questions;
  const PasswordResetQuestionsLoaded({required this.questions});
}

class PasswordResetTokenLoaded extends PasswordResetState {
  final String token;
  const PasswordResetTokenLoaded({required this.token});
}

class PasswordResetSuccess extends PasswordResetState {}
