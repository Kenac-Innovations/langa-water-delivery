import 'package:equatable/equatable.dart';
import 'package:langas_driver/models/auth_models.dart';
import 'package:langas_driver/utils/failure_models.dart';

abstract class DriverProfileState extends Equatable {
  const DriverProfileState();

  @override
  List<Object?> get props => [];
}

class DriverProfileInitial extends DriverProfileState {}

class DriverProfileLoading extends DriverProfileState {}

class DriverProfileLoadSuccess extends DriverProfileState {
  final DriverProfile driverProfile;

  const DriverProfileLoadSuccess({required this.driverProfile});

  @override
  List<Object?> get props => [driverProfile];
}

class UpdateWorkStatusSuccess extends DriverProfileState {
  final String message;

  const UpdateWorkStatusSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class UpdateAvailabilityStatusSuccess extends DriverProfileState {
  final String message;

  const UpdateAvailabilityStatusSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class UpdateSearchRadiusSuccess extends DriverProfileState {
  final String message;

  const UpdateSearchRadiusSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class DriverProfileLoadFailure extends DriverProfileState {
  final Failure failure;

  const DriverProfileLoadFailure({required this.failure});

  @override
  List<Object?> get props => [failure];
}

class DriverProfileDeleteInProgress extends DriverProfileState {}

class DriverProfileDeleteSuccess extends DriverProfileState {
  final String message;
  const DriverProfileDeleteSuccess({required this.message});
  @override
  List<Object?> get props => [message];
}

class DriverProfileDeleteFailure extends DriverProfileState {
  final Failure failure;

  const DriverProfileDeleteFailure({required this.failure});

  @override
  List<Object?> get props => [failure];
}

class UpdateStatusFailure extends DriverProfileState {
  final Failure failure;

  const UpdateStatusFailure({required this.failure});

  @override
  List<Object?> get props => [failure];
}
