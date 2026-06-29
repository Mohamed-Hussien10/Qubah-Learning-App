import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'سياسة الخصوصية',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Text(
          'سياسة الخصوصية الخاصة بتطبيق قُبَة...\n\nنحن نهتم بخصوصيتك ونقوم بحماية بياناتك بأعلى معايير الأمان.',
          style: GoogleFonts.cairo(
            fontSize: 16,
            color: Colors.black87,
            height: 1.8,
          ),
        ),
      ),
    );
  }
}
