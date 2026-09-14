import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/dependency_injection.dart';
import 'screen_security_service.dart';
import 'student_watermark_overlay.dart';

/// ──────────────────────────────────────────────────────────────────────────────
/// Protected Lesson Scaffold
///
/// Reusable wrapper for all protected educational screens (Videos, SCORM, PDFs, Audio).
///
/// Responsibilities:
///   1. Enforces OS-level screen protection on enter (and restores on exit).
///   2. Listens for active capture/recording events (iOS / desktop).
///   3. Displays a full-screen blackout shield when capture is detected.
///   4. Overlays dynamic forensic student watermark.
///   5. Notifies child controllers via [onCaptureStateChanged] to pause playback.
/// ──────────────────────────────────────────────────────────────────────────────
class ProtectedLessonScaffold extends StatefulWidget {
  final Widget child;
  final bool withWatermark;
  final ValueChanged<bool>? onCaptureStateChanged;
  final PreferredSizeWidget? appBar;
  final Color? backgroundColor;

  const ProtectedLessonScaffold({
    super.key,
    required this.child,
    this.withWatermark = true,
    this.onCaptureStateChanged,
    this.appBar,
    this.backgroundColor,
  });

  @override
  State<ProtectedLessonScaffold> createState() =>
      _ProtectedLessonScaffoldState();
}

class _ProtectedLessonScaffoldState extends State<ProtectedLessonScaffold> {
  late final ScreenSecurityService _securityService;
  StreamSubscription<bool>? _captureSubscription;
  bool _isCaptured = false;

  @override
  void initState() {
    super.initState();
    _securityService = sl<ScreenSecurityService>();
    _isCaptured = _securityService.isCaptured;

    _securityService.enableProtection(withWatermark: widget.withWatermark);

    _captureSubscription =
        _securityService.recordingStateStream.listen((isCaptured) {
      if (mounted && _isCaptured != isCaptured) {
        setState(() {
          _isCaptured = isCaptured;
        });
        widget.onCaptureStateChanged?.call(isCaptured);
      }
    });
  }

  @override
  void dispose() {
    _captureSubscription?.cancel();
    _securityService.disableProtection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      backgroundColor: widget.backgroundColor ?? Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Protected Content Layer
          // When captured, completely hide the subtree to prevent rendering frame leaks
          if (!_isCaptured)
            widget.child
          else
            const SizedBox.shrink(),

          // 2. Dynamic Forensic Watermark Layer
          if (widget.withWatermark && !_isCaptured)
            const Positioned.fill(
              child: StudentWatermarkOverlay(),
            ),

          // 3. Active Capture Blackout Barrier (iOS / Screen recording active)
          if (_isCaptured)
            Positioned.fill(
              child: _buildCaptureBlocker(),
            ),
        ],
      ),
    );
  }

  Widget _buildCaptureBlocker() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.videocam_off_rounded,
                size: 64,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'تم رصد تسجيل الشاشة',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'تم إخفاء المحتوى التعليمي لحماية حقوق الملكية الفكرية.\nيرجى إيقاف تسجيل الشاشة أو مشاركتها للمتابعة.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Screen recording detected. Content is hidden for protection.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
