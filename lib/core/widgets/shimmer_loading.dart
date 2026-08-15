import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer loading placeholder for a single card.
class ShimmerCard extends StatelessWidget {
  final double? height;
  final double? width;
  final double borderRadius;

  const ShimmerCard({
    super.key,
    this.height,
    this.width,
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF1E1E32) : const Color(0xFFE0E0E0),
      highlightColor: isDark ? const Color(0xFF2A2A44) : const Color(0xFFF5F5F5),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E32) : const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Shimmer loading list (for list-based screens like Support).
class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const ShimmerList({super.key, this.itemCount = 5, this.itemHeight = 100});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => ShimmerCard(height: itemHeight, borderRadius: 16),
    );
  }
}

/// Shimmer grid that exactly matches the card grid layout used across all screens.
/// Uses [SliverGridDelegateWithMaxCrossAxisExtent] with maxCrossAxisExtent: 280
/// and a responsive aspect ratio — identical to the real card grids.
class ShimmerGrid extends StatelessWidget {
  final int itemCount;

  const ShimmerGrid({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Mirror the exact childAspectRatio logic used in card screens
    final double childAspectRatio;
    if (width >= 1200) {
      childAspectRatio = 1.2; // desktop
    } else if (width >= 600) {
      childAspectRatio = 1.0; // tablet
    } else {
      childAspectRatio = 0.85; // mobile
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, __) => const ShimmerCard(),
    );
  }
}
