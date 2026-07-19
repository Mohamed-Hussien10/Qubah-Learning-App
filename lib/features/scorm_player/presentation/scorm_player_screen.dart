import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/debug_logger.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../domain/scorm_package.dart';
import '../services/security_service.dart';

/// ──────────────────────────────────────────────────────────────────────────────
/// SCORM Player Screen – renders the extracted HTML package inside InAppWebView.
///
/// Features:
///   • Full JavaScript + CSS animation support
///   • Audio/video inline playback
///   • DOM storage (localStorage / sessionStorage)
///   • JavaScript console message forwarding to debug log
///   • Fullscreen toggle
///   • Reload action
///   • Loading overlay while WebView initialises
///   • Back navigation with confirmation
/// ──────────────────────────────────────────────────────────────────────────────
class ScormPlayerScreen extends StatefulWidget {
  final ScormPackage package;

  const ScormPlayerScreen({super.key, required this.package});

  @override
  State<ScormPlayerScreen> createState() => _ScormPlayerScreenState();
}

class _ScormPlayerScreenState extends State<ScormPlayerScreen> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  bool _isFullscreen = false;
  bool _hasError = false;
  String _errorMessage = '';
  double _loadingProgress = 0.0;

  /// JavaScript polyfill injected after page load.
  /// Patches HTMLMediaElement.prototype.play to catch AbortError and
  /// NotSupportedError, which SCORM packages frequently trigger when
  /// rapidly calling play()/pause() on audio/video elements.
  static const String _mediaPlayPolyfill = r"""
    (function() {
      if (window.__scormPlayPatched) return;
      window.__scormPlayPatched = true;

      var originalPlay = HTMLMediaElement.prototype.play;
      HTMLMediaElement.prototype.play = function() {
        try {
          var playPromise = originalPlay.apply(this, arguments);
          if (playPromise && typeof playPromise.catch === 'function') {
            return playPromise.catch(function(err) {
              if (err.name === 'AbortError' || err.name === 'NotSupportedError') {
                // Silently swallow – this is a benign race condition
                return;
              }
              throw err;
            });
          }
          return playPromise;
        } catch(e) {
          return Promise.resolve();
        }
      };

      console.log('[SCORM Polyfill] Media play() patched successfully.');
    })();
  """;

  @override
  void initState() {
    super.initState();
    DebugLogger.webView('Player opened for: ${widget.package.name}');
    DebugLogger.webView('Entry file: ${widget.package.entryFilePath}');

    // Enable screenshot protection placeholder
    SecurityService.enableScreenshotProtection();
  }

  @override
  void dispose() {
    SecurityService.disableScreenshotProtection();

    // Restore system UI when leaving player
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    }
  }

  void _reloadWebView() {
    _webViewController?.reload();
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
  }

  Future<bool> _onWillPop() async {
    // Check if WebView can go back
    if (_webViewController != null) {
      final canGoBack = await _webViewController!.canGoBack();
      if (canGoBack) {
        await _webViewController!.goBack();
        return false;
      }
    }
    return true;
  }

  /// Build the file URI for the entry HTML.
  /// On Windows: file:///C:/path/to/file.html
  /// On Android/iOS: file:///data/data/.../file.html
  WebUri _buildEntryUri() {
    final path = widget.package.entryFilePath;

    if (Platform.isWindows) {
      // Windows paths need forward slashes in file URIs
      final normalized = path.replaceAll('\\', '/');
      final uri = 'file:///$normalized';
      DebugLogger.webView('Loading URI (Windows): $uri');
      return WebUri(uri);
    }

    final uri = 'file://$path';
    DebugLogger.webView('Loading URI: $uri');
    return WebUri(uri);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // ── WebView ──────────────────────────────────────────────────
            Positioned.fill(
              child: SafeArea(
                top: !_isFullscreen,
                bottom: !_isFullscreen,
                child: _buildWebView(),
              ),
            ),

            // ── Top Controls ─────────────────────────────────────────────
            if (!_isFullscreen)
              Positioned(top: 0, left: 0, right: 0, child: _buildTopBar()),

            // ── Loading Overlay ──────────────────────────────────────────
            if (_isLoading)
              LoadingOverlay(
                message: 'Loading content…',
                progress: _loadingProgress > 0 ? _loadingProgress : null,
              ),

            // ── Error Overlay ────────────────────────────────────────────
            if (_hasError) _buildErrorOverlay(),

            // ── Fullscreen Toggle (mini FAB) ─────────────────────────────
            Positioned(
              bottom: _isFullscreen ? 16 : 24,
              right: 16,
              child: _buildFullscreenButton(),
            ),
          ],
        ),
      ),
    );
  }

  // ── WebView Builder ───────────────────────────────────────────────────
  Widget _buildWebView() {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: _buildEntryUri()),
      initialSettings: InAppWebViewSettings(
        // ── JavaScript & Interactivity ──────────────────────────────────
        javaScriptEnabled: true,
        javaScriptCanOpenWindowsAutomatically: true,
        supportMultipleWindows: false,

        // ── Media Playback ─────────────────────────────────────────────
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,

        // ── File & Local Access ────────────────────────────────────────
        allowFileAccessFromFileURLs: false,
        allowUniversalAccessFromFileURLs: false,
        allowFileAccess: true,
        allowContentAccess: true,

        // ── DOM Storage ────────────────────────────────────────────────
        domStorageEnabled: true,
        databaseEnabled: true,

        // ── Rendering ──────────────────────────────────────────────────
        useWideViewPort: true,
        loadWithOverviewMode: true,
        supportZoom: true,
        builtInZoomControls: true,
        displayZoomControls: false,

        // ── Security (local testing mode) ──────────────────────────────
        mixedContentMode: MixedContentMode.MIXED_CONTENT_NEVER_ALLOW,
        allowsBackForwardNavigationGestures: true,

        // ── Performance ────────────────────────────────────────────────
        hardwareAcceleration: true,
        transparentBackground: false,

        // ── User Agent (identify as modern browser) ────────────────────
        userAgent:
            'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      ),

      // ── WebView Event Handlers ──────────────────────────────────────────
      onWebViewCreated: (controller) {
        _webViewController = controller;
        DebugLogger.webView('WebView created.');
      },

      onLoadStart: (controller, url) {
        DebugLogger.webView('Load started: $url');
        if (mounted) {
          setState(() {
            _isLoading = true;
            _hasError = false;
          });
        }
      },

      onLoadStop: (controller, url) async {
        DebugLogger.webView('Load completed: $url');

        // Inject the media play() polyfill to suppress AbortError spam
        // from SCORM packages that rapidly toggle play/pause on media elements.
        await controller.evaluateJavascript(source: _mediaPlayPolyfill);

        if (mounted) {
          setState(() => _isLoading = false);
        }
      },

      onProgressChanged: (controller, progress) {
        if (mounted) {
          setState(() => _loadingProgress = progress / 100.0);
        }
      },

      // ── Handle navigation to unknown URL schemes ─────────────────────
      // SCORM packages often use about:blank iframes, javascript: links,
      // or custom protocol schemes. Allow safe ones, block the rest.
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        final url = navigationAction.request.url;
        final scheme = url?.scheme ?? '';

        // Allow standard schemes that WebView can handle
        if (scheme == 'file' ||
            scheme == 'http' ||
            scheme == 'https' ||
            scheme == 'about' ||
            scheme == 'data' ||
            scheme == 'blob' ||
            scheme == 'javascript') {
          return NavigationActionPolicy.ALLOW;
        }

        DebugLogger.warning('Blocked navigation to unsupported scheme: $url');
        return NavigationActionPolicy.CANCEL;
      },

      onReceivedHttpError: (controller, request, response) {
        DebugLogger.error(
          'WebView HTTP error [${response.statusCode}]: ${response.reasonPhrase} for ${request.url}',
        );
      },

      onConsoleMessage: (controller, consoleMessage) {
        // Filter out the repetitive AbortError / NotSupportedError noise
        final msg = consoleMessage.message;
        if (msg.contains('AbortError') || msg.contains('NotSupportedError')) {
          // Already handled by polyfill — log at reduced verbosity
          DebugLogger.info(
            'JS media warning (suppressed): ${msg.substring(0, msg.length.clamp(0, 80))}…',
          );
          return;
        }
        DebugLogger.jsConsole('[${consoleMessage.messageLevel}] $msg');
      },

      onReceivedError: (controller, request, error) {
        final errorType = error.type;
        final errorDesc = error.description;
        final isMainFrame = request.isForMainFrame ?? true;

        // ── Ignore benign errors that don't affect the SCORM content ──
        // UNSUPPORTED_SCHEME: triggered by about:blank iframes, data: URIs, etc.
        // UNKNOWN: generic fallback errors from file:// resources.
        // Non-main-frame errors: sub-resource failures shouldn't show error UI.
        if (errorType == WebResourceErrorType.UNKNOWN ||
            errorType == WebResourceErrorType.UNSUPPORTED_SCHEME ||
            !isMainFrame) {
          DebugLogger.warning(
            'WebView sub-resource error (ignored): $errorType – $errorDesc [mainFrame=$isMainFrame]',
          );
          return;
        }

        DebugLogger.error('WebView MAIN FRAME error: $errorType – $errorDesc');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = 'Error: $errorDesc';
          });
        }
      },
    );
  }

  // ── Top Bar ───────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.85),
            Colors.black.withValues(alpha: 0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              // Back button
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () async {
                  final shouldPop = await _onWillPop();
                  if (shouldPop && mounted) {
                    Navigator.of(context).pop();
                  }
                },
                tooltip: 'Back',
              ),
              const SizedBox(width: 4),
              // Title
              Expanded(
                child: Text(
                  widget.package.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Reload button
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
                onPressed: _reloadWebView,
                tooltip: 'Reload',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Fullscreen Button ──────────────────────────────────────────────────
  Widget _buildFullscreenButton() {
    return AnimatedOpacity(
      opacity: _isLoading ? 0.0 : 0.7,
      duration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: _toggleFullscreen,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Icon(
            _isFullscreen
                ? Icons.fullscreen_exit_rounded
                : Icons.fullscreen_rounded,
            color: Colors.white70,
            size: 22,
          ),
        ),
      ),
    );
  }

  // ── Error Overlay ─────────────────────────────────────────────────────
  Widget _buildErrorOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.9),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Failed to Load Content',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Go Back'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(
                        color: AppColors.textSecondary.withValues(alpha: 0.3),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _reloadWebView,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
