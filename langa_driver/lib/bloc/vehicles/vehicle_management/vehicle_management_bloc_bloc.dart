import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:langas_driver/bloc/vehicles/vehicle_management/vehicle_management_bloc_event.dart';
import 'package:langas_driver/bloc/vehicles/vehicle_management/vehicle_management_bloc_state.dart';
import 'package:langas_driver/models/vehicle_model.dart';
import 'package:langas_driver/repository/vehicle_repository.dart';
import 'package:langas_driver/utils/api_response_model.dart';
import 'package:langas_driver/utils/failure_models.dart';

class VehicleManagementBloc
    extends Bloc<VehicleManagementEvent, VehicleManagementState> {
  final VehicleRepository _vehicleRepository;

  List<Vehicle> _currentVehicles = [];
  int? _currentActiveId;

  VehicleManagementBloc({required VehicleRepository vehicleRepository})
      : _vehicleRepository = vehicleRepository,
        super(VehicleInitial()) {
    on<LoadDriverVehicles>(_onLoadDriverVehicles);
    on<AddVehicle>(_onAddVehicle);
    on<SetActiveVehicle>(_onSetActiveVehicle);
    on<DeleteVehicleRequested>(_onDeleteVehicleRequested);
  }

  Future<void> _onLoadDriverVehicles(
      LoadDriverVehicles event, Emitter<VehicleManagementState> emit) async {
    emit(VehicleLoading());
    final Either<Failure, ApiResponse<List<Vehicle>>> result =
        await _vehicleRepository.getDriverVehicles(event.driverId);

    result.fold(
      (failure) {
        _currentVehicles = [];
        _currentActiveId = null;
        emit(VehicleListLoadFailure(failure: failure));
      },
      (apiResponse) {
        if (apiResponse.success && apiResponse.data != null) {
          final vehicles = apiResponse.data!;
          _currentVehicles = vehicles;
          try {
            _currentActiveId = vehicles.firstWhere((v) => v.active).vehicleId;
          } catch (_) {
            _currentActiveId = null;
          }
          emit(VehicleListLoadSuccess(
              vehicles: vehicles, activeVehicleId: _currentActiveId));
        } else {
          _currentVehicles = [];
          _currentActiveId = null;
          emit(VehicleListLoadFailure(
              failure: ServerFailure(message: apiResponse.message)));
        }
      },
    );
  }

  Future<void> _onAddVehicle(
      AddVehicle event, Emitter<VehicleManagementState> emit) async {
    emit(VehicleActionInProgress());
    final Either<Failure, ApiResponse<Vehicle>> result =
        await _vehicleRepository.createVehicle(event.driverId, event.request);

    result.fold(
      (failure) => emit(VehicleActionFailure(
          failure: failure,
          lastKnownVehicles: _currentVehicles,
          lastKnownActiveVehicleId: _currentActiveId)),
      (apiResponse) {
        if (apiResponse.success && apiResponse.data != null) {
          emit(VehicleCreateSuccess(newVehicle: apiResponse.data!));
          add(LoadDriverVehicles(driverId: event.driverId));
        } else {
          emit(VehicleActionFailure(
              failure: ServerFailure(message: apiResponse.message),
              lastKnownVehicles: _currentVehicles,
              lastKnownActiveVehicleId: _currentActiveId));
        }
      },
    );
  }

  Future<void> _onSetActiveVehicle(
      SetActiveVehicle event, Emitter<VehicleManagementState> emit) async {
    emit(VehicleActionInProgress());
    final Either<Failure, ApiResponse<String>> result = await _vehicleRepository
        .switchActiveVehicle(event.driverId as String, event.vehicleId);

    result.fold(
      (failure) => emit(VehicleActionFailure(
          failure: failure,
          lastKnownVehicles: _currentVehicles,
          lastKnownActiveVehicleId: _currentActiveId)),
      (apiResponse) {
        if (apiResponse.success) {
          final newActiveId = int.tryParse(event.vehicleId);
          final message = apiResponse.data ?? apiResponse.message;

          emit(VehicleSwitchSuccess(
              newActiveVehicleId: newActiveId ?? -1, successMessage: message));
          add(LoadDriverVehicles(driverId: event.driverId));
        } else {
          emit(VehicleActionFailure(
              failure: ServerFailure(message: apiResponse.message),
              lastKnownVehicles: _currentVehicles,
              lastKnownActiveVehicleId: _currentActiveId));
        }
      },
    );
  }

  Future<void> _onDeleteVehicleRequested(DeleteVehicleRequested event,
      Emitter<VehicleManagementState> emit) async {
    emit(VehicleActionInProgress());
    final Either<Failure, ApiResponse<String>> result =
        await _vehicleRepository.deleteVehicle(event.driverId, event.vehicleId);

    result.fold(
      (failure) => emit(VehicleActionFailure(
          failure: failure,
          lastKnownVehicles: _currentVehicles,
          lastKnownActiveVehicleId: _currentActiveId)),
      (apiResponse) {
        if (apiResponse.success) {
          emit(VehicleDeleteSuccess(
              message: apiResponse.data ?? apiResponse.message,
              deletedVehicleId: event.vehicleId));
          add(LoadDriverVehicles(driverId: event.driverId));
        } else {
          emit(VehicleActionFailure(
              failure: ServerFailure(message: apiResponse.message),
              lastKnownVehicles: _currentVehicles,
              lastKnownActiveVehicleId: _currentActiveId));
        }
      },
    );
  }
}
