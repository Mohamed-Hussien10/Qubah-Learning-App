import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/theme/app_theme.dart';

class PdfViewerScreen extends StatelessWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerScreen({super.key, required this.pdfUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    final encodedUrl = Uri.encodeFull(Uri.decodeFull(pdfUrl));
    debugPrint('=== PDF VIEWER DEBUG ===');
    debugPrint('Original URL: $pdfUrl');
    debugPrint('Encoded URL: $encodedUrl');
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
        ),
      ),
      body: SfPdfViewer.network(
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
