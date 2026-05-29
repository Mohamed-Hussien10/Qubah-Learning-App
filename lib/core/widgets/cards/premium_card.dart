import 'package:flutter/material.dart';
import 'package:qubah_learning_app/core/theme/design_tokens.dart';
import 'package:qubah_learning_app/core/widgets/buttons/animated_press_button.dart';

/// A premium, educational-style card that can either display a solid color
/// or a vibrant gradient. It supports an optional `onTap` which automatically
/// wraps it in an `AnimatedPressButton` for tactile feedback.
class PremiumCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  
  /// Optional gradient. If provided, overrides [color].
  final Gradient? gradient;
  
  /// The solid background color of the card. If neither this nor [gradient]
  /// is provided, the theme's card color is used.
  final Color? color;
  
  /// Optional padding inside the card. Defaults to md spacing.
  final EdgeInsetsGeometry? padding;

  const PremiumCard({
    super.key,
    required this.child,
    this.onTap,
    this.gradient,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final defaultPadding = EdgeInsets.all(context.spacing.md);
    
    Widget cardContent = Container(
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? Theme.of(context).cardColor) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(context.radius.xl),
        border: Border.all(
          color: Theme.of(context).cardTheme.shape is RoundedRectangleBorder
              ? ((Theme.of(context).cardTheme.shape as RoundedRectangleBorder).side.color)
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: padding ?? defaultPadding,
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return AnimatedPressButton(
        onPressed: onTap,
        pressedScale: 0.97, // Slightly less squish for larger cards
        child: cardContent,
      );
    }

    return cardContent;
  }
}
