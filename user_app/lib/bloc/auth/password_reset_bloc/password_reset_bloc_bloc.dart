import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_user/bloc/auth/password_reset_bloc/password_reset_bloc_event.dart';
import 'package:langas_user/bloc/auth/password_reset_bloc/password_reset_bloc_state.dart';
import 'package:langas_user/repository/auth_repository.dart';

class PasswordResetBloc extends Bloc<PasswordResetEvent, PasswordResetState> {
  final AuthRepository _authRepository;

  PasswordResetBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(PasswordResetInitial()) {
    on<PasswordResetSubmitted>(_onPasswordResetSubmitted);
  }

  Future<void> _onPasswordResetSubmitted(
      PasswordResetSubmitted event, Emitter<PasswordResetState> emit) async {
    emit(PasswordResetLoading());
    final result =
        await _authRepository.resetPassword(event.resetPasswordRequestDto);
    result.fold(
      (failure) => emit(PasswordResetFailure(failure: failure)),
      (message) => emit(PasswordResetSuccess(message: message)),
    );
  }
}
