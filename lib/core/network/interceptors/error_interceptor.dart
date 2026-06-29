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
          message: 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى.',
        );

      case DioExceptionType.connectionError:
        throw const NetworkException(
          message:
              'تعذر الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت.',
        );

      case DioExceptionType.badCertificate:
        throw const ServerException(
          message: 'فشل التحقق من شهادة الأمان.',
          statusCode: 495,
        );

      case DioExceptionType.badResponse:
        _handleBadResponse(err);
        break;

      case DioExceptionType.cancel:
        throw const ServerException(message: 'تم إلغاء الطلب.');

      case DioExceptionType.unknown:
        if (err.error is SocketException) {
          throw const NetworkException(message: 'لا يوجد اتصال بالإنترنت.');
        }
        throw ServerException(
          message: err.message ?? 'حدث خطأ غير متوقع. يرجى المحاولة لاحقاً.',
        );
    }

    handler.next(err);
  }

  /// Parses bad response status codes into specific exceptions.
  void _handleBadResponse(DioException err) {
    final statusCode = err.response?.statusCode;
    final data = err.response?.data;

    // Try to extract error message from the response body
    String message = 'حدث خطأ في الخادم.';
    if (data is Map<String, dynamic>) {
      message =
          data['message'] as String? ?? data['error'] as String? ?? message;
    }

    // Map specific backend messages to user-friendly Arabic
    if (message == 'The provided credentials are incorrect.') {
      message = 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
    }

    switch (statusCode) {
      case 400:
        throw ServerException(message: message, statusCode: 400);
      case 401:
        throw AuthenticationException(message: message);
      case 403:
        throw const ServerException(
          message: 'غير مصرح لك بالوصول.',
          statusCode: 403,
        );
      case 404:
        throw const ServerException(
          message: 'عذراً، لم يتم العثور على طلبك.',
          statusCode: 404,
        );
      case 409:
        throw ServerException(message: message, statusCode: 409);
      case 422:
        throw ServerException(message: message, statusCode: 422);
      case 429:
        throw const ServerException(
          message: 'الكثير من الطلبات. يرجى الانتظار قليلاً.',
          statusCode: 429,
        );
      case 500:
      case 502:
      case 503:
        throw const ServerException(
          message: 'الخادم غير متوفر حالياً. يرجى المحاولة مرة أخرى لاحقاً.',
          statusCode: 500,
        );
      default:
        throw ServerException(message: message, statusCode: statusCode);
    }
  }
}
