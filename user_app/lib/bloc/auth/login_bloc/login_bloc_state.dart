import 'package:equatable/equatable.dart';
import 'package:langas_user/models/auth_response_model.dart';
import 'package:langas_user/util/api_failure_models.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final AuthResult authResult;

  const LoginSuccess({required this.authResult});

  @override
  List<Object> get props => [authResult];
}

class LoginFailure extends LoginState {
  final Failure failure;

  const LoginFailure({required this.failure});

  @override
  List<Object> get props => [failure];
}
