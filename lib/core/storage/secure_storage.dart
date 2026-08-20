import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// ──────────────────────────────────────────────────────────────────────────────
/// Secure Storage
///
/// Wrapper around [FlutterSecureStorage] for encrypted local key-value storage.
/// Handles access tokens, refresh tokens, user data, and PIN codes.
/// ──────────────────────────────────────────────────────────────────────────────
class SecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorage()
    : _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      );

  // ── Storage Keys ────────────────────────────────────────────────────────
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userDataKey = 'user_data';
  static const String _activationCodeKey = 'activation_code';
  static const String _subscriptionExpiryKey = 'subscription_expiry';
  static const String _deviceIdKey = 'device_id';
  static const String _themeModeKey = 'theme_mode';
  static const String _isGuestKey = 'is_guest';
  static const String _enablePaymentKey = 'enable_payment';

  // ── Access Token ────────────────────────────────────────────────────────
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  Future<void> deleteAccessToken() async {
    await _storage.delete(key: _accessTokenKey);
  }

  // ── Refresh Token ──────────────────────────────────────────────────────
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  // ── User ID ────────────────────────────────────────────────────────────
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  Future<String?> getUserId() async {
    return _storage.read(key: _userIdKey);
  }

  // ── User Data (JSON string) ────────────────────────────────────────────
  Future<void> saveUserData(String userJson) async {
    await _storage.write(key: _userDataKey, value: userJson);
  }

  Future<String?> getUserData() async {
    return _storage.read(key: _userDataKey);
  }

  // ── Activation Code ───────────────────────────────────────────────────
  Future<void> saveActivationCode(String code) async {
    await _storage.write(key: _activationCodeKey, value: code);
  }

  Future<String?> getActivationCode() async {
    return _storage.read(key: _activationCodeKey);
  }

  // ── Subscription Expiry ───────────────────────────────────────────────
  Future<void> saveSubscriptionExpiry(String expiryDate) async {
    await _storage.write(key: _subscriptionExpiryKey, value: expiryDate);
  }

  Future<String?> getSubscriptionExpiry() async {
    return _storage.read(key: _subscriptionExpiryKey);
  }

  Future<bool> isSubscriptionValid() async {
    final expiry = await _storage.read(key: _subscriptionExpiryKey);
    if (expiry == null) return false;
    final expiryDate = DateTime.tryParse(expiry);
    if (expiryDate == null) return false;
    return expiryDate.isAfter(DateTime.now());
  }

  // ── Device ID ─────────────────────────────────────────────────────────
  Future<void> saveDeviceId(String deviceId) async {
    await _storage.write(key: _deviceIdKey, value: deviceId);
  }

  Future<String?> getDeviceId() async {
    return _storage.read(key: _deviceIdKey);
  }

  // ── Theme Mode ────────────────────────────────────────────────────────
  Future<void> saveThemeMode(String mode) async {
    await _storage.write(key: _themeModeKey, value: mode);
  }

  Future<String?> getThemeMode() async {
    return _storage.read(key: _themeModeKey);
  }

  // ── Guest Mode ────────────────────────────────────────────────────────
  Future<void> saveIsGuest(bool isGuest) async {
    await _storage.write(key: _isGuestKey, value: isGuest.toString());
  }

  Future<bool> isGuest() async {
    final value = await _storage.read(key: _isGuestKey);
    return value == 'true';
  }

  // ── Remote Config: Enable Payment ──────────────────────────────────────
  Future<void> saveEnablePayment(bool enablePayment) async {
    await _storage.write(key: _enablePaymentKey, value: enablePayment.toString());
  }

  Future<bool> isPaymentEnabled() async {
    final value = await _storage.read(key: _enablePaymentKey);
    if (value == null) return true; // Default to true if not set
    return value == 'true';
  }

  // ── Authentication Check ──────────────────────────────────────────────
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ── Clear All ─────────────────────────────────────────────────────────
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Clear only authentication-related data (preserves settings).
  Future<void> clearAuth() async {
    await deleteAccessToken();
    await deleteRefreshToken();
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _userDataKey);
  }
}
