import 'dart:io';

import 'package:dio/dio.dart';

import '../../errors/exceptions.dart';
import '../../services/logger_service.dart';

/// ──────────────────────────────────────────────────────────────────────────────
/// Error Interceptor
///
/// Centralised error handling interceptor that converts Dio errors into
/// application-specific exceptions for consistent error propagation.
/// ──────────────────────────────────────────────────────────────────────────────
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    LoggerService.instance.error(
      'API Error: ${err.requestOptions.method} ${err.requestOptions.path}',
      error: err,
    );

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw const NetworkException(
          message: 'Connection timed out. Please try again.',
        );

      case DioExceptionType.connectionError:
        throw const NetworkException(
          message:
              'Unable to connect to server. Check your internet connection.',
        );

      case DioExceptionType.badCertificate:
        throw const ServerException(
          message: 'SSL certificate verification failed.',
          statusCode: 495,
        );

      case DioExceptionType.badResponse:
        _handleBadResponse(err);
        break;

      case DioExceptionType.cancel:
        throw const ServerException(message: 'Request was cancelled.');

      case DioExceptionType.unknown:
        if (err.error is SocketException) {
          throw const NetworkException(message: 'No internet connection.');
        }
        throw ServerException(
          message: err.message ?? 'An unexpected error occurred.',
        );
    }

    handler.next(err);
  }

  /// Parses bad response status codes into specific exceptions.
  void _handleBadResponse(DioException err) {
    final statusCode = err.response?.statusCode;
    final data = err.response?.data;

    // Try to extract error message from the response body
    String message = 'Server error occurred.';
    if (data is Map<String, dynamic>) {
      message =
          data['message'] as String? ?? data['error'] as String? ?? message;
    }

    switch (statusCode) {
      case 400:
        throw ServerException(message: message, statusCode: 400);
      case 401:
        throw AuthenticationException(message: message);
      case 403:
        throw const ServerException(
          message: 'Access denied. You do not have permission.',
          statusCode: 403,
        );
      case 404:
        throw const ServerException(
          message: 'The requested resource was not found.',
          statusCode: 404,
        );
      case 409:
        throw ServerException(message: message, statusCode: 409);
      case 422:
        throw ServerException(message: message, statusCode: 422);
      case 429:
        throw const ServerException(
          message: 'Too many requests. Please wait a moment.',
          statusCode: 429,
        );
      case 500:
      case 502:
      case 503:
        throw const ServerException(
          message: 'Server is temporarily unavailable. Please try again later.',
          statusCode: 500,
        );
      default:
        throw ServerException(message: message, statusCode: statusCode);
    }
  }
}
