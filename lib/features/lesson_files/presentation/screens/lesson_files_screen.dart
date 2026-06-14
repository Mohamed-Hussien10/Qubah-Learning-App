import 'package:flutter/material.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../../core/utils/error_utils.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/breadcrumb_nav.dart';
import '../../../../core/widgets/child_friendly_card.dart';
import '../manager/cubit/lesson_files_cubit.dart';
import '../manager/state/lesson_files_state.dart';
import '../../../../core/routing/app_router.dart';

class LessonFilesScreen extends StatefulWidget {
  final String parentId;
  final List<String> titlePath;
  const LessonFilesScreen({
    super.key,
    required this.parentId,
    this.titlePath = const [],
  });

  @override
  State<LessonFilesScreen> createState() => _LessonFilesScreenState();
}

class _LessonFilesScreenState extends State<LessonFilesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LessonFilesCubit>().loadLessonFiles(widget.parentId);
  }

  void _openFile(BuildContext context, dynamic file) {
    if (file.type == 'video' || file.type == 'mp4') {
      context.push(
        AppRoutes.videoPlayer,
        extra: {'videoUrl': file.filePath, 'title': file.name},
      );
    } else if (file.type == 'audio' || file.type == 'mp3') {
      context.push(
        AppRoutes.audioPlayer,
        extra: {
          'audioUrl': file.filePath,
          'title': file.name,
          'coverImageUrl': file.imageUrl,
        },
      );
    } else if (file.type == 'pdf') {
      context.push(
        AppRoutes.pdfViewer,
        extra: {'pdfUrl': file.filePath, 'title': file.name},
      );
    } else if (file.type == 'scorm' || file.type == 'interactive') {
      context.push(
        AppRoutes.interactiveViewer,
        extra: {'contentUrl': file.filePath, 'title': file.name},
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('نوع الملف غير مدعوم')));
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
          Expanded(
            child: BlocBuilder<LessonFilesCubit, LessonFilesState>(
              builder: (context, state) {
                if (state is LessonFilesLoading)
                  return const ShimmerGrid();
                if (state is LessonFilesError)
                  return ErrorDisplay(message: ErrorUtils.getFriendlyMessage(state.message));
                if (state is LessonFilesLoaded) {
                  if (state.lessonFiles.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_open_rounded,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد ملفات',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: state.lessonFiles.length,
                    itemBuilder: (context, index) {
                      final item = state.lessonFiles[index];
                      IconData icon;
                      Color color;
                      switch (item.type) {
                        case 'video':
                          icon = Icons.play_circle_fill_rounded;
                          color = Colors.red;
                          break;
                        case 'pdf':
                          icon = Icons.picture_as_pdf_rounded;
                          color = Colors.orange;
                          break;
                        case 'audio':
                          icon = Icons.audiotrack_rounded;
                          color = Colors.purple;
                          break;
                        default:
                          icon = Icons.insert_drive_file_rounded;
                          color = Colors.grey;
                      }
                      return ChildFriendlyCard(
                        title: item.name,
                        subtitle: item.type.toUpperCase(),
                        imageUrl: null,
                        color: color,
                        defaultIcon: icon,
                        onTap: () {
                          _openFile(context, item);
                        },
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      ),
    );
  }
}
