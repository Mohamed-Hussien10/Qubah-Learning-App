import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qubah_learning_app/core/constants/app_colors.dart';
import 'package:qubah_learning_app/features/authentication/presentation/manager/cubit/auth_cubit.dart';
import 'package:qubah_learning_app/core/routing/app_router.dart';

class SubscriptionExpiredScreen extends StatelessWidget {
  const SubscriptionExpiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 80,
                color: AppColors.error,
              ),
              const SizedBox(height: 24),
              Text(
                'انتهت صلاحية الاشتراك',
                style: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'يرجى التواصل مع إدارة التطبيق لتجديد اشتراكك والتمتع بكافة المحتويات التعليمية.',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () {
                  context.push(AppRoutes.support);
                },
                icon: const Icon(Icons.support_agent_rounded),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                label: Text(
                  'تواصل مع الدعم الفني',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  context.read<AuthCubit>().logout();
                },
                child: Text(
                  'تسجيل الخروج',
                  style: GoogleFonts.cairo(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
