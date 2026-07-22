import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../../core/utils/error_utils.dart';
import '../../../../core/utils/package_access_helper.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/services/dependency_injection.dart';
import '../../../../core/storage/secure_storage.dart' as import_secure_storage;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/breadcrumb_nav.dart';
import '../../../../core/widgets/child_friendly_card.dart';
import '../manager/cubit/sections_cubit.dart';
import '../manager/state/sections_state.dart';

class SectionsScreen extends StatefulWidget {
  final String parentId;
  final List<String> titlePath;
  final String? backgroundImageUrl;
  const SectionsScreen({
    super.key,
    required this.parentId,
    this.titlePath = const [],
    this.backgroundImageUrl,
  });

  @override
  State<SectionsScreen> createState() => _SectionsScreenState();
}

class _SectionsScreenState extends State<SectionsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SectionsCubit>().loadSections(widget.parentId);
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
                child: BlocBuilder<SectionsCubit, SectionsState>(
                  builder: (context, state) {
                    if (state is SectionsLoading) {
                      return const ShimmerGrid();
                    }
                    if (state is SectionsError) {
                      return ErrorDisplay(
                          message: ErrorUtils.getFriendlyMessage(state.message));
                    }
                    if (state is SectionsLoaded) {
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

                          final sections = state.sections.where((sec) {
                            return PackageAccessHelper.canAccessSection(
                              userData: userData,
                              sectionId: sec.id,
                            );
                          }).toList();

                          final displaySections =
                              sections.isNotEmpty ? sections : state.sections;

                          if (displaySections.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.meeting_room_rounded,
                                    size: 80,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'لا توجد أقسام متاحة',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final itemCount = displaySections.length;
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
                              final item = displaySections[index];
                              final bool isAccessible =
                                  PackageAccessHelper.canAccessSection(
                                userData: userData,
                                sectionId: item.id,
                              );

                              return ChildFriendlyCard(
                                title: item.name,
                                subtitle: isAccessible
                                    ? item.description
                                    : 'غير مشمول في الباقة الحالية',
                                imageUrl: item.imageUrl,
                                color: isAccessible ? Colors.green : Colors.grey,
                                defaultIcon: isAccessible
                                    ? Icons.category_rounded
                                    : Icons.lock_rounded,
                                onTap: () {
                                  if (!isAccessible) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'هذا الفصل/القسم غير مشمول في باقتك الحالية.'),
                                      ),
                                    );
                                    return;
                                  }

                                  context.push(
                                    '/subjects/${item.id}',
                                    extra: {
                                      'titlePath': [
                                        ...widget.titlePath,
                                        item.name
                                      ],
                                      'backgroundImageUrl':
                                          widget.backgroundImageUrl,
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
