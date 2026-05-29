import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_typography.dart';
import 'design_tokens.dart';

export 'app_colors.dart';
export 'app_typography.dart';
export 'design_tokens.dart';

/// The central theme configuration for the application.
class AppTheme {
  AppTheme._();

  static final AppSpacing _spacing = const AppSpacing();
  static final AppRadius _radius = const AppRadius();
  static final AppElevation _elevation = const AppElevation();

  /// Defines the light theme configuration.
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surfaceLight,
      error: AppColors.error,
      // background is deprecated in Material 3, surface handles it.
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.scaffoldLight,
      colorScheme: colorScheme,
      textTheme: AppTypography.lightTextTheme,
      
      // Register custom design tokens
      extensions: <ThemeExtension<dynamic>>[
        _spacing,
        _radius,
        _elevation,
        SemanticColors.light(),
      ],

      // ── Component Themes ──────────────────────────────────────────────────

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.scaffoldLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.lightTextTheme.headlineSmall,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: _elevation.sm,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius.xl),
          side: const BorderSide(color: AppColors.borderLight, width: 1.5),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: _elevation.md,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
          padding: EdgeInsets.symmetric(
            horizontal: _spacing.xl,
            vertical: _spacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius.xl),
          ),
          textStyle: AppTypography.lightTextTheme.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 2),
          padding: EdgeInsets.symmetric(
            horizontal: _spacing.xl,
            vertical: _spacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius.xl),
          ),
          textStyle: AppTypography.lightTextTheme.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(
            horizontal: _spacing.md,
            vertical: _spacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius.md),
          ),
          textStyle: AppTypography.lightTextTheme.labelLarge,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: _spacing.lg,
          vertical: _spacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius.lg),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius.lg),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius.lg),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius.lg),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius.lg),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius.lg),
        ),
        backgroundColor: AppColors.textPrimaryLight,
        contentTextStyle: AppTypography.lightTextTheme.bodyMedium?.copyWith(
          color: Colors.white,
        ),
        actionTextColor: AppColors.secondary,
        elevation: _elevation.lg,
        insetPadding: EdgeInsets.symmetric(
          horizontal: _spacing.md,
          vertical: _spacing.xl,
        ),
      ),
    );
  }

  /// Defines the dark theme configuration.
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surfaceDark,
      error: AppColors.error,
      // background is deprecated in Material 3, surface handles it.
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.scaffoldDark,
      colorScheme: colorScheme,
      textTheme: AppTypography.darkTextTheme,

      // Register custom design tokens
      extensions: <ThemeExtension<dynamic>>[
        _spacing,
        _radius,
        _elevation,
        SemanticColors.dark(),
      ],

      // ── Component Themes ──────────────────────────────────────────────────

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.scaffoldDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.darkTextTheme.headlineSmall,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius.xl),
          side: const BorderSide(color: AppColors.borderDark, width: 1.5),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: _elevation.sm,
          padding: EdgeInsets.symmetric(
            horizontal: _spacing.xl,
            vertical: _spacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius.xl),
          ),
          textStyle: AppTypography.darkTextTheme.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          side: const BorderSide(color: AppColors.primaryLight, width: 2),
          padding: EdgeInsets.symmetric(
            horizontal: _spacing.xl,
            vertical: _spacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius.xl),
          ),
          textStyle: AppTypography.darkTextTheme.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          padding: EdgeInsets.symmetric(
            horizontal: _spacing.md,
            vertical: _spacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius.md),
          ),
          textStyle: AppTypography.darkTextTheme.labelLarge,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: EdgeInsets.symmetric(
          horizontal: _spacing.lg,
          vertical: _spacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius.lg),
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius.lg),
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius.lg),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius.lg),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius.lg),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius.lg),
        ),
        backgroundColor: AppColors.cardDarkElevated,
        contentTextStyle: AppTypography.darkTextTheme.bodyMedium?.copyWith(
          color: Colors.white,
        ),
        actionTextColor: AppColors.secondaryLight,
        elevation: _elevation.lg,
        insetPadding: EdgeInsets.symmetric(
          horizontal: _spacing.md,
          vertical: _spacing.xl,
        ),
      ),
    );
  }
}
