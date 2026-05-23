import 'dart:convert';
import '../../../../core/storage/secure_storage.dart';
import '../models/user_model.dart';

/// Local data source for caching authentication data.
class AuthLocalService {
  final SecureStorage _secureStorage;
  AuthLocalService(this._secureStorage);

  /// Saves auth tokens to secure storage.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.saveAccessToken(accessToken);
    await _secureStorage.saveRefreshToken(refreshToken);
  }

  /// Saves user data to secure storage as JSON.
  Future<void> saveUser(UserModel user) async {
    await _secureStorage.saveUserData(jsonEncode(user.toJson()));
    await _secureStorage.saveUserId(user.id);
  }

  /// Retrieves cached user data.
  Future<UserModel?> getCachedUser() async {
    final userJson = await _secureStorage.getUserData();
    if (userJson == null) return null;
    return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
  }

  /// Clears all auth data.
  Future<void> clearAuth() async {
    await _secureStorage.clearAuth();
  }

  /// Checks if user has valid tokens.
  Future<bool> isAuthenticated() async {
    return _secureStorage.isAuthenticated();
  }
}
