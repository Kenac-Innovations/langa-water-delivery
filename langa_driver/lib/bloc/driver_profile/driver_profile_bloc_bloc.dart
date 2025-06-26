import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:langas_driver/bloc/auth/auth_bloc/auth_bloc_bloc.dart';
import 'package:langas_driver/bloc/auth/auth_bloc/auth_bloc_event.dart';
import 'package:langas_driver/bloc/driver_profile/driver_profile_bloc_event.dart';
import 'package:langas_driver/bloc/driver_profile/driver_profile_bloc_state.dart';
import 'package:langas_driver/models/auth_models.dart';
import 'package:langas_driver/repository/auth_repository.dart';
import 'package:langas_driver/utils/api_response_model.dart';
import 'package:langas_driver/utils/failure_models.dart';

class DriverProfileBloc extends Bloc<DriverProfileEvent, DriverProfileState> {
  final AuthRepository _authRepository;
  final AuthBloc _authBloc;

  DriverProfileBloc(
      {required AuthRepository authRepository, required AuthBloc authBloc})
      : _authRepository = authRepository,
        _authBloc = authBloc,
        super(DriverProfileInitial()) {
    on<LoadDriverProfile>(_onLoadDriverProfile);
    on<DeleteDriverProfile>(_onDeleteDriverProfile);
    on<UpdateWorkStatus>(_onUpdateWorkStatus);
  }

  Future<void> _onLoadDriverProfile(
      LoadDriverProfile event, Emitter<DriverProfileState> emit) async {
    emit(DriverProfileLoading());
    final Either<Failure, ApiResponse<DriverProfile>> result =
        await _authRepository.getDriverProfile(event.driverId);

    result.fold(
      (failure) => emit(DriverProfileLoadFailure(failure: failure)),
      (apiResponse) {
        if (apiResponse.success && apiResponse.data != null) {
          emit(DriverProfileLoadSuccess(driverProfile: apiResponse.data!));
        } else {
          emit(DriverProfileLoadFailure(
              failure: ServerFailure(message: apiResponse.message)));
        }
      },
    );
  }

  Future<void> _onUpdateWorkStatus(
      UpdateWorkStatus event, Emitter<DriverProfileState> emit) async {
    emit(DriverProfileLoading());
    final Either<Failure, ApiResponse<DriverProfile>> result =
        await _authRepository.updateWorkStatus(event.driverId, event.status);

    result.fold(
      (failure) => emit(UpdateStatusFailure(failure: failure)),
      (apiResponse) {
        if (apiResponse.success) {
          emit(UpdateWorkStatusSuccess(message: apiResponse.message));
          emit(DriverProfileLoadSuccess(driverProfile: apiResponse.data!));
          // Reload the driver profile to get updated status
          // todo  here update
          //add(LoadDriverProfile(driverId: event.driverId.toString()));
        } else {
          emit(UpdateStatusFailure(
              failure: ServerFailure(message: apiResponse.message)));
        }
      },
    );
  }

  Future<void> _onDeleteDriverProfile(
      DeleteDriverProfile event, Emitter<DriverProfileState> emit) async {
    emit(DriverProfileDeleteInProgress());
    final Either<Failure, ApiResponse<String>> result =
        await _authRepository.deleteDriverProfile(event.driverId);

    result.fold(
      (failure) => emit(DriverProfileDeleteFailure(failure: failure)),
      (apiResponse) {
        if (apiResponse.success) {
          emit(DriverProfileDeleteSuccess(
              message: apiResponse.data ?? apiResponse.message));
          _authBloc.add(AuthDriverLoggedOut());
        } else {
          emit(DriverProfileDeleteFailure(
              failure: ServerFailure(message: apiResponse.message)));
        }
      },
    );
  }
}
