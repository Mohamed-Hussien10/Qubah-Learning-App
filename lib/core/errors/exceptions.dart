/// ──────────────────────────────────────────────────────────────────────────────
/// Application Exceptions
///
/// Custom exception classes for the data layer.
/// These are thrown by data sources and caught by repository implementations
/// to be converted into [Failure] objects for the domain layer.
/// ──────────────────────────────────────────────────────────────────────────────

/// Thrown when a server request fails (non-2xx status code).
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

/// Thrown when there is no internet connection.
class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = 'لا يوجد اتصال بالإنترنت.'});

  @override
  String toString() => message;
}

/// Thrown when local cache operations fail.
class CacheException implements Exception {
  final String message;

  const CacheException({this.message = 'فشلت عملية التخزين المؤقت.'});

  @override
  String toString() => message;
}

/// Thrown when authentication fails or token is invalid/expired.
class AuthenticationException implements Exception {
  final String message;

  const AuthenticationException({this.message = 'فشلت عملية المصادقة.'});

  @override
  String toString() => message;
}

/// Thrown when the activation code is invalid or expired.
class ActivationException implements Exception {
  final String message;

  const ActivationException({this.message = 'رمز التفعيل غير صالح.'});

  @override
  String toString() => message;
}

/// Thrown when the subscription has expired.
class SubscriptionExpiredException implements Exception {
  final String message;

  const SubscriptionExpiredException({this.message = 'انتهت صلاحية الاشتراك.'});

  @override
  String toString() => message;
}

/// Thrown when a file operation fails (read, write, extract).
class FileOperationException implements Exception {
  final String message;

  const FileOperationException({this.message = 'فشلت عملية الملف.'});

  @override
  String toString() => message;
}

/// Thrown when an unexpected error occurs.
class UnexpectedException implements Exception {
  final String message;

  const UnexpectedException({this.message = 'حدث خطأ غير متوقع.'});

  @override
  String toString() => message;
}
