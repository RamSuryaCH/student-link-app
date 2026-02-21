import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../../data/datasources/firebase_auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuthService _authService;
  final Logger _logger = Logger();

  AuthBloc(this._authService) : super(AuthInitial()) {
    on<SignInWithEmailRequested>(_onSignInWithEmail);
    on<SignUpRequested>(_onSignUp);
    on<SignOutRequested>(_onSignOut);
    on<AuthCheckRequested>(_onAuthCheck);
  }

  Future<void> _onSignInWithEmail(
    SignInWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authService.signInWithEmail(event.email, event.password);
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthError('Failed to sign in'));
      }
    } catch (e) {
      _logger.e('Sign in error: $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUp(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Validate email domain (must end with .edu)
      if (!event.email.toLowerCase().endsWith('.edu')) {
        emit(const AuthError('Please use a valid student email ending with .edu'));
        return;
      }

      final user = await _authService.signUpWithEmail(
        email: event.email,
        password: event.password,
        name: event.name,
        department: event.department,
      );
      
      emit(AuthAuthenticated(user));
    } catch (e) {
      _logger.e('Sign up error: $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOut(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authService.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      _logger.e('Sign out error: $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthCheck(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    // This is handled by the stream in main.dart
    emit(AuthInitial());
  }
}
