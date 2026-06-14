import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/storage/secure_storage.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/services/dependency_injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/qubah_button.dart';
import '../../../authentication/presentation/manager/cubit/auth_cubit.dart';
import '../../../authentication/presentation/manager/state/auth_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'الملف الشخصي',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              context.go(AppRoutes.login);
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Avatar
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: const Icon(
                            Icons.person_rounded,
                            size: 70,
                            color: AppColors.primary,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primary,
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 24),
                  // Name
                  FutureBuilder<String?>(
                    future: sl<SecureStorage>().getUserData(),
                    builder: (context, snapshot) {
                      String name = 'اسم الطالب';
                      String email = 'طالب@مثال.com';
                      String stage = 'غير محدد';
                      String grade = 'غير محدد';
                      String subscription = 'غير فعال';

                      if (snapshot.hasData && snapshot.data != null) {
                        try {
                          final data = jsonDecode(snapshot.data!);
                          name = data['name'] ?? name;
                          email = data['email'] ?? email;
                          stage = data['stageName'] ?? data['stage_name'] ?? (data['stage'] != null ? data['stage']['title'] : null) ?? stage;
                          grade = data['gradeName'] ?? data['grade_name'] ?? (data['grade'] != null ? data['grade']['title'] : null) ?? grade;
                          
                          final expString = data['subscription_expiry'];
                          DateTime? exp;
                          if (expString != null) {
                            exp = DateTime.tryParse(expString);
                          }
                          
                          if (exp != null && exp.isAfter(DateTime.now())) {
                             subscription = 'فعال';
                             subscription += ' حتى ${exp.toString().split(" ").first.split("T").first}';
                          } else {
                             subscription = 'غير فعال أو منتهي';
                          }
                        } catch (_) {}
                      }
                      return Column(
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.cairo(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ).animate().fadeIn(delay: 200.ms),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color?.withOpacity(0.6),
                            ),
                          ).animate().fadeIn(delay: 300.ms),
                          const SizedBox(height: 40),
                          // Info Cards
                          _ProfileMenuItem(
                            icon: Icons.school_rounded,
                            title: 'المرحلة والصف',
                            subtitle: '$stage - $grade',
                            onTap: () {},
                          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
                          const SizedBox(height: 12),
                          _ProfileMenuItem(
                            icon: Icons.subscriptions_rounded,
                            title: 'الاشتراك',
                            subtitle: subscription,
                            onTap: () => context.push(AppRoutes.subscription),
                          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  // Logout Button
                  QubahButton(
                    text: 'تسجيل الخروج',
                    icon: Icons.logout_rounded,
                    gradient: AppColors.sunsetGradient,
                    onPressed: () {
                      context.read<AuthCubit>().logout();
                    },
                  ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1, end: 0),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
