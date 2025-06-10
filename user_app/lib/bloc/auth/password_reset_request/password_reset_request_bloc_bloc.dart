import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_user/bloc/auth/password_reset_request/password_reset_request_bloc_event.dart';
import 'package:langas_user/bloc/auth/password_reset_request/password_reset_request_bloc_state.dart';
import 'package:langas_user/repository/auth_repository.dart';

class PasswordResetRequestBloc
    extends Bloc<PasswordResetRequestEvent, PasswordResetRequestState> {
  final AuthRepository _authRepository;

  PasswordResetRequestBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(PasswordResetRequestInitial()) {
    on<PasswordResetLinkRequested>(_onPasswordResetLinkRequested);
  }

  Future<void> _onPasswordResetLinkRequested(PasswordResetLinkRequested event,
      Emitter<PasswordResetRequestState> emit) async {
    emit(PasswordResetRequestLoading());
    // Assuming authRepository.requestPasswordLink now returns Either<Failure, String> (message)
    final result = await _authRepository.requestPasswordLink(event.loginId);
    result.fold(
      (failure) => emit(PasswordResetRequestFailure(failure: failure)),
      // Emit success state with the confirmation message
      (message) => emit(PasswordResetRequestSuccess(message: message)),
    );
  }
}
