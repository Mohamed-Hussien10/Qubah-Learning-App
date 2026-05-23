import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

class InteractiveViewerScreen extends StatefulWidget {
  final String contentUrl;
  final String title;

  const InteractiveViewerScreen({
    super.key,
    required this.contentUrl,
    required this.title,
  });

  @override
  State<InteractiveViewerScreen> createState() =>
      _InteractiveViewerScreenState();
}

class _InteractiveViewerScreenState extends State<InteractiveViewerScreen> {
  InAppWebViewController? webViewController;
  double progress = 0;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.contentUrl)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              domStorageEnabled: true,
              transparentBackground: true,
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onLoadStart: (controller, url) {
              setState(() => _isLoading = true);
            },
            onLoadStop: (controller, url) {
              setState(() => _isLoading = false);
            },
            onProgressChanged: (controller, progress) {
              setState(() {
                this.progress = progress / 100;
              });
            },
            onReceivedError: (controller, request, error) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error loading content: ${error.description}'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            onConsoleMessage: (controller, consoleMessage) {
              // Handle SCORM progress tracking through console messages if LMS API is injected
              print("SCORM/HTML5 Console: ${consoleMessage.message}");
            },
          ),
          if (_isLoading)
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          if (_isLoading && progress < 0.1)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
        ],
      ),
    );
  }
}
