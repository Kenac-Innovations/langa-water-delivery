import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_driver/bloc/auth/auth_bloc/auth_bloc_event.dart';
import 'package:langas_driver/bloc/auth/auth_bloc/auth_bloc_state.dart';
import 'package:langas_driver/services/secure_storage.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  //
  final SecureStorageService _secureStorageService;

  AuthBloc({
    required SecureStorageService secureStorageService,
  })  : _secureStorageService = secureStorageService, //
        super(AuthInitial()) {
    on<AuthDriverAppStarted>(_onAppStarted);
    on<AuthDriverLoggedIn>(_onLoggedIn);
    on<AuthDriverLoggedOut>(_onLoggedOut);
  }

  Future<void> _onAppStarted(
      AuthDriverAppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final storedAuthData = await _secureStorageService.getAuthData();
    if (storedAuthData != null) {
      emit(AuthDriverAuthenticated(authData: storedAuthData));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoggedIn(
      AuthDriverLoggedIn event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _secureStorageService.saveAuthData(event.authData);
    event.authData.driverProfile?.id;
    print(event.authData.driverProfile?.id);
    print('Driver Id is');
    emit(AuthDriverAuthenticated(authData: event.authData));
  }

  Future<void> _onLoggedOut(
      AuthDriverLoggedOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading()); // Briefly show loading while clearing
    await _secureStorageService.deleteAuthData();
    emit(AuthUnauthenticated());
  }
}
