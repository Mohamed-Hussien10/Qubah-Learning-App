import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qubah_learning_app/features/theme/presentation/manager/cubit/theme_cubit.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/child_friendly_card.dart';

/// Main home screen with navigation to educational stages, profile, settings.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.push(AppRoutes.appExitLock);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مرحباً بك! 👋',
                            style: GoogleFonts.cairo(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ).animate().fadeIn(duration: 400.ms),
                          const SizedBox(height: 4),
                          Text(
                            "هيا نتعلم شيئاً جديداً اليوم!",
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ).animate().fadeIn(delay: 200.ms),
                        ],
                      ),
                    ),
                    // Theme Toggle, Profile & Notification
                    IconButton(
                      onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                      icon: Icon(
                        isDark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        size: 28,
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.push(AppRoutes.notifications),
                      icon: const Icon(Icons.notifications_outlined, size: 28),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.profile),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary.withOpacity(0.2),
                        child: const Icon(
                          Icons.person_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 28),

                // ── Hero Card (3D Claymorphism) ─────────────────────────────────
                _buildHeroCard(
                  context,
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 32),

                // ── Quick Actions ───────────────────────────────────────
                Text(
                  'إجراءات سريعة',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                  children:
                      [
                            ChildFriendlyCard(
                              title: 'المراحل الدراسية',
                              subtitle: 'تصفح كل المراحل',
                              imageUrl: null,
                              color: AppColors.primary,
                              defaultIcon: Icons.school_rounded,
                              onTap: () => context.push(AppRoutes.stages),
                            ),
                            ChildFriendlyCard(
                              title: 'الاشتراك',
                              subtitle: 'إدارة الباقات',
                              imageUrl: null,
                              color: AppColors.orange,
                              defaultIcon: Icons.subscriptions_rounded,
                              onTap: () => context.push(AppRoutes.subscription),
                            ),
                            ChildFriendlyCard(
                              title: 'الإعدادات',
                              subtitle: 'تخصيص التطبيق',
                              imageUrl: null,
                              color: AppColors.accent,
                              defaultIcon: Icons.settings_rounded,
                              onTap: () => context.push(AppRoutes.settings),
                            ),
                            ChildFriendlyCard(
                              title: 'قفل الوالدين',
                              subtitle: 'مراقبة وتقييد',
                              imageUrl: null,
                              color: AppColors.green,
                              defaultIcon: Icons.lock_rounded,
                              onTap: () async {
                                final unlocked = await context.push<bool>(
                                  AppRoutes.parentLock,
                                );
                                if (unlocked == true && context.mounted) {
                                  context.push(AppRoutes.parentSettings);
                                }
                              },
                            ),
                          ]
                          .animate(interval: 100.ms)
                          .fadeIn(delay: 500.ms)
                          .slideY(begin: 0.15, end: 0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: AppColors.heroGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ابدأ التعلم',
                        style: GoogleFonts.cairo(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'استكشف المواد، شاهد الفيديوهات، والعب!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => context.push(AppRoutes.stages),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          elevation: 4,
                          shadowColor: Colors.black26,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          'استكشف الآن',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
