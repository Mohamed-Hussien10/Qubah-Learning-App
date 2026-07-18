import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/services/dependency_injection.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/breadcrumb_nav.dart';
import '../../../../core/widgets/child_friendly_card.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../../core/utils/error_utils.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Free Trial Subjects Screen
// Fetches from: GET /free-trial/grades/{gradeId}/subjects
// Returns: FreeTrialSubject[] → fields: id, title, description, thumbnail_path, thumbnail_url
// ─────────────────────────────────────────────────────────────────────────────

class FreeTrialSubjectsScreen extends StatefulWidget {
  final String gradeId;
  final List<String> titlePath;
  final String? backgroundImageUrl;

  const FreeTrialSubjectsScreen({
    super.key,
    required this.gradeId,
    this.titlePath = const [],
    this.backgroundImageUrl,
  });

  @override
  State<FreeTrialSubjectsScreen> createState() =>
      _FreeTrialSubjectsScreenState();
}

class _FreeTrialSubjectsScreenState extends State<FreeTrialSubjectsScreen> {
  List<dynamic> _subjects = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final dio = sl<DioClient>();
      final res =
          await dio.get('/free-trial/grades/${widget.gradeId}/subjects');
      if (mounted) {
        setState(() {
          _subjects = (res.data['data'] as List?) ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  /// Resolve the thumbnail URL returned by FreeTrialSubject model.
  /// Backend appends `thumbnail_url` (full URL) and also exposes `thumbnail_path`.
  String? _resolveImage(dynamic item) {
    // Prefer the appended full URL from the backend model
    final thumbUrl = item['thumbnail_url'] as String?;
    if (thumbUrl != null && thumbUrl.isNotEmpty) return thumbUrl;
    // Fallback: build from thumbnail_path
    final thumbPath = item['thumbnail_path'] as String?;
    if (thumbPath != null && thumbPath.isNotEmpty) {
      return '${ApiEndpoints.domainUrl}/storage/$thumbPath';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: widget.backgroundImageUrl != null &&
                  widget.backgroundImageUrl!.isNotEmpty
              ? BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      AppHelpers.resolveMediaUrl(widget.backgroundImageUrl!),
                    ),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.white.withValues(alpha: 0.15),
                      BlendMode.lighten,
                    ),
                  ),
                )
              : null,
          child: Column(
            children: [
              if (widget.titlePath.isNotEmpty)
                BreadcrumbNav(pathNames: widget.titlePath),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const ShimmerGrid();

    if (_error != null) {
      return ErrorDisplay(
        message: ErrorUtils.getFriendlyMessage(_error!),
        onRetry: _loadSubjects,
      );
    }

    if (_subjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_rounded,
                size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'لا توجد مواد تجريبية',
              style: TextStyle(fontSize: 20, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    final itemCount = _subjects.length;
    final crossAxisCount = itemCount == 1 ? 1 : 2;
    final childAspectRatio = itemCount == 1 ? 1.5 : 0.85;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final item = _subjects[index];
        return ChildFriendlyCard(
          // Backend field: title
          title: item['title'] as String? ?? '',
          // Backend field: description
          subtitle: item['description'] as String?,
          // Backend appended field: thumbnail_url
          imageUrl: _resolveImage(item),
          color: Colors.green,
          defaultIcon: Icons.menu_book_rounded,
          onTap: () {
            context.push(
              '/free-trial-lesson-files/${item['id']}',
              extra: {
                'titlePath': [
                  ...widget.titlePath,
                  item['title'] as String? ?? ''
                ],
                'backgroundImageUrl': widget.backgroundImageUrl,
              },
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Free Trial Lesson Files Screen
// Fetches from: GET /free-trial/subjects/{subjectId}/lesson-files
// Returns: FreeTrialLessonFile[] → fields: id, title, type, file_path,
//          thumbnail_path, thumbnail_url (appended), file_url (appended)
// ─────────────────────────────────────────────────────────────────────────────

class FreeTrialLessonFilesScreen extends StatefulWidget {
  final String subjectId;
  final List<String> titlePath;

  const FreeTrialLessonFilesScreen({
    super.key,
    required this.subjectId,
    this.titlePath = const [],
  });

  @override
  State<FreeTrialLessonFilesScreen> createState() =>
      _FreeTrialLessonFilesScreenState();
}

class _FreeTrialLessonFilesScreenState
    extends State<FreeTrialLessonFilesScreen> {
  List<dynamic> _files = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final dio = sl<DioClient>();
      final res = await dio
          .get('/free-trial/subjects/${widget.subjectId}/lesson-files');
      if (mounted) {
        setState(() {
          _files = (res.data['data'] as List?) ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  /// Resolve thumbnail: prefer backend-appended `thumbnail_url`, else build from `thumbnail_path`.
  String? _resolveThumbnail(dynamic file) {
    final thumbUrl = file['thumbnail_url'] as String?;
    if (thumbUrl != null && thumbUrl.isNotEmpty) return thumbUrl;
    final thumbPath = file['thumbnail_path'] as String?;
    if (thumbPath != null && thumbPath.isNotEmpty) {
      return '${ApiEndpoints.domainUrl}/storage/$thumbPath';
    }
    return null;
  }

  /// Resolve file URL: prefer backend-appended `file_url`, else build from `file_path`.
  String _resolveFileUrl(dynamic file) {
    final fileUrl = file['file_url'] as String?;
    if (fileUrl != null && fileUrl.isNotEmpty) return fileUrl;
    final filePath = file['file_path'] as String?;
    if (filePath == null || filePath.isEmpty) return '';
    return AppHelpers.resolveMediaUrl(filePath);
  }

  void _openFile(BuildContext context, dynamic file) {
    final fileUrl = _resolveFileUrl(file);
    if (fileUrl.isEmpty) return;

    final title = file['title'] as String? ?? '';
    final type = (file['type'] as String? ?? '').toLowerCase();
    final coverUrl = _resolveThumbnail(file);

    if (type == 'video' || type == 'mp4') {
      context.push(AppRoutes.videoPlayer,
          extra: {'videoUrl': fileUrl, 'title': title});
    } else if (type == 'audio' || type == 'mp3') {
      context.push(AppRoutes.audioPlayer, extra: {
        'audioUrl': fileUrl,
        'title': title,
        'coverImageUrl': coverUrl,
      });
    } else if (type == 'pdf') {
      context.push(AppRoutes.pdfViewer,
          extra: {'pdfUrl': fileUrl, 'title': title});
    } else if (type == 'scorm' || type == 'interactive') {
      context.push(AppRoutes.interactiveViewer,
          extra: {'contentUrl': fileUrl, 'title': title});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('نوع الملف غير مدعوم')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (widget.titlePath.isNotEmpty)
              BreadcrumbNav(pathNames: widget.titlePath),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const ShimmerGrid();

    if (_error != null) {
      return ErrorDisplay(
        message: ErrorUtils.getFriendlyMessage(_error!),
        onRetry: _loadFiles,
      );
    }

    if (_files.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_rounded,
                size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'لا توجد ملفات تجريبية',
              style: TextStyle(fontSize: 20, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _files.length,
      itemBuilder: (context, index) {
        final item = _files[index];
        final type = (item['type'] as String? ?? '').toLowerCase();

        IconData icon;
        Color color;
        switch (type) {
          case 'video':
          case 'mp4':
            icon = Icons.play_circle_fill_rounded;
            color = Colors.red;
            break;
          case 'pdf':
            icon = Icons.picture_as_pdf_rounded;
            color = Colors.orange;
            break;
          case 'audio':
          case 'mp3':
            icon = Icons.audiotrack_rounded;
            color = Colors.purple;
            break;
          case 'scorm':
          case 'interactive':
            icon = Icons.web_rounded;
            color = Colors.teal;
            break;
          default:
            icon = Icons.insert_drive_file_rounded;
            color = Colors.grey;
        }

        return ChildFriendlyCard(
          // Backend field: title
          title: item['title'] as String? ?? '',
          subtitle: type.toUpperCase(),
          // Backend appended field: thumbnail_url
          imageUrl: _resolveThumbnail(item),
          color: color,
          defaultIcon: icon,
          onTap: () => _openFile(context, item),
        );
      },
    );
  }
}
