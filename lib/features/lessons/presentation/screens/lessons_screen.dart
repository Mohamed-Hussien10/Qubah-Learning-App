import 'package:flutter/material.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../../core/utils/error_utils.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/breadcrumb_nav.dart';
import '../../../../core/widgets/child_friendly_card.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/services/dependency_injection.dart';
import '../manager/cubit/lessons_cubit.dart';
import '../manager/state/lessons_state.dart';

class LessonsScreen extends StatefulWidget {
  final String parentId;
  final List<String> titlePath;
  final String? backgroundImageUrl;
  const LessonsScreen({
    super.key,
    required this.parentId,
    this.titlePath = const [],
    this.backgroundImageUrl,
  });

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  bool _isGuest = false;

  @override
  void initState() {
    super.initState();
    _checkGuestStatus();
    context.read<LessonsCubit>().loadLessons(widget.parentId);
  }

  Future<void> _checkGuestStatus() async {
    final isGuest = await sl<SecureStorage>().isGuest();
    if (mounted) {
      setState(() {
        _isGuest = isGuest;
      });
    }
  }

  String _resolveImageUrl(String path) {
    if (path.startsWith('http')) {
      if (path.contains('localhost') || path.contains('127.0.0.1')) {
        return path.replaceAll(RegExp(r'http://(?:localhost|127\.0\.0\.1)(:\d+)?'), 'http://192.168.1.17:8000');
      }
      return path;
    }
    const baseUrl = 'http://192.168.1.17:8000'; 
    if (path.startsWith('/')) {
      return '$baseUrl$path';
    } else if (path.startsWith('storage/')) {
      return '$baseUrl/$path';
    } else {
      return '$baseUrl/storage/$path';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الدروس',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Container(
        decoration: widget.backgroundImageUrl != null && widget.backgroundImageUrl!.isNotEmpty
            ? BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(_resolveImageUrl(widget.backgroundImageUrl!)),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.white.withValues(alpha: 0.15), BlendMode.lighten),
                ),
              )
            : null,
        child: Column(
          children: [
            if (widget.titlePath.isNotEmpty)
              BreadcrumbNav(pathNames: widget.titlePath),
            Expanded(
            child: BlocBuilder<LessonsCubit, LessonsState>(
              builder: (context, state) {
                if (state is LessonsLoading) {
                  return const ShimmerGrid();
                }
                if (state is LessonsError) {
                  return ErrorDisplay(message: ErrorUtils.getFriendlyMessage(state.message));
                }
                if (state is LessonsLoaded) {
                  if (state.lessons.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_lesson_rounded,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد بيانات',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  final itemCount = _isGuest && state.lessons.isNotEmpty ? 1 : state.lessons.length;
                  final crossAxisCount = itemCount == 1 ? 1 : 2;
                  final childAspectRatio = itemCount == 1 ? 1.5 : 0.85;

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: childAspectRatio,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      final item = state.lessons[index];
                      return ChildFriendlyCard(
                        title: item.name,
                        subtitle: item.description,
                        imageUrl: item.coverImageUrl,
                        color: Colors.blueGrey,
                        defaultIcon: Icons.play_lesson_rounded,
                        onTap: () {
                          context.push(
                            '/lesson-files/${item.id}',
                            extra: {
                              'titlePath': [...widget.titlePath, item.name],
                            },
                          );
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
