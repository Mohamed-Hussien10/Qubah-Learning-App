import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/services/dependency_injection.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/qubah_button.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  @override
  void dispose() {
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final newPin = _newPinController.text;
    final confirmPin = _confirmPinController.text;

    if (newPin.length != 4 || confirmPin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب أن يتكون الرمز من 4 أرقام'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (newPin != confirmPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرموز غير متطابقة'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Save to Secure Storage
    final storage = sl<SecureStorage>();
    await storage.saveParentPin(newPin);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تغيير رمز PIN بنجاح!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تغيير رمز PIN',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                        Icons.pin_rounded,
                        size: 80,
                        color: AppColors.primary,
                      )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .scale(begin: const Offset(0.8, 0.8)),
                  const SizedBox(height: 24),
                  Text(
                    'إعداد رمز جديد',
                    style: GoogleFonts.cairo(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 8),
                  Text(
                    'أدخل الرمز الجديد المكون من 4 أرقام وأكده.',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 40),

                  // New PIN Field
                  TextField(
                    controller: _newPinController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 16,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: 'الرمز الجديد',
                      hintStyle: GoogleFonts.cairo(
                        fontSize: 16,
                        letterSpacing: 0,
                        color: Colors.grey,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardTheme.color,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 16),

                  // Confirm PIN Field
                  TextField(
                    controller: _confirmPinController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 16,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: 'تأكيد الرمز',
                      hintStyle: GoogleFonts.cairo(
                        fontSize: 16,
                        letterSpacing: 0,
                        color: Colors.grey,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardTheme.color,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 32),
                  QubahButton(
                    text: 'حفظ الرمز',
                    icon: Icons.save_rounded,
                    onPressed: _handleSave,
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
