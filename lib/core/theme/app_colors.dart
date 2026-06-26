import 'package:flutter/material.dart';

/// Defines the color palette for the application.
class AppColors {
  AppColors._();

  // ── Core Brand Colors ───────────────────────────────────────────────────
  // Primary: A softer, friendly purple/indigo for eye comfort
  static const Color primary = Color(0xFF7A6DF4);
  static const Color primaryLight = Color(0xFFB1A9FF);
  static const Color primaryDark = Color(0xFF5544CC);

  // Secondary: A softer, engaging teal
  static const Color secondary = Color(0xFF2DD4D0);
  static const Color secondaryLight = Color(0xFF8CF4F2);
  static const Color secondaryDark = Color(0xFF00AFA9);

  // Accent: A playful orange for highlights/actions
  static const Color accent = Color(0xFFE17055);
  static const Color accentLight = Color(0xFFFAB1A0);
  static const Color accentDark = Color(0xFFD63031);

  // ── Additional Playful Colors (from previous palette) ───────────────────
  static const Color orange = Color(0xFFE17055);
  static const Color yellow = Color(0xFFFDCB6E);
  static const Color pink = Color(0xFFFD79A8);
  static const Color green = Color(0xFF00B894);

  // ── Hessa App Specific Colors ───────────────────────────────────────────
  static const Color hessaBackground = Color(0xFFFDF6E9); // Cream bg
  static const Color hessaBrown = Color(0xFFB86846); // Buttons, logo
  static const Color hessaGreen = Color(0xFF5BA75B); // Free trial button
  static const Color hessaInputBg = Color(0xFFF8E7D1); // Input fields bg
  static const Color hessaTextBrown = Color(0xFF614E3F); // Labels, hints

  // ── Semantic & Status Colors ────────────────────────────────────────────
  static const Color success = Color(0xFF2ECC71); // Vibrant green
  static const Color error = Color(0xFFFF4757);   // Friendly red
  static const Color warning = Color(0xFFFFA502); // Warm orange/yellow
  static const Color info = Color(0xFF1E90FF);    // Clear blue

  // ── Light Theme Surfaces & Backgrounds ──────────────────────────────────
  static const Color scaffoldLight = Color(0xFFF7F9FC); // Very soft cool grey
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);

  // ── Dark Theme Surfaces & Backgrounds ───────────────────────────────────
  // Premium dark mode: warmer deep purple/blue tone, very easy on the eyes
  static const Color scaffoldDark = Color(0xFF141424);
  static const Color surfaceDark = Color(0xFF1E1E32);
  static const Color cardDark = Color(0xFF1E1E32);
  static const Color cardDarkElevated = Color(0xFF2A2A44);
  static const Color borderDark = Color(0xFF2A2A44);

  // ── Text Colors ─────────────────────────────────────────────────────────
  static const Color textPrimaryLight = Color(0xFF1E293B); // Deep slate
  static const Color textSecondaryLight = Color(0xFF64748B); // Cool grey
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Off-white
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Muted grey

  // ── Gradients ──────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFF8E44AD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFF00CEC9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFE17055), Color(0xFFFDCB6E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient oceanGradient = LinearGradient(
    colors: [Color(0xFF0984E3), Color(0xFF00CEC9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00B894), Color(0xFF55EFC4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient forestGradient = LinearGradient(
    colors: [Color(0xFF00B894), Color(0xFF55EFC4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Returns a child-friendly gradient for card backgrounds by index.
  static LinearGradient cardGradientByIndex(int index) {
    final gradients = [
      primaryGradient,
      heroGradient,
      oceanGradient,
      sunsetGradient,
      successGradient,
      forestGradient,
    ];
    return gradients[index % gradients.length];
  }
}

/// A ThemeExtension to provide access to semantic colors that might not fit
/// directly into the standard ColorScheme.
class SemanticColors extends ThemeExtension<SemanticColors> {
  final Color success;
  final Color warning;
  final Color info;
  final Color border;

  const SemanticColors({
    required this.success,
    required this.warning,
    required this.info,
    required this.border,
  });

  factory SemanticColors.light() {
    return const SemanticColors(
      success: AppColors.success,
      warning: AppColors.warning,
      info: AppColors.info,
      border: AppColors.borderLight,
    );
  }

  factory SemanticColors.dark() {
    return const SemanticColors(
      success: AppColors.success,
      warning: AppColors.warning,
      info: AppColors.info,
      border: AppColors.borderDark,
    );
  }

  @override
  ThemeExtension<SemanticColors> copyWith({
    Color? success,
    Color? warning,
    Color? info,
    Color? border,
  }) {
    return SemanticColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      border: border ?? this.border,
    );
  }

  @override
  ThemeExtension<SemanticColors> lerp(
      ThemeExtension<SemanticColors>? other, double t) {
    if (other is! SemanticColors) return this;
    return SemanticColors(
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      info: Color.lerp(info, other.info, t) ?? info,
      border: Color.lerp(border, other.border, t) ?? border,
    );
  }
}

/// Helper extension to easily access semantic colors
extension SemanticColorsHelper on BuildContext {
  SemanticColors get semantics => Theme.of(this).extension<SemanticColors>() ?? SemanticColors.light();
}
