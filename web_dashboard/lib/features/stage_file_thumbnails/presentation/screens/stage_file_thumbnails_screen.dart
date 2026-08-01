import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import 'package:web_dashboard/core/widgets/smart_image.dart';
import 'package:web_dashboard/core/constants/app_colors.dart';
import 'package:web_dashboard/core/services/dependency_injection.dart';
import 'package:web_dashboard/features/stage_file_thumbnails/presentation/manager/stage_file_thumbnails_cubit.dart';
import 'package:web_dashboard/features/stage_file_thumbnails/presentation/manager/stage_file_thumbnails_state.dart';

class StageFileThumbnailsScreen extends StatelessWidget {
  const StageFileThumbnailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StageFileThumbnailsCubit>()..loadData(),
      child: const _StageFileThumbnailsView(),
    );
  }
}

class _StageFileThumbnailsView extends StatelessWidget {
  const _StageFileThumbnailsView();

  static const List<Map<String, dynamic>> _fileFormats = [
    {
      'key': 'pdf',
      'name': 'ملفات PDF',
      'icon': Icons.picture_as_pdf_rounded,
      'color': AppColors.error,
      'description': 'الصورة المصغرة الافتراضية للمستندات والملفات النصية',
    },
    {
      'key': 'video',
      'name': 'الفيديوهات',
      'icon': Icons.video_library_rounded,
      'color': AppColors.primary,
      'description': 'الصورة المصغرة الافتراضية لمقاطع الفيديو الدروس',
    },
    {
      'key': 'audio',
      'name': 'الملفات الصوتية',
      'icon': Icons.audiotrack_rounded,
      'color': AppColors.accent,
      'description': 'الصورة المصغرة الافتراضية للشروحات والقصائد الصوتية',
    },
    {
      'key': 'image',
      'name': 'الصور والرسومات',
      'icon': Icons.image_rounded,
      'color': AppColors.warning,
      'description': 'الصورة المصغرة الافتراضية للبطاقات التوضيحية والإنفوجرافيك',
    },
    {
      'key': 'scorm',
      'name': 'حزم SCORM',
      'icon': Icons.webhook_rounded,
      'color': AppColors.success,
      'description': 'الصورة المصغرة الافتراضية للمحتوى التفاعلي المنظم',
    },
    {
      'key': 'html5',
      'name': 'محتوى HTML5',
      'icon': Icons.html_rounded,
      'color': AppColors.info,
      'description': 'الصورة المصغرة الافتراضية للألعاب والأنشطة التفاعلية',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocConsumer<StageFileThumbnailsCubit, StageFileThumbnailsState>(
        listener: (context, state) {
          if (state is StageFileThumbnailsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is StageFileThumbnailsLoading || state is StageFileThumbnailsInitial) {
            return _buildShimmer(isDark);
          }

          if (state is StageFileThumbnailsLoaded) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Header ──────────────────────────────────────────────
                  _buildHeader(context, isDark),
                  const SizedBox(height: 20),

                  // ── Stage Selector Filter ────────────────────────────────
                  _buildStageSelector(context, isDark, state),
                  const SizedBox(height: 24),

                  if (state.isUpdating) ...[
                    const LinearProgressIndicator(minHeight: 4),
                    const SizedBox(height: 16),
                  ],

                  // ── Formats Grid ─────────────────────────────────────────
                  Expanded(
                    child: _buildFormatsGrid(context, isDark, state),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.02, end: 0);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.photo_library_rounded, color: AppColors.primary, size: 28),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'صور مصغرة للملفات بحسب المرحلة',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'إدارة الصورة المصغرة الافتراضية لكل صيغة ملف حسب المرحلة التعليمية',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStageSelector(
    BuildContext context,
    bool isDark,
    StageFileThumbnailsLoaded state,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            const Icon(Icons.account_balance_rounded, color: AppColors.primary),
            const SizedBox(width: 12),
            const Text(
              'المرحلة التعليمية:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: state.stages.map((stage) {
                    final isSelected = state.selectedStage?.id == stage.id;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ChoiceChip(
                        label: Text(stage.title),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            context.read<StageFileThumbnailsCubit>().selectStage(stage);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatsGrid(
    BuildContext context,
    bool isDark,
    StageFileThumbnailsLoaded state,
  ) {
    final width = MediaQuery.of(context).size.width;
    int crossAxisCount = 3;
    if (width < 700) {
      crossAxisCount = 1;
    } else if (width < 1100) {
      crossAxisCount = 2;
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.1,
      ),
      itemCount: _fileFormats.length,
      itemBuilder: (context, index) {
        final formatInfo = _fileFormats[index];
        final formatKey = formatInfo['key'] as String;
        final currentUrl = state.thumbnails[formatKey];

        return _buildFormatCard(context, isDark, formatInfo, currentUrl);
      },
    );
  }

  Widget _buildFormatCard(
    BuildContext context,
    bool isDark,
    Map<String, dynamic> formatInfo,
    String? currentUrl,
  ) {
    final formatKey = formatInfo['key'] as String;
    final formatName = formatInfo['name'] as String;
    final iconData = formatInfo['icon'] as IconData;
    final color = formatInfo['color'] as Color;
    final description = formatInfo['description'] as String;

    final hasThumbnail = currentUrl != null && currentUrl.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Format Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(iconData, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Image Preview Area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: hasThumbnail
                        ? color.withValues(alpha: 0.3)
                        : (isDark ? AppColors.borderDark : AppColors.borderLight),
                    width: 1.5,
                  ),
                ),
                child: hasThumbnail
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            SmartImage(
                              imageUrl: _resolveImageUrl(currentUrl),
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) {
                                return Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(iconData, color: color, size: 36),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'تعذر تحميل الصورة',
                                        style: TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_rounded, color: Colors.green, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      'تم التعيين',
                                      style: TextStyle(color: Colors.white, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(iconData,
                                size: 40,
                                color: color.withValues(alpha: 0.4)),
                            const SizedBox(height: 8),
                            Text(
                              'لا تتوفر صورة مصغرة افتراضية',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.textTertiaryDark
                                    : AppColors.textTertiaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickAndUploadImage(context, formatKey, formatName),
                    icon: const Icon(Icons.upload_file_rounded, size: 18),
                    label: Text(hasThumbnail ? 'تغيير الصورة' : 'إضافة صورة'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                if (hasThumbnail) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _confirmRemove(context, formatKey, formatName),
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                    tooltip: 'حذف الصورة المصغرة',
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(10),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage(
    BuildContext context,
    String formatKey,
    String formatName,
  ) async {
    final cubit = context.read<StageFileThumbnailsCubit>();
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.first;
        if (pickedFile.bytes != null) {
          final success = await cubit.uploadFormatThumbnail(
            format: formatKey,
            imageBytes: pickedFile.bytes!,
            fileName: pickedFile.name,
          );

          if (success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم حفظ الصورة المصغرة لـ $formatName بنجاح'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking stage file thumbnail: $e');
    }
  }

  void _confirmRemove(
    BuildContext context,
    String formatKey,
    String formatName,
  ) {
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
        content: Text('هل أنت متأكد من حذف الصورة المصغرة الافتراضية لـ "$formatName"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context
                  .read<StageFileThumbnailsCubit>()
                  .removeFormatThumbnail(formatKey);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم حذف الصورة المصغرة لـ $formatName'),
                    backgroundColor: AppColors.info,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Shimmer.fromColors(
        baseColor: isDark ? AppColors.surfaceDark : Colors.grey.shade200,
        highlightColor: isDark ? AppColors.cardDark : Colors.grey.shade50,
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1.1,
          children: List.generate(
            6,
            (_) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _resolveImageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('data:')) return path;
    if (path.contains('thumbnails/')) {
      final fileName = path.split('thumbnails/').last;
      return 'https://qubahom.com/api/v1/thumbnails/$fileName';
    }
    if (path.startsWith('http')) return path;
    const baseUrl = 'https://qubahom.com';
    if (path.startsWith('/')) return '$baseUrl$path';
    if (path.startsWith('storage/')) return '$baseUrl/$path';
    return '$baseUrl/storage/$path';
  }
}
