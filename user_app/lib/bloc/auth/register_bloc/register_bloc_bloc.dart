import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_user/bloc/auth/register_bloc/register_bloc_event.dart';
import 'package:langas_user/bloc/auth/register_bloc/register_bloc_state.dart';
import 'package:langas_user/repository/auth_repository.dart';
import 'package:langas_user/util/api_failure_models.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository _authRepository;

  RegisterBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(RegisterInitial()) {
    on<RegisterOtpRequested>(_onRegisterOtpRequested);
    on<RegisterOtpValidated>(_onRegisterOtpValidated);
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  Future<void> _onRegisterOtpRequested(
      RegisterOtpRequested event, Emitter<RegisterState> emit) async {
    emit(RegisterOtpLoading());
    final result = await _authRepository.requestOtp(event.dto);
    result.fold(
      (failure) => emit(RegisterOtpFailure(failure: failure)),
      (_) => emit(RegisterOtpSuccess()),
    );
  }

  Future<void> _onRegisterOtpValidated(
      RegisterOtpValidated event, Emitter<RegisterState> emit) async {
    emit(RegisterOtpValidationLoading());
    final result = await _authRepository.validateOtp(event.dto);
    await result.fold(
      (failure) async => emit(RegisterOtpValidationFailure(failure: failure)),
      (isValid) async {
        if (isValid) {
          final questionsResult = await _authRepository.getRandomSecurityQuestions();
          questionsResult.fold(
            (failure) => emit(RegisterOtpValidationFailure(failure: failure)),
            (questions) => emit(RegisterOtpValidationSuccess(questions: questions)),
          );
        } else {
          emit(const RegisterOtpValidationFailure(
              failure: AuthFailure(message: 'The OTP entered is invalid.')));
        }
      },
    );
  }

  Future<void> _onRegisterSubmitted(
      RegisterSubmitted event, Emitter<RegisterState> emit) async {
    emit(RegisterLoading());
    final result = await _authRepository.register(event.dto);
    result.fold(
      (failure) => emit(RegisterFailure(failure: failure)),
      (authResult) => emit(RegisterSuccess(authResult: authResult)),
    );
  }
}