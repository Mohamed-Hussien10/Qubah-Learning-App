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
    if (error is AuthException) return error.message;
    if (error is ValidationException) {
      // If validation exception has details, extract them nicely, else fallback to message.
      if (error.errors != null && error.errors!.isNotEmpty) {
        final messages = error.errors!.values.expand((element) => element).toList();
        if (messages.isNotEmpty) {
          String valMsg = messages.first;
          if (valMsg == 'The provided credentials are incorrect.') {
            return 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
          }
          return valMsg; // Returning the first validation message
        }
      }
      if (error.message == 'The provided credentials are incorrect.') {
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
      }
      return error.message;
    }
    if (error is Failure) return error.message;

    String msg = error.toString();
    
    // Clean up Exception prefixes if they somehow appear as strings
    if (msg.contains('Exception: ')) {
      msg = msg.replaceAll('Exception: ', '').trim();
    }
    if (msg.contains('Error: ')) {
      msg = msg.split('Error: ').last.trim();
    }

    // Clean up any leaked object representations (like DioException stringifiers)
    if (msg.contains('NetworkException')) {
      return 'عذراً، يبدو أنه لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة.';
    }
    if (msg.contains('ServerException')) {
      return 'حدث خطأ في الخادم.';
    }
    if (msg.contains('ValidationException')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة.'; // Safe fallback
    }
    if (msg.contains('AuthException')) {
      return 'انتهت الجلسة أو ليس لديك الصلاحية الكافية.';
    }
    if (msg.contains('(') || msg.contains('[')) {
      return 'حدث خطأ غير متوقع. يرجى المحاولة لاحقاً.';
    }

    return msg.isNotEmpty ? msg : 'حدث خطأ غير متوقع.';
  }
}
