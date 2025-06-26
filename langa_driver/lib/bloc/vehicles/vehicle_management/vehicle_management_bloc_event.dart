import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:langas_driver/dto/vehicle_dto.dart';

@immutable
abstract class VehicleManagementEvent extends Equatable {
  const VehicleManagementEvent();
  @override
  List<Object?> get props => [];
}

class LoadDriverVehicles extends VehicleManagementEvent {
  final String driverId;
  const LoadDriverVehicles({required this.driverId});
  @override
  List<Object?> get props => [driverId];
}

class AddVehicle extends VehicleManagementEvent {
  final String driverId;
  final CreateVehicleRequest request;
  const AddVehicle({required this.driverId, required this.request});
  @override
  List<Object?> get props => [driverId, request];
}

class SetActiveVehicle extends VehicleManagementEvent {
  final String driverId;
  final String vehicleId;
  const SetActiveVehicle({required this.driverId, required this.vehicleId});
  @override
  List<Object?> get props => [driverId, vehicleId];
}

class DeleteVehicleRequested extends VehicleManagementEvent {
  final String driverId;
  final String vehicleId;
  const DeleteVehicleRequested(
      {required this.driverId, required this.vehicleId});
  @override
  List<Object?> get props => [driverId, vehicleId];
}
