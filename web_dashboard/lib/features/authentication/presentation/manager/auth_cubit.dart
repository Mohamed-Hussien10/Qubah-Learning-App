import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:web_dashboard/features/authentication/data/repositories/auth_repository.dart';
import 'package:web_dashboard/features/authentication/presentation/manager/auth_state.dart';
import 'package:web_dashboard/core/errors/error_handler.dart';

/// Cubit managing authentication state.
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial());

  /// Check whether the user already has an active session.
  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());

    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final admin = await _authRepository.getCurrentAdmin();
        if (admin != null) {
          emit(AuthAuthenticated(admin: admin));
          return;
        }
      }
      emit(const AuthInitial());
    } catch (e) {
      emit(const AuthInitial());
    }
  }

  /// Attempt to log in with [email] and [password].
  Future<void> login(String email, String password) async {
    emit(const AuthLoading());

    try {
      final admin = await _authRepository.login(email, password);
      emit(AuthAuthenticated(admin: admin));
    } catch (e) {
      emit(AuthError(message: ErrorHandler.handle(e)));
    }
  }

  /// Log out the current user and reset state.
  Future<void> logout() async {
    emit(const AuthLoading());

    try {
      await _authRepository.logout();
      emit(const AuthInitial());
    } catch (e) {
      emit(AuthError(message: ErrorHandler.handle(e)));
    }
  }
}
