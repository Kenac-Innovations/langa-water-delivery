import 'package:equatable/equatable.dart';
import 'package:langas_user/models/auth_response_model.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoggedIn extends AuthEvent {
  final AuthResult authResult;

  const AuthLoggedIn({required this.authResult});

  @override
  List<Object?> get props => [authResult];
}

class AuthLoggedOut extends AuthEvent {}
