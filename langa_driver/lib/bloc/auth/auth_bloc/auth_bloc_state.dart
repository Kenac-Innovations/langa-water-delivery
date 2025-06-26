import 'package:equatable/equatable.dart';
import 'package:langas_driver/models/auth_models.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthDriverAuthenticated extends AuthState {
  final AuthResponseData authData;
  const AuthDriverAuthenticated({required this.authData});
  @override
  List<Object?> get props => [authData];
}

class AuthUnauthenticated extends AuthState {}
