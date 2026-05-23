// ignore_for_file: avoid_print

/// ──────────────────────────────────────────────────────────────────────────────
/// Debug logger for SCORM player operations.
/// Wraps print statements with tags for easy filtering in the console.
/// ──────────────────────────────────────────────────────────────────────────────
class DebugLogger {
  DebugLogger._();

  static const String _tag = '[SCORM]';

  /// General info log.
  static void info(String message) {
    print('$_tag ℹ️  $message');
  }

  /// Success / positive event.
  static void success(String message) {
    print('$_tag ✅ $message');
  }

  /// Warning.
  static void warning(String message) {
    print('$_tag ⚠️  $message');
  }

  /// Error with optional stack trace.
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    print('$_tag ❌ $message');
    if (error != null) print('$_tag    Error: $error');
    if (stackTrace != null) print('$_tag    StackTrace: $stackTrace');
  }

  /// WebView-specific logs.
  static void webView(String message) {
    print('$_tag 🌐 $message');
  }

  /// JavaScript console messages forwarded from WebView.
  static void jsConsole(String message) {
    print('$_tag 📜 JS: $message');
  }

  /// File system operations.
  static void fileSystem(String message) {
    print('$_tag 📂 $message');
  }
}
