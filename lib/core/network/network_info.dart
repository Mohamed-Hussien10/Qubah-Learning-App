import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// ──────────────────────────────────────────────────────────────────────────────
/// Network Info
///
/// Abstraction for checking network connectivity status.
/// Used by repositories to determine whether to fetch from remote or cache.
/// ──────────────────────────────────────────────────────────────────────────────
abstract class NetworkInfo {
  /// Returns true if the device has an active internet connection.
  Future<bool> get isConnected;
}

/// Implementation using [InternetConnection] package.
class NetworkInfoImpl implements NetworkInfo {
  final InternetConnection _connectionChecker;

  const NetworkInfoImpl(this._connectionChecker);

  @override
  Future<bool> get isConnected => _connectionChecker.hasInternetAccess;
}
