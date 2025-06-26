import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_driver/bloc/auth/driver_registration_bloc/driver_registration_bloc_event.dart';
import 'package:langas_driver/bloc/auth/driver_registration_bloc/driver_registration_bloc_state.dart';
import 'package:langas_driver/models/auth_models.dart';
import 'package:langas_driver/repository/auth_repository.dart';
import 'package:langas_driver/utils/api_response_model.dart';
import 'package:langas_driver/utils/failure_models.dart';

class DriverRegistrationBloc
    extends Bloc<DriverRegistrationEvent, DriverRegistrationState> {
  final AuthRepository _authRepository;

  DriverRegistrationBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(RegistrationInitial()) {
    on<RegisterDriverSubmitted>(_onRegisterDriverSubmitted);
  }

  Future<void> _onRegisterDriverSubmitted(RegisterDriverSubmitted event,
      Emitter<DriverRegistrationState> emit) async {
    emit(RegistrationLoading());
    final Either<Failure, ApiResponse<DriverRegistrationResponseData>> result =
        await _authRepository.registerDriver(event.request);

    result.fold(
      (failure) => emit(RegistrationFailure(failure: failure)),
      (apiResponse) {
        if (apiResponse.success && apiResponse.data != null) {
          emit(RegistrationSuccess(responseData: apiResponse.data!));
        } else {
          emit(RegistrationFailure(
              failure: ServerFailure(message: apiResponse.message)));
        }
      },
    );
  }
}
