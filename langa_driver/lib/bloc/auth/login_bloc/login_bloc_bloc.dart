import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_driver/bloc/auth/auth_bloc/auth_bloc_bloc.dart';
import 'package:langas_driver/bloc/auth/auth_bloc/auth_bloc_event.dart';
import 'package:langas_driver/bloc/auth/login_bloc/login_bloc_event.dart';
import 'package:langas_driver/bloc/auth/login_bloc/login_bloc_state.dart';
import 'package:langas_driver/models/auth_models.dart';
import 'package:langas_driver/repository/auth_repository.dart';
import 'package:langas_driver/utils/api_response_model.dart';
import 'package:langas_driver/utils/failure_models.dart';

class DriverLoginBloc extends Bloc<DriverLoginEvent, DriverLoginState> {
  final AuthRepository _authRepository;
  final AuthBloc _authBloc;

  DriverLoginBloc({
    required AuthRepository authRepository,
    required AuthBloc authBloc,
  })  : _authRepository = authRepository,
        _authBloc = authBloc,
        super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
      LoginSubmitted event, Emitter<DriverLoginState> emit) async {
    emit(LoginLoading());
    final Either<Failure, ApiResponse<AuthResponseData>> result =
        await _authRepository.login(event.request);

    result.fold(
      (failure) {
        if (failure is AuthFailure &&
            (failure.statusCode == 403 || failure.statusCode == 400) &&
            failure.message.toLowerCase().contains("verify your account")) {
          emit(LoginRequiresOtpVerification(loginId: event.request.loginId));
        } else {
          emit(LoginFailure(failure: failure));
        }
      },
      (apiResponse) {
        if (apiResponse.success && apiResponse.data != null) {
          if (apiResponse.data!.driverProfile != null) {
            emit(LoginSuccess(authData: apiResponse.data!));
            _authBloc.add(AuthDriverLoggedIn(authData: apiResponse.data!));
          } else {
            emit(LoginRequiresOtpVerification(loginId: event.request.loginId));
          }
        } else {
          if (!apiResponse.success &&
              apiResponse.message
                  .toLowerCase()
                  .contains("verify your account")) {
            emit(LoginRequiresOtpVerification(loginId: event.request.loginId));
          } else {
            emit(LoginFailure(
                failure: ServerFailure(
                    message: apiResponse.message,
                    statusCode: apiResponse.success ? 200 : 400)));
          }
        }
      },
    );
  }
}
