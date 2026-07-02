import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:qubah_learning_app/core/theme/app_theme.dart';
import 'package:qubah_learning_app/core/widgets/qubah_button.dart';
import 'package:qubah_learning_app/core/routing/app_router.dart';

class MaintenanceScreen extends StatelessWidget {
  final String contactEmail;
  final String contactPhone;

  const MaintenanceScreen({
    super.key,
    this.contactEmail = 'support@qubah.com',
    this.contactPhone = '+966500000000',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Illustration / Icon
              Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.engineering_rounded,
                      size: 70,
                      color: AppColors.primary,
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 2000.ms, color: Colors.white54)
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 48),

              // Title
              Text(
                'التطبيق في وضع الصيانة',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimaryLight,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                'نحن نقوم حالياً ببعض التحديثات والتحسينات المدهشة على المنصة لتقديم تجربة تعليمية لا تُنسى لكم. يرجى المحاولة مرة أخرى قريباً.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondaryDark,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 48),

              // Navigate to Support Button
              QubahButton(
                text: 'التواصل مع الدعم الفني',
                onPressed: () {
                  context.push(
                    AppRoutes.support,
                    extra: {
                      'contactEmail': contactEmail,
                      'contactPhone': contactPhone,
                    },
                  );
                },
                icon: Icons.headset_mic_rounded,
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 24),

              // Exit Button
              TextButton.icon(
                onPressed: () => SystemNavigator.pop(),
                icon: const Icon(Icons.exit_to_app_rounded, color: Colors.grey),
                label: const Text(
                  'إغلاق التطبيق',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}
