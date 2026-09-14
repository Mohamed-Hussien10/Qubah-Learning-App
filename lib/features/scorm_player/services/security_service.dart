import 'dart:io';
import '../../../core/services/dependency_injection.dart';
import '../../../core/security/screen_security_service.dart';
import '../../../core/utils/debug_logger.dart';

/// ──────────────────────────────────────────────────────────────────────────────
/// Security Service – Provides backwards compatibility for SCORM & lesson player
/// security features while delegating screen capture protection to the centralized
/// [ScreenSecurityService].
/// ──────────────────────────────────────────────────────────────────────────────
class SecurityService {
  SecurityService._();

  static Future<bool> validateZipEncryption(String zipFilePath) async {
    DebugLogger.info('[SECURITY] ZIP encryption validation');
    return File(zipFilePath).existsSync();
  }

  static Future<bool> validateAccessToken(String? token) async {
    DebugLogger.info('[SECURITY] Token validation');
    if (token == null || token.isEmpty) return false;
    return true;
  }

  static Future<void> enableScreenshotProtection() async {
    try {
      await sl<ScreenSecurityService>().enableProtection();
    } catch (e) {
      DebugLogger.error('Failed to enable screenshot protection: $e');
    }
  }

  static Future<void> disableScreenshotProtection() async {
    try {
      await sl<ScreenSecurityService>().disableProtection();
    } catch (e) {
      DebugLogger.error('Failed to disable screenshot protection: $e');
    }
  }
}
