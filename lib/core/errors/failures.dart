import 'package:equatable/equatable.dart';

/// ──────────────────────────────────────────────────────────────────────────────
/// Application Failures
///
/// Domain-layer failure classes. These are returned by repositories as the
/// left side of an Either-like result to communicate errors to the
/// presentation layer without throwing exceptions.
/// ──────────────────────────────────────────────────────────────────────────────

/// Base failure class. All specific failures extend this.
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Failure due to server/API errors.
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({required super.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Failure due to no internet connection.
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
  });
}

/// Failure due to local cache errors.
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Failed to load cached data.'});
}

/// Failure due to authentication errors.
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    super.message = 'Authentication failed. Please log in again.',
  });
}

/// Failure due to invalid activation code.
class ActivationFailure extends Failure {
  const ActivationFailure({
    super.message = 'Invalid or expired activation code.',
  });
}

/// Failure due to expired subscription.
class SubscriptionFailure extends Failure {
  const SubscriptionFailure({super.message = 'Your subscription has expired.'});
}

/// Failure due to file operations.
class FileFailure extends Failure {
  const FileFailure({super.message = 'File operation failed.'});
}

/// Generic unexpected failure.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({super.message = 'An unexpected error occurred.'});
}
