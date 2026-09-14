import 'package:qubah_learning_app/core/widgets/hover_scale.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/security/protected_lesson_scaffold.dart';

class PdfViewerScreen extends StatelessWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerScreen({super.key, required this.pdfUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = AppHelpers.resolveMediaUrl(pdfUrl);
    final encodedUrl = Uri.encodeFull(Uri.decodeFull(resolvedUrl));
    debugPrint('=== PDF VIEWER DEBUG ===');
    debugPrint('Original URL: $pdfUrl');
    debugPrint('Encoded URL: $encodedUrl');

    return ProtectedLessonScaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: HoverScale(
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pushReplacementNamed('/home');
              }
            },
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
        ),
      ),
      child: SfPdfViewer.network(
        encodedUrl,
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          debugPrint('=== PDF LOAD FAILED ===');
          debugPrint('Error: ${details.error}');
          debugPrint('Description: ${details.description}');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تعذر فتح الملف: ${details.description}'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 5),
            ),
          );
        },
      ),
    );
  }
}
