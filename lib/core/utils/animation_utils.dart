import 'package:flutter/material.dart';

/// Centralized animation utilities for consistent durations and curves
/// across the premium educational app.
class AppAnimations {
  AppAnimations._();

  // ── Durations ───────────────────────────────────────────────────────────
  
  /// For micro-interactions (button presses, small icon changes)
  static const Duration fast = Duration(milliseconds: 150);
  
  /// For component state changes (hover, focus, simple transitions)
  static const Duration medium = Duration(milliseconds: 300);
  
  /// For page transitions, dialog appearances, and major structural changes
  static const Duration slow = Duration(milliseconds: 500);

  // ── Curves ──────────────────────────────────────────────────────────────
  
  /// Standard easing for most UI elements
  static const Curve standard = Curves.easeInOutCubic;
  
  /// Bouncy entrance for a playful, educational feel
  static const Curve playfulEntrance = Curves.elasticOut;
  
  /// Snappy exit when an element is removed
  static const Curve snappyExit = Curves.easeInQuint;

  /// Smooth deceleration for lists or scrolled items
  static const Curve deceleration = Curves.easeOutCubic;
}
