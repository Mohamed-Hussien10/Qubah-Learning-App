import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_dashboard/core/constants/app_colors.dart';

/// Light theme for Qubah Dashboard.
class LightTheme {
  LightTheme._();

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.cairo().fontFamily,

      // ── Color Scheme ───────────────────────────────────────────────────
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.accent,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFB2F5EA),
        onSecondaryContainer: Color(0xFF00504D),
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimaryLight,
        surfaceContainerHighest: AppColors.backgroundLight,
        error: AppColors.error,
        onError: Colors.white,
        errorContainer: AppColors.errorBg,
        outline: AppColors.borderLight,
        outlineVariant: Color(0xFFEEEFF2),
        shadow: Color(0x0A000000),
      ),

      scaffoldBackgroundColor: AppColors.backgroundLight,

      // ── AppBar ─────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textPrimaryLight,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryLight,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textSecondaryLight,
          size: 22,
        ),
      ),

      // ── Card ───────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.cardLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        margin: const EdgeInsets.all(0),
      ),

      // ── Elevated Button ────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Outlined Button ────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: AppColors.borderLight, width: 1.5),
          textStyle: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Text Button ────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Input Decoration ───────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundLight,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: GoogleFonts.cairo(
          color: AppColors.textTertiaryLight,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.cairo(
          color: AppColors.textSecondaryLight,
          fontSize: 14,
        ),
        errorStyle: GoogleFonts.cairo(
          color: AppColors.error,
          fontSize: 12,
        ),
        prefixIconColor: AppColors.textSecondaryLight,
        suffixIconColor: AppColors.textSecondaryLight,
      ),

      // ── Data Table ─────────────────────────────────────────────────────
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(
          AppColors.backgroundLight,
        ),
        dataRowColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.hovered)) {
              return AppColors.primary.withValues(alpha: 0.04);
            }
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary.withValues(alpha: 0.08);
            }
            return AppColors.surfaceLight;
          },
        ),
        headingTextStyle: GoogleFonts.cairo(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondaryLight,
        ),
        dataTextStyle: GoogleFonts.cairo(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimaryLight,
        ),
        dividerThickness: 1,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
      ),

      // ── Dialog ─────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        elevation: 8,
        backgroundColor: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryLight,
        ),
        contentTextStyle: GoogleFonts.cairo(
          fontSize: 14,
          color: AppColors.textSecondaryLight,
        ),
      ),

      // ── SnackBar ───────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimaryLight,
        contentTextStyle: GoogleFonts.cairo(
          fontSize: 14,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),

      // ── Chip ───────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.backgroundLight,
        selectedColor: AppColors.primary.withValues(alpha: 0.12),
        disabledColor: AppColors.backgroundLight,
        labelStyle: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.borderLight),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),

      // ── Divider ────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 1,
      ),

      // ── Tooltip ────────────────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.textPrimaryLight.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.cairo(
          fontSize: 12,
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // ── Floating Action Button ─────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ── Navigation Rail ────────────────────────────────────────────────
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.sidebarLight,
        selectedIconTheme: const IconThemeData(color: AppColors.primary),
        unselectedIconTheme:
            const IconThemeData(color: AppColors.textSecondaryLight),
        selectedLabelTextStyle: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
        unselectedLabelTextStyle: GoogleFonts.cairo(
          fontSize: 12,
          color: AppColors.textSecondaryLight,
        ),
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
      ),

      // ── Popup Menu ─────────────────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderLight),
        ),
        textStyle: GoogleFonts.cairo(
          fontSize: 14,
          color: AppColors.textPrimaryLight,
        ),
      ),

      // ── Tab Bar ────────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondaryLight,
        indicatorColor: AppColors.primary,
        labelStyle: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      // ── Text Theme ─────────────────────────────────────────────────────
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cairo(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimaryLight,
        ),
        displayMedium: GoogleFonts.cairo(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryLight,
        ),
        displaySmall: GoogleFonts.cairo(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryLight,
        ),
        headlineLarge: GoogleFonts.cairo(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryLight,
        ),
        headlineMedium: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
        headlineSmall: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
        titleLarge: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
        titleMedium: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
        titleSmall: GoogleFonts.cairo(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
        bodyLarge: GoogleFonts.cairo(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimaryLight,
        ),
        bodyMedium: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimaryLight,
        ),
        bodySmall: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondaryLight,
        ),
        labelLarge: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
        labelMedium: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondaryLight,
        ),
        labelSmall: GoogleFonts.cairo(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textTertiaryLight,
        ),
      ),
    );
  }
}

/// Dark theme for Qubah Dashboard.
class DarkTheme {
  DarkTheme._();

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.cairo().fontFamily,

      // ── Color Scheme ───────────────────────────────────────────────────
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        onPrimary: Color(0xFF1A1A2E),
        primaryContainer: AppColors.primaryDark,
        onPrimaryContainer: Color(0xFFE8E0FF),
        secondary: AppColors.accent,
        onSecondary: Color(0xFF003735),
        secondaryContainer: Color(0xFF004F4D),
        onSecondaryContainer: Color(0xFFB2F5EA),
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        surfaceContainerHighest: AppColors.backgroundDark,
        error: Color(0xFFFCA5A5),
        onError: Color(0xFF7F1D1D),
        errorContainer: Color(0xFF991B1B),
        outline: AppColors.borderDark,
        outlineVariant: Color(0xFF232338),
        shadow: Color(0x33000000),
      ),

      scaffoldBackgroundColor: AppColors.backgroundDark,

      // ── AppBar ─────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimaryDark,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryDark,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textSecondaryDark,
          size: 22,
        ),
      ),

      // ── Card ───────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.cardDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        margin: const EdgeInsets.all(0),
      ),

      // ── Elevated Button ────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Outlined Button ────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: AppColors.borderDark, width: 1.5),
          textStyle: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Text Button ────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Input Decoration ───────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundDark,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primaryLight, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: GoogleFonts.cairo(
          color: AppColors.textTertiaryDark,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.cairo(
          color: AppColors.textSecondaryDark,
          fontSize: 14,
        ),
        errorStyle: GoogleFonts.cairo(
          color: AppColors.error,
          fontSize: 12,
        ),
        prefixIconColor: AppColors.textSecondaryDark,
        suffixIconColor: AppColors.textSecondaryDark,
      ),

      // ── Data Table ─────────────────────────────────────────────────────
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(
          AppColors.backgroundDark,
        ),
        dataRowColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.hovered)) {
              return AppColors.primaryLight.withValues(alpha: 0.06);
            }
            if (states.contains(WidgetState.selected)) {
              return AppColors.primaryLight.withValues(alpha: 0.1);
            }
            return AppColors.surfaceDark;
          },
        ),
        headingTextStyle: GoogleFonts.cairo(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondaryDark,
        ),
        dataTextStyle: GoogleFonts.cairo(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimaryDark,
        ),
        dividerThickness: 1,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDark),
        ),
      ),

      // ── Dialog ─────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        elevation: 8,
        backgroundColor: AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryDark,
        ),
        contentTextStyle: GoogleFonts.cairo(
          fontSize: 14,
          color: AppColors.textSecondaryDark,
        ),
      ),

      // ── SnackBar ───────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.cardDark,
        contentTextStyle: GoogleFonts.cairo(
          fontSize: 14,
          color: AppColors.textPrimaryDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),

      // ── Chip ───────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.backgroundDark,
        selectedColor: AppColors.primaryLight.withValues(alpha: 0.15),
        disabledColor: AppColors.backgroundDark,
        labelStyle: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.borderDark),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),

      // ── Divider ────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.borderDark,
        thickness: 1,
        space: 1,
      ),

      // ── Tooltip ────────────────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderDark),
        ),
        textStyle: GoogleFonts.cairo(
          fontSize: 12,
          color: AppColors.textPrimaryDark,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // ── Floating Action Button ─────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ── Navigation Rail ────────────────────────────────────────────────
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.sidebarDark,
        selectedIconTheme: const IconThemeData(color: AppColors.primaryLight),
        unselectedIconTheme:
            const IconThemeData(color: AppColors.textSecondaryDark),
        selectedLabelTextStyle: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryLight,
        ),
        unselectedLabelTextStyle: GoogleFonts.cairo(
          fontSize: 12,
          color: AppColors.textSecondaryDark,
        ),
        indicatorColor: AppColors.primaryLight.withValues(alpha: 0.15),
      ),

      // ── Popup Menu ─────────────────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.cardDark,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderDark),
        ),
        textStyle: GoogleFonts.cairo(
          fontSize: 14,
          color: AppColors.textPrimaryDark,
        ),
      ),

      // ── Tab Bar ────────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primaryLight,
        unselectedLabelColor: AppColors.textSecondaryDark,
        indicatorColor: AppColors.primaryLight,
        labelStyle: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      // ── Text Theme ─────────────────────────────────────────────────────
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cairo(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimaryDark,
        ),
        displayMedium: GoogleFonts.cairo(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryDark,
        ),
        displaySmall: GoogleFonts.cairo(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryDark,
        ),
        headlineLarge: GoogleFonts.cairo(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryDark,
        ),
        headlineMedium: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryDark,
        ),
        headlineSmall: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryDark,
        ),
        titleLarge: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryDark,
        ),
        titleMedium: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryDark,
        ),
        titleSmall: GoogleFonts.cairo(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryDark,
        ),
        bodyLarge: GoogleFonts.cairo(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimaryDark,
        ),
        bodyMedium: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimaryDark,
        ),
        bodySmall: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondaryDark,
        ),
        labelLarge: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryDark,
        ),
        labelMedium: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondaryDark,
        ),
        labelSmall: GoogleFonts.cairo(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textTertiaryDark,
        ),
      ),
    );
  }
}
