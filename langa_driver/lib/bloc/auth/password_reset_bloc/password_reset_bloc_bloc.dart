import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_driver/bloc/auth/password_reset_bloc/password_reset_bloc_event.dart';
import 'package:langas_driver/bloc/auth/password_reset_bloc/password_reset_bloc_state.dart';
import 'package:langas_driver/repository/auth_repository.dart';
import 'package:langas_driver/utils/api_response_model.dart';
import 'package:langas_driver/utils/failure_models.dart';

class PasswordResetBloc extends Bloc<PasswordResetEvent, PasswordResetState> {
  final AuthRepository _authRepository;

  PasswordResetBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(PasswordResetInitial()) {
    on<RequestResetLink>(_onRequestResetLink);
    on<SubmitPasswordReset>(_onSubmitPasswordReset);
  }

  Future<void> _onRequestResetLink(
      RequestResetLink event, Emitter<PasswordResetState> emit) async {
    emit(PasswordResetLoading());
    final Either<Failure, ApiResponse<String>> result =
        await _authRepository.requestPasswordLink(event.loginId);

    result.fold(
      (failure) => emit(PasswordResetFailure(failure: failure)),
      (apiResponse) {
        if (apiResponse.success) {
          emit(PasswordResetLinkSent());
        } else {
          emit(PasswordResetFailure(
              failure: ServerFailure(message: apiResponse.message)));
        }
      },
    );
  }

  Future<void> _onSubmitPasswordReset(
      SubmitPasswordReset event, Emitter<PasswordResetState> emit) async {
    emit(PasswordResetLoading());
    final Either<Failure, ApiResponse<void>> result =
        await _authRepository.resetPassword(event.request);

    result.fold(
      (failure) => emit(PasswordResetFailure(failure: failure)),
      (apiResponse) {
        if (apiResponse.success) {
          emit(PasswordResetSuccess());
        } else {
          emit(PasswordResetFailure(
              failure: ServerFailure(message: apiResponse.message)));
        }
      },
    );
  }
}
