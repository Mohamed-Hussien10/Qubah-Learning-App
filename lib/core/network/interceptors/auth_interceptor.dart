import 'dart:async';
import 'package:dio/dio.dart';

import '../../storage/secure_storage.dart';
import '../../services/logger_service.dart';
import '../api_endpoints.dart';

/// ──────────────────────────────────────────────────────────────────────────────
/// Auth Interceptor
///
/// Automatically attaches the Bearer token to outgoing requests and handles
/// 401 responses by attempting a token refresh. If the refresh also fails,
/// it clears the stored tokens and signals a forced logout.
/// ──────────────────────────────────────────────────────────────────────────────
class AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage;

  AuthInterceptor({required SecureStorage secureStorage})
    : _secureStorage = secureStorage;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for login/register endpoints
    final noAuthPaths = [
      ApiEndpoints.login,
      ApiEndpoints.register,
    ];

    if (!noAuthPaths.contains(options.path)) {
      final token = await _secureStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // On 401 Unauthorized, clear stored tokens and force logout
    if (err.response?.statusCode == 401) {
      await _forceLogout();
    }

    handler.next(err);
  }

  /// Clears all stored tokens and triggers a logout flow.
  Future<void> _forceLogout() async {
    await _secureStorage.clearAll();
    LoggerService.instance.warning('Forced logout: tokens cleared');
    // The app should listen for auth state changes and redirect to login
  }
}
