import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/helpers.dart';

class ChildFriendlyCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final VoidCallback onTap;
  final Color color;
  final IconData defaultIcon;

  const ChildFriendlyCard({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    required this.onTap,
    required this.color,
    this.defaultIcon = Icons.star_rounded,
  });

  @override
  State<ChildFriendlyCard> createState() => _ChildFriendlyCardState();
}

class _ChildFriendlyCardState extends State<ChildFriendlyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      cursor: SystemMouseCursors.click,
      hitTestBehavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => AnimatedScale(
          scale: _isHovered ? 1.02 : _scaleAnimation.value,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: widget.color.withValues(alpha: _isHovered ? 0.5 : 0.2),
                  width: _isHovered ? 2.5 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(
                      alpha: _isHovered ? 0.4 : 0.2,
                    ),
                    blurRadius: _isHovered ? 20 : 15,
                    offset: Offset(0, _isHovered ? 12 : 8),
                  ),
                  // Inner highlight simulation (adapts to theme)
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.white.withValues(alpha: 0.5)
                        : Colors.white10,
                    blurRadius: 2,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: InkWell(
                onTap: widget.onTap,
                mouseCursor: SystemMouseCursors.click,
                onHighlightChanged: (isHighlighted) {
                  if (isHighlighted) {
                    _controller.forward();
                  } else {
                    _controller.reverse();
                  }
                },
                borderRadius: BorderRadius.circular(24),
                splashColor: widget.color.withValues(alpha: 0.2),
                highlightColor: widget.color.withValues(alpha: 0.1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.color.withValues(alpha: 0.15),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(22),
                            topRight: Radius.circular(22),
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(22),
                            topRight: Radius.circular(22),
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                          child:
                              widget.imageUrl != null &&
                                  widget.imageUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: AppHelpers.resolveMediaUrl(widget.imageUrl!),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  placeholder: (context, url) => Container(
                                    color: widget.color.withValues(alpha: 0.1),
                                  ),
                                  errorWidget: (context, url, error) => Icon(
                                    widget.defaultIcon,
                                    size: 60,
                                    color: widget.color,
                                  ),
                                )
                              : Icon(
                                  widget.defaultIcon,
                                  size: 60,
                                  color: widget.color,
                                ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              widget.title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (widget.subtitle != null &&
                                widget.subtitle!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                widget.subtitle!,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
