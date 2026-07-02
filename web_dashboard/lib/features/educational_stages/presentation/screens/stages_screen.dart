import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import 'package:web_dashboard/core/constants/app_colors.dart';
import 'package:web_dashboard/core/constants/app_strings.dart';
import 'package:web_dashboard/features/educational_stages/data/models/stage_model.dart';
import 'package:web_dashboard/features/educational_stages/presentation/manager/stages_cubit.dart';
import 'package:web_dashboard/features/educational_stages/presentation/manager/stages_state.dart';
import 'package:web_dashboard/core/services/dependency_injection.dart';
import 'package:web_dashboard/features/educational_stages/presentation/widgets/stage_form_dialog.dart';

/// Full management screen for educational stages.
class StagesScreen extends StatelessWidget {
  const StagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<StagesCubit>()..loadStages(),
      child: const _StagesView(),
    );
  }
}

class _StagesView extends StatelessWidget {
  const _StagesView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ─────────────────────────────────────────────
            _buildHeader(context, isDark),
            const SizedBox(height: 20),

            // ── Search Bar ─────────────────────────────────────────
            _buildSearchBar(context, isDark),
            const SizedBox(height: 20),

            // ── Table ──────────────────────────────────────────────
            Expanded(child: _buildBody(context, isDark)),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.02, end: 0),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        Icon(Icons.school_rounded,
            color: AppColors.primary, size: 28),
        const SizedBox(width: 12),
        Text(
          AppStrings.stages,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
        ),
        const Spacer(),
        FilledButton.icon(
          onPressed: () => _showForm(context),
          icon: const Icon(Icons.add_rounded),
          label: Text('${AppStrings.add} مرحلة'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  // ── Search ─────────────────────────────────────────────────────────────

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: AppStrings.search,
          prefixIcon: const Icon(Icons.search),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: (q) => context.read<StagesCubit>().search(q),
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 300.ms);
  }

  // ── Body (State Switcher) ──────────────────────────────────────────────

  Widget _buildBody(BuildContext context, bool isDark) {
    return BlocBuilder<StagesCubit, StagesState>(
      builder: (context, state) {
        if (state is StagesLoading) return _buildShimmer(isDark);
        if (state is StagesError) return _buildError(context, state.message, isDark);
        if (state is StagesLoaded) {
          if (state.filteredStages.isEmpty) {
            return _buildEmpty(isDark);
          }
          return _buildTable(context, state.filteredStages, isDark);
        }
        return const SizedBox.shrink();
      },
    );
  }

  // ── Data Table ─────────────────────────────────────────────────────────

  Widget _buildTable(
      BuildContext context, List<StageModel> stages, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: DataTable2(
          columnSpacing: 16,
          horizontalMargin: 20,
          minWidth: 700,
          headingRowColor: WidgetStateProperty.all(
            isDark
                ? AppColors.surfaceDark
                : AppColors.backgroundLight,
          ),
          headingTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          dataTextStyle: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
          columns: const [
            DataColumn2(label: Text(AppStrings.order), fixedWidth: 70),
            DataColumn2(label: Text(AppStrings.title), size: ColumnSize.L),
            DataColumn2(label: Text(AppStrings.description), size: ColumnSize.L),
            DataColumn2(label: Text(AppStrings.status), fixedWidth: 100),
            DataColumn2(label: Text('الصفوف'), fixedWidth: 90),
            DataColumn2(label: Text(AppStrings.actions), fixedWidth: 200),
          ],
          rows: stages.asMap().entries.map((entry) {
            final stage = entry.value;
            return DataRow2(
              onTap: () => _navigateToGrades(context, stage),
              cells: [
                DataCell(Text('${stage.order}')),
                DataCell(
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                          backgroundImage: (stage.thumbnailUrl != null &&
                                  stage.thumbnailUrl!.isNotEmpty)
                              ? NetworkImage(resolveImageUrl(stage.thumbnailUrl!))
                              : null,
                        onBackgroundImageError: (stage.thumbnailUrl != null && stage.thumbnailUrl!.isNotEmpty) 
                            ? (_, __) {} 
                            : null,
                        child: (stage.thumbnailUrl == null || stage.thumbnailUrl!.isEmpty)
                            ? const Icon(Icons.school, size: 18, color: AppColors.primary)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          stage.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(Text(
                  stage.description ?? '—',
                  overflow: TextOverflow.ellipsis,
                )),
                DataCell(_StatusBadge(isActive: stage.isActive)),
                DataCell(Text('${stage.gradesCount}')),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ActionIcon(
                        icon: Icons.edit_rounded,
                        tooltip: AppStrings.edit,
                        color: AppColors.warning,
                        onTap: () => _showForm(context, stage: stage),
                      ),
                      _ActionIcon(
                        icon: Icons.delete_outline_rounded,
                        tooltip: AppStrings.delete,
                        color: AppColors.error,
                        onTap: () =>
                            _confirmDelete(context, stage),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  // ── Empty State ────────────────────────────────────────────────────────

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.school_outlined,
              size: 80,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight),
          const SizedBox(height: 16),
          Text(
            AppStrings.noData,
            style: TextStyle(
              fontSize: 18,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لا توجد مراحل تعليمية حالياً',
            style: TextStyle(
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9));
  }

  // ── Error State ────────────────────────────────────────────────────────

  Widget _buildError(BuildContext context, String message, bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 80, color: AppColors.error),
          const SizedBox(height: 16),
          Text(message,
              style: const TextStyle(color: AppColors.error, fontSize: 16)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.read<StagesCubit>().loadStages(),
            icon: const Icon(Icons.refresh),
            label: const Text(AppStrings.refresh),
          ),
        ],
      ),
    );
  }

  // ── Loading Shimmer ────────────────────────────────────────────────────

  Widget _buildShimmer(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Shimmer.fromColors(
        baseColor:
            isDark ? AppColors.surfaceDark : Colors.grey.shade200,
        highlightColor:
            isDark ? AppColors.cardDark : Colors.grey.shade50,
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: 5,
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Actions ────────────────────────────────────────────────────────────

  void _showForm(BuildContext context, {StageModel? stage}) {
    final cubit = context.read<StagesCubit>();
    StageFormDialog.show(
      context,
      stage: stage,
      onSave: (s, {imageBytes, imageName, bgImageBytes, bgImageName}) async {
        if (stage != null) {
          await cubit.updateStage(s, imageBytes: imageBytes, imageName: imageName, bgImageBytes: bgImageBytes, bgImageName: bgImageName);
        } else {
          await cubit.createStage(s, imageBytes: imageBytes, imageName: imageName, bgImageBytes: bgImageBytes, bgImageName: bgImageName);
        }
      },
    );
  }

  void _confirmDelete(BuildContext context, StageModel stage) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('تأكيد الحذف'),
          ],
        ),
        content: Text('هل أنت متأكد من حذف "${stage.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<StagesCubit>().deleteStage(stage.id);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  void _navigateToGrades(BuildContext context, StageModel stage) {
    context.push('/grades/${stage.id}');
  }

  String resolveImageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.contains('thumbnails/')) {
      final fileName = path.split('thumbnails/').last;
      return 'http://127.0.0.1:8000/api/v1/thumbnails/' + fileName;
    }
    if (path.startsWith('http')) return path;
    const baseUrl = 'http://127.0.0.1:8000';
    if (path.startsWith('/')) return '$baseUrl$path';
    if (path.startsWith('storage/')) return '$baseUrl/$path';
    return '$baseUrl/storage/$path';
  }
}

// ── Helper Widgets ───────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? AppColors.successBg : AppColors.errorBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? AppStrings.active : AppStrings.inactive,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? AppColors.success : AppColors.error,
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}
