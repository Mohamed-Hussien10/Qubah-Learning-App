import 'package:flutter/material.dart';

/// Utility class with responsive helper methods for padding, grid counts, etc.
class ResponsiveHelper {
  ResponsiveHelper._();

  // ── Breakpoints ────────────────────────────────────────────────────────
  static const double _mobileBreakpoint = 768;
  static const double _tabletBreakpoint = 1200;

  /// Returns the current screen width.
  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  /// Returns the current screen height.
  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  /// Whether the screen is mobile-sized.
  static bool isMobile(BuildContext context) =>
      screenWidth(context) < _mobileBreakpoint;

  /// Whether the screen is tablet-sized.
  static bool isTablet(BuildContext context) {
    final w = screenWidth(context);
    return w >= _mobileBreakpoint && w < _tabletBreakpoint;
  }

  /// Whether the screen is desktop-sized.
  static bool isDesktop(BuildContext context) =>
      screenWidth(context) >= _tabletBreakpoint;

  /// Returns appropriate horizontal padding for the current breakpoint.
  static EdgeInsets paddingForScreen(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 24);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 20);
    } else {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
    }
  }

  /// Returns the appropriate content max-width for the current breakpoint.
  static double contentMaxWidth(BuildContext context) {
    if (isDesktop(context)) return 1400;
    if (isTablet(context)) return 900;
    return double.infinity;
  }

  /// Returns the number of columns for a grid layout.
  static int gridCrossAxisCount(BuildContext context, {int? forcedCount}) {
    if (forcedCount != null) return forcedCount;
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return 2;
    return 1;
  }

  /// Returns appropriate spacing for grid items.
  static double gridSpacing(BuildContext context) {
    if (isDesktop(context)) return 24;
    if (isTablet(context)) return 20;
    return 16;
  }

  /// Returns the aspect ratio for stat cards based on breakpoint.
  static double cardAspectRatio(BuildContext context) {
    if (isDesktop(context)) return 1.8;
    if (isTablet(context)) return 1.6;
    return 1.4;
  }

  /// Returns appropriate font scale factor.
  static double fontScale(BuildContext context) {
    if (isDesktop(context)) return 1.0;
    if (isTablet(context)) return 0.95;
    return 0.9;
  }

  /// Returns the sidebar width based on breakpoint.
  static double sidebarWidth(BuildContext context, {bool collapsed = false}) {
    if (collapsed) return 72;
    if (isDesktop(context)) return 280;
    return 260;
  }
}
