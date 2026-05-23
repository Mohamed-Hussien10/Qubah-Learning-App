import 'package:logger/logger.dart';

/// ──────────────────────────────────────────────────────────────────────────────
/// Logger Service - Singleton logging wrapper.
/// ──────────────────────────────────────────────────────────────────────────────
class LoggerService {
  LoggerService._internal();
  static final LoggerService _instance = LoggerService._internal();
  static LoggerService get instance => _instance;

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
    level: Level.debug,
  );

  void debug(String message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.d(message, error: error, stackTrace: stackTrace);
  void info(String message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.i(message, error: error, stackTrace: stackTrace);
  void warning(String message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.w(message, error: error, stackTrace: stackTrace);
  void error(String message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
  void fatal(String message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.f(message, error: error, stackTrace: stackTrace);
}
