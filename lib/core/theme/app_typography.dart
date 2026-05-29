import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Defines the typography system for the application using Material 3 TextTheme.
class AppTypography {
  AppTypography._();

  /// Returns the TextTheme for the Light Mode.
  static TextTheme get lightTextTheme {
    return _buildTextTheme(AppColors.textPrimaryLight, AppColors.textSecondaryLight);
  }

  /// Returns the TextTheme for the Dark Mode.
  static TextTheme get darkTextTheme {
    return _buildTextTheme(AppColors.textPrimaryDark, AppColors.textSecondaryDark);
  }

  static TextTheme _buildTextTheme(Color primaryColor, Color secondaryColor) {
    // We use GoogleFonts.cairo to provide a friendly, highly legible font
    // that has excellent support for Arabic and English.
    return GoogleFonts.cairoTextTheme(
      TextTheme(
        // Display - For very large marketing or hero sections
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.25,
          color: primaryColor,
          height: 1.12,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.bold,
          letterSpacing: 0,
          color: primaryColor,
          height: 1.15,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          letterSpacing: 0,
          color: primaryColor,
          height: 1.2,
        ),

        // Headline - For major screen titles
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
          color: primaryColor,
          height: 1.25,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
          color: primaryColor,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
          color: primaryColor,
          height: 1.3,
        ),

        // Title - For cards, dialogs, sub-sections
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: primaryColor,
          height: 1.3,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          color: primaryColor,
          height: 1.5,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: primaryColor,
          height: 1.4,
        ),

        // Body - For general text and long form content
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          color: secondaryColor,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          color: secondaryColor,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          color: secondaryColor,
          height: 1.3,
        ),

        // Label - For buttons, overline, and tiny hints
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700, // Thicker for buttons
          letterSpacing: 0.1,
          color: primaryColor,
          height: 1.4,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: secondaryColor,
          height: 1.3,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: secondaryColor,
          height: 1.3,
        ),
      ),
    );
  }
}
