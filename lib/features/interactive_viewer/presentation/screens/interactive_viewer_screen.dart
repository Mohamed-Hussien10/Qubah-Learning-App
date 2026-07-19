import 'package:flutter/material.dart';
import '../../../../core/services/dependency_injection.dart';
import '../../../../core/network/dio_client.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../scorm_player/domain/scorm_package.dart';
import '../../../scorm_player/services/scorm_extractor_service.dart';
import '../../../scorm_player/presentation/scorm_player_screen.dart';

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
  ScormPackage? _package;
  double _progress = 0;
  bool _isLoading = true;
  String _status = 'جاري التجهيز...';
  String? _error;

  @override
  void initState() {
    super.initState();
    _downloadAndExtract();
  }

  Future<void> _downloadAndExtract() async {
    try {
      if (!widget.contentUrl.toLowerCase().endsWith('.zip')) {
        setState(() {
          _error = 'صيغة الملف غير مدعومة. ندعم ملفات zip التفاعلية فقط.';
          _isLoading = false;
        });
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final zipFileName = widget.contentUrl.split('/').last;
      final savePath = '${tempDir.path}/$zipFileName';
      
      // Deterministic ID based on filename
      final packageId = zipFileName.replaceAll('.zip', '').replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');

      // Check cache first
      final cachedPackage = await ScormExtractorService.getCachedPackage(packageId, savePath);
      if (cachedPackage != null) {
        if (mounted) {
          setState(() {
            _package = cachedPackage;
            _isLoading = false;
          });
        }
        return;
      }

      setState(() => _status = 'جاري تحميل المحتوى...');

      final dioClient = sl<DioClient>();
      await dioClient.download(
        widget.contentUrl,
        savePath,
        onReceiveProgress: (count, total) {
          if (total > 0) {
            setState(() {
              _progress = count / total;
            });
          }
        },
      );

      setState(() {
        _status = 'جاري معالجة الملفات...';
        _progress = 0;
      });

      final package = await ScormExtractorService.extractAndPrepare(
        savePath,
        packageId: packageId,
        onProgress: (p) {
          setState(() {
            _progress = p;
          });
        },
      );

      if (mounted) {
        setState(() {
          _package = package;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'فشل تحميل المحتوى التفاعلي: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_package != null) {
      // Use the advanced ScormPlayerScreen which handles SCORM playback properly
      return ScormPlayerScreen(package: _package!);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
        ),
        elevation: 1,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isLoading
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 24),
                    Text(
                      _status,
                      style:  TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimaryDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: _progress > 0 ? _progress : null,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.error,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error ?? 'حدث خطأ غير معروف.',
                      style:  TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimaryDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _error = null;
                        });
                        _downloadAndExtract();
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('إعادة المحاولة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
