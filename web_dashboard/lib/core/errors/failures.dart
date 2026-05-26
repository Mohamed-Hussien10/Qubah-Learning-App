import 'package:equatable/equatable.dart';

/// Base failure class for domain-level error handling.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Failure returned when the server responds with an error.
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(super.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Failure returned when there is no network connectivity.
class NetworkFailure extends Failure {
  const NetworkFailure(
      [super.message = 'لا يوجد اتصال بالإنترنت. تحقق من الشبكة.']);
}

/// Failure returned when a local cache operation fails.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'خطأ في التخزين المحلي.']);
}

/// Failure returned when the user is not authenticated or session expired.
class AuthFailure extends Failure {
  final int? statusCode;

  const AuthFailure([super.message = 'غير مصرح. يرجى تسجيل الدخول.', this.statusCode]);

  @override
  List<Object?> get props => [message, statusCode];
}

/// Failure returned when input validation fails.
class ValidationFailure extends Failure {
  final Map<String, List<String>>? errors;

  const ValidationFailure(
      [super.message = 'خطأ في البيانات المدخلة.', this.errors]);

  @override
  List<Object?> get props => [message, errors];
}
