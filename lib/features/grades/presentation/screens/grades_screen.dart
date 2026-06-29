import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../../core/services/dependency_injection.dart';
import '../../../../core/storage/secure_storage.dart' as import_secure_storage;
import '../../../../core/widgets/error_display.dart';
import '../../../../core/utils/error_utils.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/breadcrumb_nav.dart';
import '../../../../core/widgets/child_friendly_card.dart';
import '../manager/cubit/grades_cubit.dart';
import '../manager/state/grades_state.dart';

class GradesScreen extends StatefulWidget {
  final String parentId;
  final List<String> titlePath;
  final String? backgroundImageUrl;
  const GradesScreen({
    super.key,
    required this.parentId,
    this.titlePath = const [],
    this.backgroundImageUrl,
  });

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GradesCubit>().loadGrades(widget.parentId);
  }

  String _resolveImageUrl(String path) {
    if (path.startsWith('http')) {
      if (path.contains('localhost') || path.contains('127.0.0.1')) {
        return path.replaceAll(RegExp(r'http://(?:localhost|127\.0\.0\.1)(:\d+)?'), 'https://qubahom.com');
      }
      return path;
    }
    const baseUrl = 'https://qubahom.com'; 
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

      body: SafeArea(
        child: Container(
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
              child: BlocBuilder<GradesCubit, GradesState>(
                builder: (context, state) {
                  if (state is GradesLoading)
                    return const ShimmerGrid();
                  if (state is GradesError)
                    return ErrorDisplay(message: ErrorUtils.getFriendlyMessage(state.message));
                  if (state is GradesLoaded) {
                    return FutureBuilder<String?>(
                      future: sl<import_secure_storage.SecureStorage>().getUserData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const ShimmerGrid();
                        }

                        String? userGradeId;
                        if (snapshot.hasData && snapshot.data != null) {
                          try {
                            final data = jsonDecode(snapshot.data!);
                            userGradeId = data['grade_id']?.toString();
                          } catch (_) {}
                        }

                        final grades = state.grades.where((g) => userGradeId == null || g.id == userGradeId).toList();

                      if (grades.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.class_rounded,
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
                      final itemCount = grades.length;
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
                      final item = grades[index];
                      return ChildFriendlyCard(
                        title: item.name,
                        subtitle: item.description,
                        imageUrl: item.imageUrl,
                        color: Colors.blue,
                        defaultIcon: Icons.class_rounded,
                        onTap: () {
                          context.push(
                            '/sections/${item.id}',
                            extra: {
                              'titlePath': [...widget.titlePath, item.name],
                              'backgroundImageUrl': widget.backgroundImageUrl,
                            },
                          );
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
    );
  }
}




