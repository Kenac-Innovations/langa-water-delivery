import 'package:equatable/equatable.dart';
import 'package:langas_user/models/auth_response_model.dart';
import 'package:langas_user/models/security_question_model.dart';
import 'package:langas_user/util/api_failure_models.dart';

abstract class RegisterState extends Equatable {
  const RegisterState();
  @override
  List<Object> get props => [];
}

class RegisterInitial extends RegisterState {}

class RegisterOtpLoading extends RegisterState {}

class RegisterOtpSuccess extends RegisterState {}

class RegisterOtpFailure extends RegisterState {
  final Failure failure;
  const RegisterOtpFailure({required this.failure});
  @override
  List<Object> get props => [failure];
}

class RegisterOtpValidationLoading extends RegisterState {}

class RegisterOtpValidationSuccess extends RegisterState {
  final List<SecurityQuestion> questions;
  const RegisterOtpValidationSuccess({required this.questions});
  @override
  List<Object> get props => [questions];
}

class RegisterOtpValidationFailure extends RegisterState {
  final Failure failure;
  const RegisterOtpValidationFailure({required this.failure});
  @override
  List<Object> get props => [failure];
}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {
  final AuthResult authResult;
  const RegisterSuccess({required this.authResult});
  @override
  List<Object> get props => [authResult];
}

class RegisterFailure extends RegisterState {
  final Failure failure;
  const RegisterFailure({required this.failure});
  @override
  List<Object> get props => [failure];
}
