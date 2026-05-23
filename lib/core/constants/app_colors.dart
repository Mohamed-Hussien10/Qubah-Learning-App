import 'package:flutter/material.dart';

/// ──────────────────────────────────────────────────────────────────────────────
/// App-wide colour palette.
/// Uses a refined dark-first palette with vibrant accent colours for a premium
/// educational experience.
/// ──────────────────────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  // ── Primary Brand Colours ─────────────────────────────────────────────────
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFFA29BFE);
  static const Color primaryDark = Color(0xFF4834D4);

  // ── Accent / Secondary ────────────────────────────────────────────────────
  static const Color accent = Color(0xFF00CEC9);
  static const Color accentLight = Color(0xFF81ECEC);

  // ── Surface & Background (Dark Mode) ──────────────────────────────────────
  static const Color scaffoldDark = Color(0xFF0D1117);
  static const Color surfaceDark = Color(0xFF161B22);
  static const Color cardDark = Color(0xFF1C2333);
  static const Color cardDarkElevated = Color(0xFF232B3E);

  // ── Surface & Background (Light Mode) ─────────────────────────────────────
  static const Color scaffoldLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFF1F3F5);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF0F0F0);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textLight = Color(0xFF1A1A2E);
  static const Color textLightSecondary = Color(0xFF6C757D);

  // ── Status ────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF00B894);
  static const Color error = Color(0xFFE17055);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color info = Color(0xFF74B9FF);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFF0984E3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [cardDark, cardDarkElevated],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFF00CEC9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
