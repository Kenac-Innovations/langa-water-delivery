import 'package:equatable/equatable.dart';
import 'package:langas_driver/models/auth_models.dart';
import 'package:langas_driver/utils/failure_models.dart';

abstract class DriverLoginState extends Equatable {
  const DriverLoginState();
  @override
  List<Object?> get props => [];
}

class LoginInitial extends DriverLoginState {}

class LoginLoading extends DriverLoginState {}

class LoginSuccess extends DriverLoginState {
  final AuthResponseData authData;
  const LoginSuccess({required this.authData});
  @override
  List<Object?> get props => [authData];
}

class LoginRequiresOtpVerification extends DriverLoginState {
  final String loginId;
  const LoginRequiresOtpVerification({required this.loginId});
  @override
  List<Object?> get props => [loginId];
}

class LoginFailure extends DriverLoginState {
  final Failure failure;
  const LoginFailure({required this.failure});
  @override
  List<Object?> get props => [failure];
}
