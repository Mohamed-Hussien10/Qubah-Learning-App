import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الاشتراك',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      body: const Center(child: Text('تفاصيل الاشتراك ستظهر هنا.')),
    );
  }
}
