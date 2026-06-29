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

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final secureStorage = sl<SecureStorage>();
    final isAuthenticated = await secureStorage.isAuthenticated();

    if (!mounted) return;

    if (isAuthenticated) {
      context.go(AppRoutes.appEntryLock);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.hessaBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.hessaBrown.withOpacity(0.15),
                      blurRadius: 50,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 140,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .scaleXY(begin: 0.95, end: 1.05, duration: 1500.ms, curve: Curves.easeInOut)
                  .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.6)),
              const SizedBox(height: 50),
              SizedBox(
                width: 140,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(
                    color: AppColors.hessaBrown,
                    backgroundColor: Colors.white,
                    minHeight: 6,
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 16),
              Text(
                'جاري التحميل...',
                style: GoogleFonts.cairo(
                  color: AppColors.hessaTextBrown.withOpacity(0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true)).fade(begin: 0.4, end: 1.0, duration: 1200.ms),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.hessaBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Placeholder for the 4 grid images
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset('assets/images/login_1.png', fit: BoxFit.cover),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset('assets/images/login_2.png', fit: BoxFit.cover),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset('assets/images/login_3.png', fit: BoxFit.cover),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset('assets/images/login_4.png', fit: BoxFit.cover),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Logo Overlay
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                        )
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ).animate().scale(delay: 200.ms, duration: 500.ms, curve: Curves.easeOutBack),
                ],
              ),
            ),
            
            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  QubahButton(
                    text: 'دخول',
                    gradient: const LinearGradient(colors: [AppColors.hessaBrown, AppColors.hessaBrown]),
                    onPressed: () => context.push(AppRoutes.login),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 20),
                  Text(
                    '!ليس لديك حساب بعد؟ احصل على اشتراك الآن',
                    style: GoogleFonts.cairo(
                      color: AppColors.hessaTextBrown.withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 500.ms),
                  const SizedBox(height: 20),
                  
                  QubahButton(
                    text: 'تجربة مجانية',
                    gradient: const LinearGradient(colors: [AppColors.hessaGreen, AppColors.hessaGreen]),
                    onPressed: () async {
                      await sl<SecureStorage>().saveIsGuest(true);
                      if (context.mounted) {
                        context.go(AppRoutes.home);
                      }
                    },
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
