import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:web_dashboard/core/constants/app_colors.dart';
import 'package:web_dashboard/core/constants/app_strings.dart';
import 'package:web_dashboard/features/free_trial_lesson_files/data/models/free_trial_lesson_file_model.dart';
import 'package:web_dashboard/features/free_trial_lesson_files/presentation/manager/free_trial_lesson_files_cubit.dart';
import 'package:web_dashboard/features/lesson_files/presentation/manager/lesson_files_cubit.dart' show BatchUploadItem;
import 'package:web_dashboard/core/widgets/smart_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_dashboard/core/services/dependency_injection.dart';
import 'package:web_dashboard/features/free_trial_lesson_files/presentation/manager/free_trial_lesson_files_state.dart';

/// Screen listing files associated with a subject in a beautiful grid layout.
class FreeTrialLessonFilesScreen extends StatelessWidget {
  final String subjectId;
  const FreeTrialLessonFilesScreen({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FreeTrialLessonFilesCubit>()
        ..loadFiles(subjectId),
      child: _FreeTrialLessonFilesView(subjectId: subjectId),
    );
  }
}

class _FreeTrialLessonFilesView extends StatelessWidget {
  final String subjectId;
  const _FreeTrialLessonFilesView({required this.subjectId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocConsumer<FreeTrialLessonFilesCubit, FreeTrialLessonFilesState>(
        listener: (context, state) {
          if (state is FreeTrialLessonFilesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          if (state is FreeTrialLessonFilesLoading || state is FreeTrialLessonFilesInitial) {
            return _buildShimmer(isDark);
          }

          if (state is FreeTrialLessonFilesLoaded) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Breadcrumb
                  _buildBreadcrumb(context, isDark, state.subjectName),
                  const SizedBox(height: 16),

                  // Header with Upload Button
                  _buildHeader(context, isDark, state.uploadProgress != null),
                  const SizedBox(height: 8),

                  // Uploading State Indicator
                  if (state.uploadProgress != null) ...[
                    const SizedBox(height: 8),
                    _buildUploadProgressCard(isDark, state.uploadProgress!),
                  ],

                  const SizedBox(height: 20),

                  // Grid of files
                  Expanded(
                    child: state.files.isEmpty
                        ? _buildEmpty(isDark)
                        : _buildFilesGrid(context, state.files, isDark),
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

  Widget _buildBreadcrumb(
      BuildContext context, bool isDark, String subjectName) {
    return Row(
      children: [
        InkWell(
          onTap: () => context.pop(),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_lesson_rounded,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                const Text('الدروس',
                    style:
                        TextStyle(color: AppColors.primary, fontSize: 14)),
              ],
            ),
          ),
        ),
        Icon(Icons.chevron_left,
            size: 18,
            color: isDark
                ? AppColors.textTertiaryDark
                : AppColors.textTertiaryLight),
        Text(subjectName,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight)),
        Icon(Icons.chevron_left,
            size: 18,
            color: isDark
                ? AppColors.textTertiaryDark
                : AppColors.textTertiaryLight),
        Text(AppStrings.subjectFiles,
            style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight)),
      ],
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildHeader(BuildContext context, bool isDark, bool isUploading) {
    return Row(
      children: [
        Icon(Icons.attach_file_rounded,
            color: AppColors.primary, size: 28),
        const SizedBox(width: 12),
        Text(AppStrings.subjectFiles,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight)),
        const Spacer(),
        FilledButton.icon(
          onPressed: isUploading ? null : () => _pickAndUploadFile(context),
          icon: const Icon(Icons.cloud_upload_rounded),
          label: const Text('رفع ملفات جديدة'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadProgressCard(bool isDark, double progress) {
    return Card(
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'جاري رفع الملف... ${(progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: progress,
                    borderRadius: BorderRadius.circular(4),
                    minHeight: 6,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  Widget _buildFilesGrid(
      BuildContext context, List<FreeTrialLessonFileModel> files, bool isDark) {
    final width = MediaQuery.of(context).size.width;
    int crossAxisCount = 4;
    if (width < 600) {
      crossAxisCount = 1;
    } else if (width < 900) {
      crossAxisCount = 2;
    } else if (width < 1400) {
      crossAxisCount = 3;
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        return _buildFileCard(context, file, isDark);
      },
    );
  }

  Widget _buildFileCard(BuildContext context, FreeTrialLessonFileModel file, bool isDark) {
    final iconData = _getFileIcon(file.type);
    final themeColor = _getFileTypeColor(file.type);
    final effectiveThumbnail = _getEffectiveThumbnail(file);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _previewFile(context, file),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Cover Thumbnail Banner
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (effectiveThumbnail != null)
                    SmartImage(
                      imageUrl: resolveImageUrl(effectiveThumbnail),
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(
                        color: themeColor.withValues(alpha: 0.15),
                        child: Center(
                          child: Icon(iconData, color: themeColor, size: 40),
                        ),
                      ),
                    )
                  else
                    Container(
                      color: themeColor.withValues(alpha: 0.15),
                      child: Center(
                        child: Icon(iconData, color: themeColor, size: 40),
                      ),
                    ),
                  // Top overlay: type badge & delete action
                  Positioned(
                    top: 8,
                    right: 8,
                    left: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            file.type.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                            onPressed: () => _confirmDelete(context, file),
                            tooltip: AppStrings.delete,
                            style: IconButton.styleFrom(
                              backgroundColor: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.85),
                              padding: const EdgeInsets.all(6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bottom Details Area
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      file.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      file.fileSize,
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
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return Icons.video_library_rounded;
      case 'audio':
        return Icons.audiotrack_rounded;
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'image':
        return Icons.image_rounded;
      case 'scorm':
        return Icons.webhook_rounded;
      case 'html5':
        return Icons.html_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _getFileTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return AppColors.primary;
      case 'audio':
        return AppColors.accent;
      case 'pdf':
        return AppColors.error;
      case 'image':
        return AppColors.warning;
      case 'scorm':
      case 'html5':
        return AppColors.success;
      default:
        return AppColors.info;
    }
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.attach_file_rounded,
              size: 80,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight),
          const SizedBox(height: 16),
          Text(AppStrings.noData,
              style: TextStyle(
                  fontSize: 18,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight)),
          const SizedBox(height: 8),
          const Text('لا توجد ملفات مرفقة بهذا الدرس',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9));
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
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
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

  Future<void> _pickAndUploadFile(BuildContext context) async {
    final cubit = context.read<FreeTrialLessonFilesCubit>();
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final itemsToUpload = <BatchUploadItem>[];

        if (result.files.length == 1) {
          final pickedFile = result.files.first;
          final fileName = pickedFile.name;
          final bytesCount = pickedFile.size;
          final defaultTitle = fileName.contains('.')
              ? fileName.substring(0, fileName.lastIndexOf('.'))
              : fileName;

          final titleCtrl = TextEditingController(text: defaultTitle);
          String? title;

          if (!context.mounted) return;
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('تأكيد رفع الملف'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('أدخل اسماً توضيحياً للملف:'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'عنوان الملف *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(AppStrings.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    title = titleCtrl.text.trim();
                    Navigator.pop(ctx);
                  },
                  child: const Text('رفع'),
                ),
              ],
            ),
          );

          if (title != null && title!.isNotEmpty) {
            itemsToUpload.add(BatchUploadItem(
              title: title!,
              type: _detectFileType(fileName),
              fileName: fileName,
              bytesCount: bytesCount,
              fileBytes: pickedFile.bytes,
            ));
          }
        } else {
          // Multiple files selected
          final controllers = result.files.map((file) {
            final defaultTitle = file.name.contains('.')
                ? file.name.substring(0, file.name.lastIndexOf('.'))
                : file.name;
            return TextEditingController(text: defaultTitle);
          }).toList();

          bool confirmed = false;

          if (!context.mounted) return;
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('تأكيد رفع الملفات (${result.files.length})'),
              content: SizedBox(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('أدخل أسماء توضيحية للملفات المختارة:'),
                    const SizedBox(height: 12),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: result.files.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final file = result.files[index];
                          final fileType = _detectFileType(file.name);
                          final icon = _getFileIcon(fileType);
                          final color = _getFileTypeColor(fileType);

                          return Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.cardDark
                                  : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(icon, color: color, size: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        file.name,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? AppColors.textTertiaryDark
                                              : AppColors.textTertiaryLight,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      TextField(
                                        controller: controllers[index],
                                        decoration: const InputDecoration(
                                          labelText: 'عنوان الملف *',
                                          isDense: true,
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(AppStrings.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    confirmed = true;
                    Navigator.pop(ctx);
                  },
                  child: Text('رفع الكل (${result.files.length})'),
                ),
              ],
            ),
          );

          if (confirmed) {
            for (int i = 0; i < result.files.length; i++) {
              final file = result.files[i];
              final titleText = controllers[i].text.trim().isNotEmpty
                  ? controllers[i].text.trim()
                  : file.name;
              itemsToUpload.add(BatchUploadItem(
                title: titleText,
                type: _detectFileType(file.name),
                fileName: file.name,
                bytesCount: file.size,
                fileBytes: file.bytes,
              ));
            }
          }
        }

        if (itemsToUpload.isNotEmpty) {
          await cubit.uploadMultipleFiles(itemsToUpload);
        }
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
  }

  String _detectFileType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension)) {
      return 'video';
    } else if (['mp3', 'wav', 'aac', 'm4a', 'ogg'].contains(extension)) {
      return 'audio';
    } else if (['png', 'jpg', 'jpeg', 'gif', 'webp', 'svg'].contains(extension)) {
      return 'image';
    } else if (['zip', 'rar', '7z'].contains(extension)) {
      return 'scorm';
    } else if (['html', 'htm'].contains(extension)) {
      return 'html5';
    }
    return 'pdf';
  }

  String? _getEffectiveThumbnail(FreeTrialLessonFileModel file) {
    if (file.thumbnailUrl != null && file.thumbnailUrl!.isNotEmpty) {
      return file.thumbnailUrl;
    }
    if (sl.isRegistered<SharedPreferences>()) {
      final prefs = sl<SharedPreferences>();
      final type = file.type.toLowerCase();
      final defaultKey = 'stage_file_thumb_$type';
      final defaultUrl = prefs.getString(defaultKey);
      if (defaultUrl != null && defaultUrl.isNotEmpty) {
        return defaultUrl;
      }
    }
    return null;
  }



  void _confirmDelete(BuildContext context, FreeTrialLessonFileModel file) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.error),
          SizedBox(width: 8),
          Text('تأكيد الحذف'),
        ]),
        content: Text('هل أنت متأكد من حذف الملف "${file.title}"؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(AppStrings.cancel)),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<FreeTrialLessonFilesCubit>().deleteFile(file.id);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _previewFile(BuildContext context, FreeTrialLessonFileModel file) async {
    if (file.fileUrl.isNotEmpty) {
      final uri = Uri.parse(file.fileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تعذر فتح الملف')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رابط الملف غير متاح')),
      );
    }
  }


}

String resolveImageUrl(String path) {
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
