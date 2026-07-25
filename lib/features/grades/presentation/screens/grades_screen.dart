import 'package:flutter/material.dart';
import '../../../../core/utils/helpers.dart';
import 'dart:convert';
import '../../../../core/services/dependency_injection.dart';
import '../../../../core/storage/secure_storage.dart' as import_secure_storage;
import '../../../../core/widgets/error_display.dart';
import '../../../../core/utils/error_utils.dart';
import '../../../../core/utils/package_access_helper.dart';
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
                        AppHelpers.resolveMediaUrl(widget.backgroundImageUrl!)),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                        Colors.white.withValues(alpha: 0.15),
                        BlendMode.lighten),
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
                    if (state is GradesLoading) {
                      return const ShimmerGrid();
                    }
                    if (state is GradesError) {
                      return ErrorDisplay(
                          message: ErrorUtils.getFriendlyMessage(state.message));
                    }
                    if (state is GradesLoaded) {
                      return FutureBuilder<String?>(
                        future: sl<import_secure_storage.SecureStorage>()
                            .getUserData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const ShimmerGrid();
                          }

                          Map<String, dynamic>? userData;
                          if (snapshot.hasData && snapshot.data != null) {
                            try {
                              userData = jsonDecode(snapshot.data!);
                            } catch (_) {}
                          }

                          final displayGrades = state.grades.where((g) {
                            return PackageAccessHelper.canAccessGrade(
                              userData: userData,
                              stageId: widget.parentId,
                              gradeId: g.id,
                            );
                          }).toList();

                          if (displayGrades.isEmpty) {
                            final bool isSubActive =
                                PackageAccessHelper.isSubscriptionActiveFromJson(userData);
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isSubActive
                                          ? Icons.class_rounded
                                          : Icons.lock_outline_rounded,
                                      size: 80,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      isSubActive
                                          ? 'لا توجد صفوف مشمولة في باقتك لهذه المرحلة'
                                          : 'اشتراكك غير فعال أو انتهت صلاحيته',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    if (!isSubActive) ...[
                                      const SizedBox(height: 16),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          context.push('/subscription-expired');
                                        },
                                        icon: const Icon(Icons.refresh_rounded),
                                        label: const Text('تجديد الاشتراك'),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }

                          final itemCount = displayGrades.length;
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
                              final item = displayGrades[index];
                              final bool isAccessible =
                                  PackageAccessHelper.canAccessGrade(
                                userData: userData,
                                stageId: widget.parentId,
                                gradeId: item.id,
                              );

                              return ChildFriendlyCard(
                                title: item.name,
                                subtitle: isAccessible
                                    ? item.description
                                    : 'غير مشمول في الباقة الحالية',
                                imageUrl: item.imageUrl,
                                color: isAccessible ? Colors.blue : Colors.grey,
                                defaultIcon: isAccessible
                                    ? Icons.class_rounded
                                    : Icons.lock_rounded,
                                onTap: () async {
                                  if (!isAccessible) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'هذا الصف غير مشمول في باقتك الحالية.'),
                                      ),
                                    );
                                    return;
                                  }

                                  final isGuest =
                                      await sl<import_secure_storage.SecureStorage>()
                                          .isGuest();
                                  if (context.mounted) {
                                    if (isGuest) {
                                      context.push(
                                        '/free-trial-subjects/${item.id}',
                                        extra: {
                                          'titlePath': [
                                            ...widget.titlePath,
                                            item.name
                                          ],
                                          'backgroundImageUrl':
                                              widget.backgroundImageUrl,
                                        },
                                      );
                                    } else {
                                      context.push(
                                        '/sections/${item.id}',
                                        extra: {
                                          'titlePath': [
                                            ...widget.titlePath,
                                            item.name
                                          ],
                                          'backgroundImageUrl':
                                              widget.backgroundImageUrl,
                                        },
                                      );
                                    }
                                  }
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
