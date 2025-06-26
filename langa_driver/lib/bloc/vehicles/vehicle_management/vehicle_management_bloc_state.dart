import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:langas_driver/models/vehicle_model.dart';
import 'package:langas_driver/utils/failure_models.dart';

@immutable
abstract class VehicleManagementState extends Equatable {
  const VehicleManagementState();
  @override
  List<Object?> get props => [];
}

class VehicleInitial extends VehicleManagementState {}

class VehicleLoading extends VehicleManagementState {}

class VehicleActionInProgress extends VehicleManagementState {}

class VehicleListLoadSuccess extends VehicleManagementState {
  final List<Vehicle> vehicles;
  final int? activeVehicleId;

  const VehicleListLoadSuccess({required this.vehicles, this.activeVehicleId});

  @override
  List<Object?> get props => [vehicles, activeVehicleId];
}

class VehicleListLoadFailure extends VehicleManagementState {
  final Failure failure;
  const VehicleListLoadFailure({required this.failure});
  @override
  List<Object?> get props => [failure];
}

class VehicleCreateSuccess extends VehicleManagementState {
  final Vehicle newVehicle;
  const VehicleCreateSuccess({required this.newVehicle});
  @override
  List<Object?> get props => [newVehicle];
}

class VehicleSwitchSuccess extends VehicleManagementState {
  final int newActiveVehicleId;
  final String successMessage;
  const VehicleSwitchSuccess(
      {required this.newActiveVehicleId, required this.successMessage});
  @override
  List<Object?> get props => [newActiveVehicleId, successMessage];
}

class VehicleActionFailure extends VehicleManagementState {
  final Failure failure;
  final List<Vehicle> lastKnownVehicles;
  final int? lastKnownActiveVehicleId;

  const VehicleActionFailure({
    required this.failure,
    this.lastKnownVehicles = const [],
    this.lastKnownActiveVehicleId,
  });
  @override
  List<Object?> get props =>
      [failure, lastKnownVehicles, lastKnownActiveVehicleId];
}

class VehicleDeleteSuccess extends VehicleManagementState {
  final String message;
  final String deletedVehicleId;
  const VehicleDeleteSuccess(
      {required this.message, required this.deletedVehicleId});
  @override
  List<Object?> get props => [message, deletedVehicleId];
}
