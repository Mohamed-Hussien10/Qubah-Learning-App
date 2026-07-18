import 'package:flutter/material.dart';
import 'package:web_dashboard/core/constants/app_colors.dart';

class NetworkAvatar extends StatelessWidget {
  final String? imageUrl;
  final IconData defaultIcon;
  final double radius;

  const NetworkAvatar({
    super.key,
    this.imageUrl,
    required this.defaultIcon,
    this.radius = 18,
  });

  String _resolveImageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    const domainUrl = 'https://qubahom.com';
    if (path.startsWith('/')) return '$domainUrl$path';
    if (path.startsWith('storage/')) return '$domainUrl/$path';
    return '$domainUrl/storage/$path';
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primaryLight.withOpacity(0.2),
        child: Icon(defaultIcon, size: radius, color: AppColors.primary),
      );
    }

    return ClipOval(
      child: Container(
        width: radius * 2,
        height: radius * 2,
        color: AppColors.primaryLight.withOpacity(0.2),
        child: Image.network(
          _resolveImageUrl(imageUrl!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => CircleAvatar(
            radius: radius,
            backgroundColor: AppColors.primaryLight.withOpacity(0.2),
            child: Icon(defaultIcon, size: radius, color: AppColors.primary),
          ),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return CircleAvatar(
              radius: radius,
              backgroundColor: AppColors.primaryLight.withOpacity(0.2),
              child: SizedBox(
                width: radius,
                height: radius,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
        ),
      ),
    );
  }
}
