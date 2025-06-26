import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_driver/bloc/auth/otp_verification/otp_verification_bloc_event.dart';
import 'package:langas_driver/bloc/auth/otp_verification/otp_verification_bloc_state.dart';
import 'package:langas_driver/repository/auth_repository.dart';

class VerifyAccountBloc extends Bloc<VerifyAccountEvent, VerifyAccountState> {
  final AuthRepository _authRepository;

  VerifyAccountBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(VerifyAccountInitial()) {
    on<VerifyAccountSubmitted>(_onVerifyAccountSubmitted);
  }

  Future<void> _onVerifyAccountSubmitted(
      VerifyAccountSubmitted event, Emitter<VerifyAccountState> emit) async {
    emit(VerifyAccountLoading());
    final result =
        await _authRepository.verifyAccount(event.verifyAccountRequestDto);
    result.fold(
      (failure) => emit(VerifyAccountFailure(failure: failure)),
      (message) => emit(VerifyAccountSuccess(message: message)),
    );
  }
}
