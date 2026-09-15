import 'package:qubah_learning_app/core/widgets/hover_scale.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../../core/utils/error_utils.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/responsive_utils.dart';
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



  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: widget.backgroundImageUrl != null && widget.backgroundImageUrl!.isNotEmpty ? Colors.transparent : null,
          elevation: widget.backgroundImageUrl != null && widget.backgroundImageUrl!.isNotEmpty ? 0 : null,
          title: const Text('الدروس', style: TextStyle(fontWeight: FontWeight.bold)),
          leading: HoverScale(child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          )),
        ),
        body: Container(
          decoration: widget.backgroundImageUrl != null && widget.backgroundImageUrl!.isNotEmpty
              ? BoxDecoration(
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(AppHelpers.resolveMediaUrl(widget.backgroundImageUrl!)),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.white.withValues(alpha: 0.15), BlendMode.lighten),
                  ),
                )
              : null,
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
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
                  final childAspectRatio = context.responsiveValue(mobile: 0.85, tablet: 1.0, desktop: 1.2);

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 280,
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
      ),
    ),
  ),
),
);
  }
}




