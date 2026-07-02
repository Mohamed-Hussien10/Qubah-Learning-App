import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qubah_learning_app/core/utils/usecase.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../../domain/usecases/logout_usecase.dart';
import '../state/auth_state.dart';
import 'package:qubah_learning_app/core/errors/error_handler.dart';

/// Cubit managing authentication state.
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
  }) : _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase,
       super(AuthInitial());

  /// Attempts to log in with the given credentials.
  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      final user = await _loginUseCase(
        LoginParams(email: email, password: password),
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(ErrorHandler.handle(e)));
    }
  }

  /// Logs out the current user.
  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _logoutUseCase(NoParams());
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(ErrorHandler.handle(e)));
    }
  }
}
