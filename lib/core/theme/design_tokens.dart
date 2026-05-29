import 'package:flutter/material.dart';

/// Defines consistent spacing tokens for the application.
class AppSpacing extends ThemeExtension<AppSpacing> {
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;

  const AppSpacing({
    this.xs = 4.0,
    this.sm = 8.0,
    this.md = 16.0,
    this.lg = 24.0,
    this.xl = 32.0,
    this.xxl = 48.0,
  });

  @override
  ThemeExtension<AppSpacing> copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
  }) {
    return AppSpacing(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
    );
  }

  @override
  ThemeExtension<AppSpacing> lerp(ThemeExtension<AppSpacing>? other, double t) {
    if (other is! AppSpacing) return this;
    return AppSpacing(
      xs: _lerpDouble(xs, other.xs, t),
      sm: _lerpDouble(sm, other.sm, t),
      md: _lerpDouble(md, other.md, t),
      lg: _lerpDouble(lg, other.lg, t),
      xl: _lerpDouble(xl, other.xl, t),
      xxl: _lerpDouble(xxl, other.xxl, t),
    );
  }

  double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

/// Defines consistent border radius tokens for the application.
class AppRadius extends ThemeExtension<AppRadius> {
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double pill;

  const AppRadius({
    this.sm = 8.0,
    this.md = 12.0,
    this.lg = 16.0,
    this.xl = 24.0,
    this.pill = 999.0,
  });

  @override
  ThemeExtension<AppRadius> copyWith({
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? pill,
  }) {
    return AppRadius(
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      pill: pill ?? this.pill,
    );
  }

  @override
  ThemeExtension<AppRadius> lerp(ThemeExtension<AppRadius>? other, double t) {
    if (other is! AppRadius) return this;
    return AppRadius(
      sm: _lerpDouble(sm, other.sm, t),
      md: _lerpDouble(md, other.md, t),
      lg: _lerpDouble(lg, other.lg, t),
      xl: _lerpDouble(xl, other.xl, t),
      pill: _lerpDouble(pill, other.pill, t),
    );
  }

  double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

/// Defines consistent elevation tokens for the application.
class AppElevation extends ThemeExtension<AppElevation> {
  final double sm;
  final double md;
  final double lg;

  const AppElevation({
    this.sm = 2.0,
    this.md = 4.0,
    this.lg = 8.0,
  });

  @override
  ThemeExtension<AppElevation> copyWith({
    double? sm,
    double? md,
    double? lg,
  }) {
    return AppElevation(
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
    );
  }

  @override
  ThemeExtension<AppElevation> lerp(
      ThemeExtension<AppElevation>? other, double t) {
    if (other is! AppElevation) return this;
    return AppElevation(
      sm: _lerpDouble(sm, other.sm, t),
      md: _lerpDouble(md, other.md, t),
      lg: _lerpDouble(lg, other.lg, t),
    );
  }

  double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

/// Helper extension on BuildContext to easily access design tokens
extension DesignTokensHelper on BuildContext {
  AppSpacing get spacing => Theme.of(this).extension<AppSpacing>() ?? const AppSpacing();
  AppRadius get radius => Theme.of(this).extension<AppRadius>() ?? const AppRadius();
  AppElevation get elevation => Theme.of(this).extension<AppElevation>() ?? const AppElevation();
}
