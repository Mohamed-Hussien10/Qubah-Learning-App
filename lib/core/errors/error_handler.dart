import 'package:dio/dio.dart';
import 'exceptions.dart';
import 'failures.dart';

class ErrorHandler {
  static String handle(dynamic error) {
    if (error is DioException) {
      if (error.error != null) {
        return _extractMessage(error.error);
      }
      return 'حدث خطأ في الاتصال بالخادم.';
    }
    return _extractMessage(error);
  }

  static String _extractMessage(dynamic error) {
    if (error is ServerException) return error.message;
    if (error is NetworkException) return error.message;
    if (error is CacheException) return error.message;
    if (error is AuthenticationException) return error.message;
    if (error is ActivationException) return error.message;
    if (error is SubscriptionExpiredException) return error.message;
    if (error is FileOperationException) return error.message;
    if (error is UnexpectedException) return error.message;
    if (error is Failure) return error.message;

    String msg = error.toString();
    
    if (msg.contains('Error: ')) {
      msg = msg.split('Error: ').last.trim();
    } else if (msg.contains('Exception: ')) {
      msg = msg.split('Exception: ').last.trim();
    }

    // Clean up any leaked object representations (like DioException stringifiers)
    if (msg.contains('NetworkException')) {
      return 'لا يوجد اتصال بالإنترنت. تحقق من الشبكة.';
    }
    if (msg.contains('ServerException')) {
      return 'حدث خطأ في الخادم.';
    }
    if (msg.contains('(') || msg.contains('[')) {
      return 'حدث خطأ غير متوقع. يرجى المحاولة لاحقاً.';
    }

    return msg.isNotEmpty ? msg : 'حدث خطأ غير متوقع.';
  }
}
