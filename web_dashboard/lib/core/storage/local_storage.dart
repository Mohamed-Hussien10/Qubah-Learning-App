import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper around [SharedPreferences] for typed local storage operations.
class LocalStorage {
  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  // ── Keys ──────────────────────────────────────────────────────────────
  static const String _tokenKey = 'auth_token';
  static const String _themeModeKey = 'theme_mode';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  // ── Token ─────────────────────────────────────────────────────────────

  /// Returns the stored auth token, or `null` if not set.
  String? getToken() => _prefs.getString(_tokenKey);

  /// Persists the auth [token].
  Future<bool> setToken(String token) => _prefs.setString(_tokenKey, token);

  /// Removes the stored auth token.
  Future<bool> removeToken() => _prefs.remove(_tokenKey);

  /// Whether a token is currently stored.
  bool get hasToken => getToken() != null && getToken()!.isNotEmpty;

  // ── Theme ─────────────────────────────────────────────────────────────

  /// Returns the stored [ThemeMode], defaults to [ThemeMode.light].
  ThemeMode getThemeMode() {
    final value = _prefs.getString(_themeModeKey);
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }

  /// Persists the [ThemeMode] selection.
  Future<bool> setThemeMode(ThemeMode mode) {
    final value = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
      ThemeMode.light => 'light',
    };
    return _prefs.setString(_themeModeKey, value);
  }

  // ── User Info ────────────────────────────────────────────────────────

  /// Gets the stored user ID.
  int? getUserId() => _prefs.getInt(_userIdKey);

  /// Persists the user [id].
  Future<bool> setUserId(int id) => _prefs.setInt(_userIdKey, id);

  /// Gets the stored user name.
  String? getUserName() => _prefs.getString(_userNameKey);

  /// Persists the user [name].
  Future<bool> setUserName(String name) =>
      _prefs.setString(_userNameKey, name);

  /// Gets the stored user email.
  String? getUserEmail() => _prefs.getString(_userEmailKey);

  /// Persists the user [email].
  Future<bool> setUserEmail(String email) =>
      _prefs.setString(_userEmailKey, email);

  // ── General Key-Value ─────────────────────────────────────────────────

  /// Gets a string value by [key].
  String? getString(String key) => _prefs.getString(key);

  /// Sets a string [value] for [key].
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  /// Gets an int value by [key].
  int? getInt(String key) => _prefs.getInt(key);

  /// Sets an int [value] for [key].
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  /// Gets a double value by [key].
  double? getDouble(String key) => _prefs.getDouble(key);

  /// Sets a double [value] for [key].
  Future<bool> setDouble(String key, double value) =>
      _prefs.setDouble(key, value);

  /// Gets a bool value by [key].
  bool? getBool(String key) => _prefs.getBool(key);

  /// Sets a bool [value] for [key].
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  /// Removes the value associated with [key].
  Future<bool> remove(String key) => _prefs.remove(key);

  /// Clears all stored data. Use with caution.
  Future<bool> clearAll() => _prefs.clear();

  /// Clears user session data (token + user info) without clearing preferences.
  Future<void> clearSession() async {
    await removeToken();
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_userNameKey);
    await _prefs.remove(_userEmailKey);
  }
}
