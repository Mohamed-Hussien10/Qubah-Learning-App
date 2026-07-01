/// Base exception for data-layer errors.
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() => '$runtimeType(message: $message, statusCode: $statusCode)';
}

/// Thrown when the server responds with a non-success status code.
class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}

/// Thrown when there is no network connectivity or a timeout occurs.
class NetworkException extends AppException {
  const NetworkException(
      [super.message = 'عذراً، يبدو أنه لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة.', int? statusCode])
      : super(statusCode: statusCode);
}

/// Thrown when a local storage operation fails.
class CacheException extends AppException {
  const CacheException(
      [super.message = 'عذراً، حدثت مشكلة أثناء محاولة حفظ أو استرجاع البيانات محلياً.', int? statusCode])
      : super(statusCode: statusCode);
}

/// Thrown when the user is unauthenticated (401) or forbidden (403).
class AuthException extends AppException {
  const AuthException(
      [super.message = 'انتهت الجلسة أو ليس لديك الصلاحية الكافية. يرجى تسجيل الدخول مجدداً.', int? statusCode])
      : super(statusCode: statusCode);
}

/// Thrown when the server returns validation errors (422).
class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  const ValidationException(
      [super.message = 'عذراً، يرجى التأكد من صحة البيانات المدخلة والمحاولة مجدداً.',
      this.errors,
      int? statusCode])
      : super(statusCode: statusCode);

  @override
  String toString() =>
      'ValidationException(message: $message, errors: $errors, statusCode: $statusCode)';
}
