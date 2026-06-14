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
  String _correctPin = '1234'; 
  bool _isLockEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPin();
  }

  Future<void> _loadPin() async {
    final storage = sl<SecureStorage>();
    final pin = await storage.getParentPin();
    if (mounted) {
      setState(() {
        if (pin != null && pin.isNotEmpty) {
          _isLockEnabled = true;
          _correctPin = pin;
        } else {
          _isLockEnabled = false;
        }
      });
    }
  }

  Future<void> _toggleLock() async {
    final storage = sl<SecureStorage>();
    if (_isLockEnabled) {
      // Disable
      await storage.saveParentPin('');
      setState(() {
        _isLockEnabled = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تعطيل الرقابة الأبوية'), backgroundColor: AppColors.success),
        );
      }
    } else {
      // Enable with default PIN '1234' for now
      await storage.saveParentPin('1234');
      setState(() {
        _isLockEnabled = true;
        _correctPin = '1234';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تفعيل الرقابة الأبوية (الرمز: 1234)'), backgroundColor: AppColors.success),
        );
      }
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
    final isSettingsMode = !widget.isAppEntry && !widget.isAppExit;

    return PopScope(
      canPop: isSettingsMode,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: isSettingsMode,
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black87),
          title: Text(
            'قفل الوالدين',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.black87),
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

                    if (isSettingsMode) ...[
                      // Enable/Disable Section
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: SwitchListTile(
                          title: Text(
                            _isLockEnabled ? 'تعطيل القفل' : 'تفعيل القفل',
                            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text(
                            _isLockEnabled ? 'سيتم تعطيل حماية التطبيق' : 'تفعيل القفل برمز 1234',
                            style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey.shade600),
                          ),
                          value: _isLockEnabled,
                          onChanged: (val) => _toggleLock(),
                          activeColor: AppColors.primary,
                        ),
                      ).animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: 40),
                    ],

                    if (!isSettingsMode || _isLockEnabled) ...[
                      Text(
                        widget.isAppExit
                            ? 'يرجى إدخال رمز PIN المكون من 4 أرقام للخروج من التطبيق.'
                            : widget.isAppEntry
                            ? 'يرجى إدخال رمز PIN المكون من 4 أرقام لدخول التطبيق.'
                            : 'يرجى إدخال رمز PIN للوصول أو التعديل.',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: 24),
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
                                color: Colors.grey.shade300,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.grey.shade200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.grey.shade200),
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
                        child: Text('نسيت الرمز؟', style: GoogleFonts.cairo(color: AppColors.primary)),
                      ).animate().fadeIn(delay: 600.ms),
                    ],
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
