import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../utils/debug_logger.dart';
import 'models/screen_capture_state.dart';

/// ──────────────────────────────────────────────────────────────────────────────
/// Screen Security Service
///
/// Centralized service for cross-platform screen recording, screenshot, and
/// capture protection.
///
/// Features:
///   • Android: WindowManager.LayoutParams.FLAG_SECURE via native channel.
///   • iOS: Real-time screen recording / AirPlay capture detection via
///     UIScreen.capturedDidChangeNotification and EventChannel.
///   • Windows: Win32 SetWindowDisplayAffinity (WDA_EXCLUDEFROMCAPTURE / WDA_MONITOR).
///   • Reference counted protection to handle nested or overlapping screens.
///   • Live capture state broadcast stream.
/// ──────────────────────────────────────────────────────────────────────────────
class ScreenSecurityService {
  static const MethodChannel _securityChannel =
      MethodChannel('com.qubah.learning/security');
  static const EventChannel _eventChannel =
      EventChannel('com.qubah.learning/security_events');

  int _protectionReferenceCount = 0;
  bool _isProtectionActive = false;
  bool _isCaptured = false;

  final StreamController<bool> _recordingStateController =
      StreamController<bool>.broadcast();
  final StreamController<ScreenCaptureState> _captureStateController =
      StreamController<ScreenCaptureState>.broadcast();

  StreamSubscription<dynamic>? _nativeEventSubscription;

  ScreenSecurityService() {
    _initNativeListeners();
  }

  /// Broadcast stream indicating if screen recording / capture is active (primarily iOS).
  Stream<bool> get recordingStateStream => _recordingStateController.stream;

  /// Broadcast stream providing full capture state updates.
  Stream<ScreenCaptureState> get captureStateStream =>
      _captureStateController.stream;

  /// Returns true if OS-level protection is currently active.
  bool get isProtectionActive => _isProtectionActive;

  /// Returns true if the screen is currently being captured/recorded.
  bool get isCaptured => _isCaptured;

  void _initNativeListeners() {
    if (kIsWeb) return;

    if (Platform.isIOS) {
      try {
        _nativeEventSubscription = _eventChannel
            .receiveBroadcastStream()
            .listen(
          (dynamic event) {
            if (event is bool) {
              _updateCaptureState(event);
            } else if (event is Map) {
              final isCaptured = event['isCaptured'] as bool? ?? false;
              _updateCaptureState(isCaptured);
            }
          },
          onError: (Object error) {
            DebugLogger.error(
                '[SECURITY] Error in iOS security event stream: $error');
          },
        );
      } catch (e) {
        DebugLogger.error('[SECURITY] Failed to subscribe to iOS event channel: $e');
      }
    }
  }

  void _updateCaptureState(bool captured) {
    if (_isCaptured != captured) {
      _isCaptured = captured;
      DebugLogger.info(
          '[SECURITY] Screen capture state changed: isCaptured = $captured');
      _recordingStateController.add(captured);
      _captureStateController.add(
        ScreenCaptureState(
          isCaptured: _isCaptured,
          isProtected: _isProtectionActive,
          message: captured
              ? 'Screen recording detected. Content is hidden for protection.'
              : null,
        ),
      );
    }
  }

  /// Enables OS-level screen protection and capture mitigation.
  /// Uses reference counting to support multiple/nested protected screens.
  Future<void> enableProtection({bool withWatermark = true}) async {
    _protectionReferenceCount++;
    DebugLogger.info(
        '[SECURITY] enableProtection called (ref count: $_protectionReferenceCount)');

    if (_isProtectionActive) return;

    if (kIsWeb) {
      _isProtectionActive = true;
      return;
    }

    try {
      if (Platform.isAndroid || Platform.isIOS || Platform.isWindows) {
        final dynamic result =
            await _securityChannel.invokeMethod('enableProtection');
        _isProtectionActive = true;
        DebugLogger.info('[SECURITY] Native protection enabled successfully: $result');
      }
    } on MissingPluginException {
      DebugLogger.warning(
          '[SECURITY] Security MethodChannel not implemented on current platform.');
      _isProtectionActive = true;
    } catch (e) {
      DebugLogger.error('[SECURITY] Error enabling native protection: $e');
      _isProtectionActive = true;
    }

    _captureStateController.add(
      ScreenCaptureState(
        isCaptured: _isCaptured,
        isProtected: _isProtectionActive,
      ),
    );
  }

  /// Decrements protection reference count and disables protection when count reaches 0.
  Future<void> disableProtection() async {
    if (_protectionReferenceCount > 0) {
      _protectionReferenceCount--;
    }
    DebugLogger.info(
        '[SECURITY] disableProtection called (ref count: $_protectionReferenceCount)');

    if (_protectionReferenceCount > 0) return;

    await forceDisableProtection();
  }

  /// Force disables OS-level screen protection regardless of reference count.
  Future<void> forceDisableProtection() async {
    _protectionReferenceCount = 0;
    if (!_isProtectionActive) return;

    if (kIsWeb) {
      _isProtectionActive = false;
      return;
    }

    try {
      if (Platform.isAndroid || Platform.isIOS || Platform.isWindows) {
        await _securityChannel.invokeMethod('disableProtection');
        DebugLogger.info('[SECURITY] Native protection disabled.');
      }
    } catch (e) {
      DebugLogger.error('[SECURITY] Error disabling native protection: $e');
    } finally {
      _isProtectionActive = false;
      _captureStateController.add(
        ScreenCaptureState(
          isCaptured: _isCaptured,
          isProtected: false,
        ),
      );
    }
  }

  /// Disposes resources.
  void dispose() {
    _nativeEventSubscription?.cancel();
    _recordingStateController.close();
    _captureStateController.close();
  }
}
