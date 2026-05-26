/// Application-wide color constants and design tokens.
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary Brand Colors ─────────────────────────────────────────────
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFF9B8FEF);
  static const Color primaryDark = Color(0xFF4834D4);

  // ── Accent / Secondary ───────────────────────────────────────────────
  static const Color accent = Color(0xFF00D2D3);
  static const Color accentLight = Color(0xFF55E6C1);

  // ── Surface & Background (Light) ────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF8F9FD);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color sidebarLight = Color(0xFFFFFFFF);

  // ── Surface & Background (Dark) ─────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0F0F1A);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color cardDark = Color(0xFF1E1E32);
  static const Color sidebarDark = Color(0xFF141425);

  // ── Text ─────────────────────────────────────────────────────────────
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textTertiaryLight = Color(0xFF9CA3AF);

  static const Color textPrimaryDark = Color(0xFFF1F1F8);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color textTertiaryDark = Color(0xFF6B7280);

  // ── Status Colors ───────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color successBg = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorBg = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoBg = Color(0xFFDBEAFE);

  // ── Borders ─────────────────────────────────────────────────────────
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF2D2D44);

  // ── Chart Palette ───────────────────────────────────────────────────
  static const List<Color> chartPalette = [
    Color(0xFF6C5CE7),
    Color(0xFF00D2D3),
    Color(0xFFFF6B6B),
    Color(0xFFFFD93D),
    Color(0xFF10B981),
    Color(0xFFFF8A5B),
    Color(0xFF3B82F6),
    Color(0xFFEC4899),
  ];
}
