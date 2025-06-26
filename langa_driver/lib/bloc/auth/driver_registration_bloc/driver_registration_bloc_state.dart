import 'package:equatable/equatable.dart';
import 'package:langas_driver/models/auth_models.dart';
import 'package:langas_driver/utils/failure_models.dart';

abstract class DriverRegistrationState extends Equatable {
  const DriverRegistrationState();
  @override
  List<Object?> get props => [];
}

class RegistrationInitial extends DriverRegistrationState {}

class RegistrationLoading extends DriverRegistrationState {}

class RegistrationSuccess extends DriverRegistrationState {
  final DriverRegistrationResponseData responseData;
  const RegistrationSuccess({required this.responseData});
  @override
  List<Object?> get props => [responseData];
}

class RegistrationFailure extends DriverRegistrationState {
  final Failure failure;
  const RegistrationFailure({required this.failure});
  @override
  List<Object?> get props => [failure];
}
