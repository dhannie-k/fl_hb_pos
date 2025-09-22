import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../auth_service/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthenState> {
  final AuthRepository _authRepository;
  StreamSubscription<AuthState>? _authStateSubscription;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthAppStarted>(_onAppStarted);
    on<AuthSignInWithGoogleRequested>(_onSignInWithGoogle);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthUserChanged>(_onUserChanged);

    // Listen to the stream from the repository
    _authStateSubscription = _authRepository.authStateChanges.listen((authState) {
      add(AuthUserChanged(authState.session?.user));
    });
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }

  void _onAppStarted(AuthAppStarted event, Emitter<AuthenState> emit) {
    final currentUser = _authRepository.currentUser;
    if (currentUser != null) {
      emit(AuthAuthenticated(currentUser));
    } else {
      emit(AuthUnauthenticated());
    }
  }
  
  void _onUserChanged(AuthUserChanged event, Emitter<AuthenState> emit) {
    if (event.user != null) {
      emit(AuthAuthenticated(event.user!));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSignInWithGoogle(
      AuthSignInWithGoogleRequested event, Emitter<AuthenState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.signInWithGoogle();
      // The _authStateSubscription will automatically trigger a state change to AuthAuthenticated
    } catch (e) {
      emit(AuthError(e.toString()));
      // Ensure we revert to unauthenticated state after an error
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSignOut(
      AuthSignOutRequested event, Emitter<AuthenState> emit) async {
    // No loading state needed for sign out, it's usually instant
    await _authRepository.signOut();
    // The stream will automatically emit AuthUnauthenticated
  }
}