import 'package:equatable/equatable.dart';
import 'package:langas_driver/models/auth_models.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthDriverAppStarted extends AuthEvent {}

class AuthDriverLoggedIn extends AuthEvent {
  final AuthResponseData authData;
  const AuthDriverLoggedIn({required this.authData});
  @override
  List<Object?> get props => [authData];
}

class AuthDriverLoggedOut extends AuthEvent {}
