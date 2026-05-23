import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// ──────────────────────────────────────────────────────────────────────────────
/// Animated shimmer/glass loading overlay.
/// Shows a pulsing indicator with status text during extraction and loading.
/// ──────────────────────────────────────────────────────────────────────────────
class LoadingOverlay extends StatelessWidget {
  final String message;
  final double? progress;

  const LoadingOverlay({super.key, this.message = 'Loading…', this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.82),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.cardDark.withValues(alpha: 0.95),
                AppColors.cardDarkElevated.withValues(alpha: 0.95),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated progress indicator
              SizedBox(
                width: 56,
                height: 56,
                child: progress != null
                    ? CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 4,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.2,
                        ),
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.primary,
                        ),
                      )
                    : const CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      ),
              ),
              const SizedBox(height: 24),
              // Status text
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              if (progress != null) ...[
                const SizedBox(height: 12),
                Text(
                  '${(progress! * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: AppColors.primary.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
