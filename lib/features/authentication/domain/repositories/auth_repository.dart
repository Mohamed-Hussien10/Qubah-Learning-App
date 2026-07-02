import '../entities/user_entity.dart';

/// Abstract authentication repository contract.
/// Domain layer - no Flutter imports, pure Dart.
abstract class AuthRepository {
  /// Authenticates user with email and password.
  /// Returns [UserEntity] on success, throws on failure.
  Future<UserEntity> login({required String email, required String password});

  /// Logs out the current user and clears session.
  Future<void> logout();

  /// Returns the currently cached user, if any.
  Future<UserEntity?> getCachedUser();

  /// Fetches the profile from the server and updates cache.
  Future<UserEntity> fetchProfile();

  /// Checks if user is currently authenticated.
  Future<bool> isAuthenticated();
}
