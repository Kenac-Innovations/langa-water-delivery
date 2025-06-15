import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_event.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_state.dart';
import 'package:langas_user/models/auth_response_model.dart';
import 'package:langas_user/repository/auth_repository.dart';
import 'package:langas_user/services/fcm_service.dart';
import 'package:langas_user/services/secure_storage.dart';
import 'dart:async';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final SecureStorageService _storageService;
  final FCMService _fcmService;

  AuthBloc({
    required AuthRepository authRepository,
    required SecureStorageService storageService,
    required FCMService fcmService,
  })  : _authRepository = authRepository,
        _storageService = storageService,
        _fcmService = fcmService,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoggedIn>(_onAuthLoggedIn);
    on<AuthLoggedOut>(_onAuthLoggedOut);
  }

  Future<void> _onAuthCheckRequested(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final AuthResult? authResult = await _storageService.getAuthResult();

    if (authResult != null && authResult.accessToken.isNotEmpty) {
      // Implement check to see if the token is still valid

      emit(Authenticated(user: authResult.userProfile));
      await _fcmService.registerTokenForUser(authResult.userID.toString());
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onAuthLoggedIn(
      AuthLoggedIn event, Emitter<AuthState> emit) async {
    emit(Authenticated(user: event.authResult.userProfile));
    await _fcmService.registerTokenForUser(
      event.authResult.userID.toString(),
      forceSend: true,
    );
  }

  Future<void> _onAuthLoggedOut(
      AuthLoggedOut event, Emitter<AuthState> emit) async {
    await _authRepository.logout();
    await _fcmService.handleLogout();
    emit(Unauthenticated());
  }
}
