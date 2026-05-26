import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:web_dashboard/core/constants/app_colors.dart';

/// Loading shimmer widget that mimics a data table or card grid.
class LoadingWidget extends StatelessWidget {
  /// The type of shimmer layout to display.
  final LoadingType type;

  /// Number of shimmer items to display.
  final int itemCount;

  const LoadingWidget({
    super.key,
    this.type = LoadingType.table,
    this.itemCount = 5,
  });

  const LoadingWidget.table({super.key, this.itemCount = 5})
      : type = LoadingType.table;

  const LoadingWidget.cards({super.key, this.itemCount = 4})
      : type = LoadingType.cards;

  const LoadingWidget.list({super.key, this.itemCount = 6})
      : type = LoadingType.list;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? AppColors.surfaceDark : AppColors.backgroundLight;
    final highlightColor =
        isDark ? AppColors.cardDark : AppColors.surfaceLight;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: switch (type) {
        LoadingType.table => _buildTableShimmer(),
        LoadingType.cards => _buildCardsShimmer(),
        LoadingType.list => _buildListShimmer(),
      },
    );
  }

  Widget _buildTableShimmer() {
    return Column(
      children: [
        // Header row
        Container(
          height: 48,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        // Data rows
        ...List.generate(
          itemCount,
          (index) => Container(
            height: 56,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardsShimmer() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.6,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  Widget _buildListShimmer() {
    return Column(
      children: List.generate(
        itemCount,
        (index) => Container(
          height: 72,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

/// Types of loading shimmer layouts.
enum LoadingType {
  /// Mimics a data table with header and rows.
  table,

  /// Mimics a grid of cards (e.g., stat cards).
  cards,

  /// Mimics a vertical list of items.
  list,
}
