import 'dart:async';
import 'package:flutter/material.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_bloc.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_state.dart';

// Simple ChangeNotifier that listens to AuthBloc state changes
class AuthChangeNotifier extends ChangeNotifier {
  final AuthBloc authBloc;
  late StreamSubscription _authSubscription;
  AuthState? _previousState;

  AuthChangeNotifier(this.authBloc) {
    // Listen to the AuthBloc's stream
    _authSubscription = authBloc.stream.listen((newState) {
      // Only notify if the core authentication status changes (e.g., Initial -> Unauthenticated)
      // This prevents unnecessary refreshes for states within the same auth status.
      if (_getAuthStatus(newState) != _getAuthStatus(_previousState)) {
        notifyListeners(); // Tell GoRouter to refresh
      }
      _previousState = newState;
    });
  }

  // Helper to determine the core auth status from the state type
  String _getAuthStatus(AuthState? state) {
    if (state is Authenticated) return 'authenticated';
    if (state is Unauthenticated) return 'unauthenticated';
    return 'initializing'; // Covers Initial and Loading
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
