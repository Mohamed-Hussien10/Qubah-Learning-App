// ignore_for_file: avoid_print
import 'package:flutter/foundation.dart';

/// ──────────────────────────────────────────────────────────────────────────────
/// Debug logger for SCORM player operations.
/// Wraps print statements with tags for easy filtering in the console.
/// ──────────────────────────────────────────────────────────────────────────────
class DebugLogger {
  DebugLogger._();

  static const String _tag = '[SCORM]';

  static void _log(String message) {
    if (kDebugMode) {
      print(message);
    }
  }

  /// General info log.
  static void info(String message) {
    _log('$_tag ℹ️  $message');
  }

  /// Success / positive event.
  static void success(String message) {
    _log('$_tag ✅ $message');
  }

  /// Warning.
  static void warning(String message) {
    _log('$_tag ⚠️  $message');
  }

  /// Error with optional stack trace.
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log('$_tag ❌ $message');
    if (error != null) _log('$_tag    Error: $error');
    if (stackTrace != null) _log('$_tag    StackTrace: $stackTrace');
  }

  /// WebView-specific logs.
  static void webView(String message) {
    _log('$_tag 🌐 $message');
  }

  /// JavaScript console messages forwarded from WebView.
  static void jsConsole(String message) {
    _log('$_tag 📜 JS: $message');
  }

  /// File system operations.
  static void fileSystem(String message) {
    _log('$_tag 📂 $message');
  }
}
