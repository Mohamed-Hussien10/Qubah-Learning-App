import 'package:flutter/material.dart';

/// Responsive breakpoint definitions and layout builder.
class ResponsiveLayout extends StatelessWidget {
  /// Widget to display on mobile (< 768px).
  final Widget mobile;

  /// Widget to display on tablet (768px - 1199px).
  final Widget? tablet;

  /// Widget to display on desktop (>= 1200px).
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  // ── Breakpoints ────────────────────────────────────────────────────────
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1200;

  /// Whether the current screen is mobile-sized.
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileBreakpoint;

  /// Whether the current screen is tablet-sized.
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Whether the current screen is desktop-sized.
  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;

  /// Returns the current screen width.
  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  /// Returns the current screen height.
  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= tabletBreakpoint) {
          return desktop;
        } else if (constraints.maxWidth >= mobileBreakpoint) {
          return tablet ?? desktop;
        } else {
          return mobile;
        }
      },
    );
  }
}
