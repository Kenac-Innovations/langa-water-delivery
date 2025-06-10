import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_user/bloc/auth/register_bloc/register_bloc_event.dart';
import 'package:langas_user/bloc/auth/register_bloc/register_bloc_state.dart';
import 'package:langas_user/repository/auth_repository.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository _authRepository;

  RegisterBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  Future<void> _onRegisterSubmitted(
      RegisterSubmitted event, Emitter<RegisterState> emit) async {
    emit(RegisterLoading());
    final result = await _authRepository.register(event.registerRequestDto);
    result.fold(
      (failure) => emit(RegisterFailure(failure: failure)),
      (registerData) =>
          emit(RegisterSuccess(registerResponseDataDto: registerData)),
    );
  }
}
