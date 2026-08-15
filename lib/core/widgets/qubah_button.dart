import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

/// Gradient-filled primary action button with animation.
class QubahButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final LinearGradient? gradient;
  final IconData? icon;
  final double? width;

  const QubahButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.gradient,
    this.icon,
    this.width,
  });

  @override
  State<QubahButton> createState() => _QubahButtonState();
}

class _QubahButtonState extends State<QubahButton> {
  bool _isHovered = false;

  void _onHover(bool isHovered) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() {
        _isHovered = isHovered;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: (widget.onPressed != null && !widget.isLoading)
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      hitTestBehavior: HitTestBehavior.opaque,
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: SizedBox(
          width: widget.width ?? double.infinity,
          height: 56,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: widget.onPressed != null
                  ? (widget.gradient ?? AppColors.primaryGradient)
                  : LinearGradient(
                      colors: [Colors.grey.shade600, Colors.grey.shade700],
                    ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: widget.onPressed != null
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: _isHovered ? 16 : 12,
                        offset: Offset(0, _isHovered ? 6 : 4),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.isLoading ? null : widget.onPressed,
                mouseCursor: (widget.onPressed != null && !widget.isLoading)
                    ? SystemMouseCursors.click
                    : SystemMouseCursors.basic,
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(widget.icon, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              widget.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
    );
  }
}
