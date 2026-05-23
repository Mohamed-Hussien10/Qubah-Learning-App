import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/services/dependency_injection.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/qubah_button.dart';

class ParentLockScreen extends StatefulWidget {
  final bool isAppEntry;
  final bool isAppExit;

  const ParentLockScreen({
    super.key,
    this.isAppEntry = false,
    this.isAppExit = false,
  });

  @override
  State<ParentLockScreen> createState() => _ParentLockScreenState();
}

class _ParentLockScreenState extends State<ParentLockScreen> {
  final _pinController = TextEditingController();
  String _correctPin = '1234'; // Default PIN, updated from storage

  @override
  void initState() {
    super.initState();
    _loadPin();
  }

  Future<void> _loadPin() async {
    final storage = sl<SecureStorage>();
    final pin = await storage.getParentPin();
    if (pin != null && pin.isNotEmpty) {
      setState(() {
        _correctPin = pin;
      });
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _handleUnlock() {
    if (_pinController.text == _correctPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم السماح بالدخول!'),
          backgroundColor: AppColors.success,
        ),
      );

      if (widget.isAppExit) {
        SystemNavigator.pop();
      } else if (widget.isAppEntry) {
        context.go(AppRoutes.home);
      } else {
        Navigator.pop(context, true);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('رمز PIN غير صحيح'),
          backgroundColor: AppColors.error,
        ),
      );
      _pinController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.isAppEntry && !widget.isAppExit,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: !widget.isAppEntry && !widget.isAppExit,
          title: Text(
            'قفل الوالدين',
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
                          Icons.lock_person_rounded,
                          size: 80,
                          color: AppColors.primary,
                        )
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .scale(begin: const Offset(0.8, 0.8)),
                    const SizedBox(height: 24),
                    Text(
                      'الرقابة الأبوية',
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 8),
                    Text(
                      widget.isAppExit
                          ? 'يرجى إدخال رمز PIN المكون من 4 أرقام للخروج من التطبيق.'
                          : widget.isAppEntry
                          ? 'يرجى إدخال رمز PIN المكون من 4 أرقام لدخول التطبيق.'
                          : 'يرجى إدخال رمز PIN المكون من 4 أرقام للوصول إلى الإعدادات.',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 40),
                    TextField(
                          controller: _pinController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          maxLength: 4,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 16,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: '••••',
                            hintStyle: GoogleFonts.jetBrainsMono(
                              fontSize: 32,
                              letterSpacing: 16,
                              color: Colors.grey,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).cardTheme.color,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 32),
                    QubahButton(
                          text: 'إلغاء القفل',
                          icon: Icons.lock_open_rounded,
                          onPressed: _handleUnlock,
                        )
                        .animate()
                        .fadeIn(delay: 500.ms)
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        // Forgot PIN logic
                      },
                      child: Text('نسيت الرمز؟', style: GoogleFonts.cairo()),
                    ).animate().fadeIn(delay: 600.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
