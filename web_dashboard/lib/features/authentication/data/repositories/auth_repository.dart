import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_dashboard/core/network/api_client.dart';
import 'package:web_dashboard/features/authentication/data/models/admin_model.dart';

/// Repository handling authentication operations.
class AuthRepository {
  final ApiClient _apiClient;
  static const String _tokenKey = 'auth_token';
  static const String _adminKey = 'admin_data';

  AuthRepository(this._apiClient);

  /// Authenticate the user with [email] and [password].
  ///
  /// Returns an [AdminModel] on success.
  /// Throws an [Exception] on failure.
  Future<AdminModel> login(String email, String password) async {
    debugPrint('DEBUG: Web Dashboard login attempt for $email');
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      debugPrint('DEBUG: Web Dashboard login response: ${response.data}');

      final data = response.data['data'] ?? response.data;
      final userMap = Map<String, dynamic>.from(data['user'] ?? data);
      final token = (data['access_token'] ?? data['token'] ?? '') as String;
      
      userMap['token'] = token;
      final admin = AdminModel.fromJson(userMap);
      await _saveSession(admin);
      return admin;
    } catch (e) {
      debugPrint('DEBUG: Web Dashboard login ERROR: $e');
      rethrow;
    }
  }

  /// Clear the stored session and log out.
  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout');
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_adminKey);
  }

  /// Retrieve the currently logged-in admin, if any.
  Future<AdminModel?> getCurrentAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    final adminJson = prefs.getString(_adminKey);
    if (adminJson == null) return null;

    try {
      // Try to fetch latest details from backend if connected
      try {
        final response = await _apiClient.get('/auth/me');
        final data = response.data['data'] ?? response.data;
        final userMap = Map<String, dynamic>.from(data['user'] ?? data);
        final token = prefs.getString(_tokenKey) ?? '';
        userMap['token'] = token;
        final admin = AdminModel.fromJson(userMap);
        await _saveSession(admin);
        return admin;
      } catch (_) {
        // Fallback to cache if network fails
        final map = jsonDecode(adminJson) as Map<String, dynamic>;
        return AdminModel.fromJson(map);
      }
    } catch (_) {
      return null;
    }
  }

  /// Check if a valid session token exists.
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  // ── Private helpers ──────────────────────────────────────────────────

  Future<void> updateProfile(String name, String email) async {
    try {
      await _apiClient.post(
        '/user/profile/update',
        data: {
          'name': name,
          'email': email,
        },
      );
    } catch (e) {
      debugPrint('DEBUG: Web Dashboard update profile ERROR: $e');
      rethrow;
    }
  }

  Future<void> updatePassword(String currentPassword, String newPassword) async {
    try {
      // Assuming the endpoint is /user/change-password based on the mobile app's endpoints
      await _apiClient.post(
        '/user/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPassword,
        },
      );
    } catch (e) {
      debugPrint('DEBUG: Web Dashboard update password ERROR: $e');
      rethrow;
    }
  }

  Future<void> _saveSession(AdminModel admin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, admin.token);
    await prefs.setString(_adminKey, jsonEncode(admin.toJson()));
  }
}
