import 'dart:convert';
import 'package:flutter/material.dart';

/// A smart image widget that seamlessly renders:
/// 1. Base64 Data URIs (`data:image/...;base64,...`) via `Image.memory`
/// 2. Network URLs (`http://`, `https://`) via `Image.network`
/// 3. Graceful fallback on error
class SmartImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final ImageErrorWidgetBuilder? errorBuilder;

  const SmartImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return errorBuilder?.call(context, 'Empty image URL', null) ??
          const SizedBox.shrink();
    }

    // Handle Base64 Data URIs safely on both Mobile Native and Web
    if (imageUrl.startsWith('data:')) {
      try {
        final commaIndex = imageUrl.indexOf(',');
        final base64String =
            commaIndex != -1 ? imageUrl.substring(commaIndex + 1) : imageUrl;
        final bytes = base64Decode(base64String.trim());
        return Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (ctx, err, stack) =>
              errorBuilder?.call(ctx, err, stack) ?? const SizedBox.shrink(),
        );
      } catch (e) {
        return errorBuilder?.call(context, e, null) ?? const SizedBox.shrink();
      }
    }

    // Handle standard HTTP/HTTPS Network URLs
    return Image.network(
      imageUrl,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (ctx, err, stack) =>
          errorBuilder?.call(ctx, err, stack) ?? const SizedBox.shrink(),
    );
  }
}
