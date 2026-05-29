import 'package:flutter/material.dart';

/// Defines breakpoints for responsive design.
class Breakpoints {
  static const double mobile = 600.0;
  static const double tablet = 900.0;
  static const double desktop = 1200.0;
}

/// Helper extension on BuildContext to easily create responsive layouts
/// suitable for both phones and tablets in an educational app context.
extension ResponsiveUtils on BuildContext {
  /// Returns the width of the screen
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Returns the height of the screen
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Returns true if the screen is considered mobile sized
  bool get isMobile => screenWidth < Breakpoints.mobile;

  /// Returns true if the screen is considered tablet sized
  bool get isTablet => screenWidth >= Breakpoints.mobile && screenWidth < Breakpoints.tablet;

  /// Returns true if the screen is considered desktop sized
  bool get isDesktop => screenWidth >= Breakpoints.tablet;

  /// Calculate a responsive value based on the screen width.
  /// For example, `context.responsiveValue(mobile: 16, tablet: 24, desktop: 32)`
  T responsiveValue<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) {
      return desktop;
    }
    if ((isTablet || isDesktop) && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  /// Calculates an optimal cross axis count for GridViews based on screen width
  int get responsiveGridColumns {
    if (isDesktop) return 4;
    if (isTablet) return 3;
    return 2;
  }
}
