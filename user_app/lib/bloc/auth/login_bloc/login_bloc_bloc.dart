import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_user/bloc/auth/login_bloc/login_bloc_event.dart';
import 'package:langas_user/bloc/auth/login_bloc/login_bloc_state.dart';
import 'package:langas_user/repository/auth_repository.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;

  LoginBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(LoginInitial()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
  }

  Future<void> _onLoginButtonPressed(
      LoginButtonPressed event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    final result = await _authRepository.login(event.loginRequestDto);
    result.fold(
      (failure) => emit(LoginFailure(failure: failure)),
      (authResult) => emit(LoginSuccess(authResult: authResult)),
    );
  }
}
