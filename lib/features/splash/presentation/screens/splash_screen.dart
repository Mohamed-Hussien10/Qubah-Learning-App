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
      return const Scaffold(
        backgroundColor: AppColors.hessaBackground,
        body: Center(child: CircularProgressIndicator(color: AppColors.hessaBrown)),
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
                              Expanded(child: _buildPlaceholder(AppColors.hessaGreen.withValues(alpha: 0.15))),
                              const SizedBox(width: 8),
                              Expanded(child: _buildPlaceholder(AppColors.hessaBrown.withValues(alpha: 0.15))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(child: _buildPlaceholder(AppColors.primary.withValues(alpha: 0.15))),
                              const SizedBox(width: 8),
                              Expanded(child: _buildPlaceholder(AppColors.orange.withValues(alpha: 0.15))),
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

  Widget _buildPlaceholder(Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Icon(Icons.image_outlined, color: AppColors.hessaBrown.withValues(alpha: 0.3), size: 48),
      ),
    );
  }
}
