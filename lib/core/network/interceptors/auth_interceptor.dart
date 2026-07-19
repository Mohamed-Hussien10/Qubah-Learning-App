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
  final Dio _refreshDio;
  Completer<String>? _refreshCompleter;

  AuthInterceptor({required SecureStorage secureStorage})
    : _secureStorage = secureStorage,
      _refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          connectTimeout: ApiEndpoints.connectTimeout,
          receiveTimeout: ApiEndpoints.receiveTimeout,
        ),
      );

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for login/register/refresh endpoints
    final noAuthPaths = [
      ApiEndpoints.login,
      ApiEndpoints.register,
      ApiEndpoints.refreshToken,
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
    // Only attempt refresh on 401 Unauthorized responses
    if (err.response?.statusCode == 401) {
      if (_refreshCompleter != null) {
        // Wait for the ongoing refresh
        try {
          final newAccessToken = await _refreshCompleter!.future;
          err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          final retryResponse = await _refreshDio.fetch(err.requestOptions);
          handler.resolve(retryResponse);
        } catch (e) {
          handler.next(err);
        }
        return;
      }

      _refreshCompleter = Completer<String>();

      try {
        final refreshToken = await _secureStorage.getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          await _forceLogout();
          _refreshCompleter?.completeError(Exception('No refresh token'));
          _refreshCompleter = null;
          handler.next(err);
          return;
        }

        // Attempt token refresh
        final response = await _refreshDio.post(
          ApiEndpoints.refreshToken,
          data: {'refresh_token': refreshToken},
        );

        if (response.statusCode == 200) {
          final newAccessToken =
              response.data['data']['access_token'] as String;
          final newRefreshToken =
              response.data['data']['refresh_token'] as String;

          // Store new tokens
          await _secureStorage.saveAccessToken(newAccessToken);
          await _secureStorage.saveRefreshToken(newRefreshToken);

          // Retry the original request with new token
          err.requestOptions.headers['Authorization'] =
              'Bearer $newAccessToken';

          final retryResponse = await _refreshDio.fetch(err.requestOptions);
          
          _refreshCompleter?.complete(newAccessToken);
          _refreshCompleter = null;
          
          handler.resolve(retryResponse);
          return;
        } else {
          await _forceLogout();
          _refreshCompleter?.completeError(Exception('Refresh failed'));
          _refreshCompleter = null;
        }
      } catch (e) {
        LoggerService.instance.error('Token refresh failed', error: e);
        await _forceLogout();
        _refreshCompleter?.completeError(e);
        _refreshCompleter = null;
      }
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
