import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_user/bloc/auth/password_reset_bloc/password_reset_bloc_event.dart';
import 'package:langas_user/bloc/auth/password_reset_bloc/password_reset_bloc_state.dart';
import 'package:langas_user/repository/auth_repository.dart';

class PasswordResetBloc extends Bloc<PasswordResetEvent, PasswordResetState> {
  final AuthRepository authRepository;

  PasswordResetBloc({required this.authRepository})
      : super(PasswordResetInitial()) {
    on<PasswordResetOtpRequested>(_onOtpRequested);
    on<PasswordResetOtpVerified>(_onOtpVerified);
    on<PasswordResetAnswersVerified>(_onAnswersVerified);
    on<PasswordResetSubmitted>(_onResetSubmitted);
  }

  Future<void> _onOtpRequested(
      PasswordResetOtpRequested event, Emitter<PasswordResetState> emit) async {
    emit(PasswordResetLoading());
    final result = await authRepository.requestPasswordResetOtp(event.dto);
    result.fold(
      (failure) => emit(PasswordResetFailure(failure: failure)),
      (_) => emit(PasswordResetOtpSent()),
    );
  }

  Future<void> _onOtpVerified(
      PasswordResetOtpVerified event, Emitter<PasswordResetState> emit) async {
    emit(PasswordResetLoading());
    final result = await authRepository.verifyPasswordResetOtp(event.dto);
    result.fold(
      (failure) => emit(PasswordResetFailure(failure: failure)),
      (response) => emit(
          PasswordResetQuestionsLoaded(questions: response.securityQuestions)),
    );
  }

  Future<void> _onAnswersVerified(PasswordResetAnswersVerified event,
      Emitter<PasswordResetState> emit) async {
    emit(PasswordResetLoading());
    final result = await authRepository.verifySecurityAnswers(event.dto);
    result.fold(
      (failure) => emit(PasswordResetFailure(failure: failure)),
      (token) => emit(PasswordResetTokenLoaded(token: token)),
    );
  }

  Future<void> _onResetSubmitted(
      PasswordResetSubmitted event, Emitter<PasswordResetState> emit) async {
    emit(PasswordResetLoading());
    final result = await authRepository.resetPasswordWithToken(event.dto);
    result.fold(
      (failure) => emit(PasswordResetFailure(failure: failure)),
      (_) => emit(PasswordResetSuccess()),
    );
  }
}
