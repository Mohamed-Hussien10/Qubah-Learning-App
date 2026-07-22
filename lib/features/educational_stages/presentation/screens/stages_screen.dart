import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../../core/services/dependency_injection.dart';
import '../../../../core/storage/secure_storage.dart' as import_secure_storage;
import '../../../../core/widgets/error_display.dart';
import '../../../../core/utils/error_utils.dart';
import '../../../../core/utils/package_access_helper.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/child_friendly_card.dart';
import '../manager/cubit/stages_cubit.dart';
import '../manager/state/stages_state.dart';

class StagesScreen extends StatefulWidget {
  const StagesScreen({super.key});

  @override
  State<StagesScreen> createState() => _StagesScreenState();
}

class _StagesScreenState extends State<StagesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StagesCubit>().loadStages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<StagesCubit, StagesState>(
          builder: (context, state) {
            if (state is StagesLoading) {
              return const ShimmerGrid();
            }
            if (state is StagesError) {
              return ErrorDisplay(
                  message: ErrorUtils.getFriendlyMessage(state.message));
            }
            if (state is StagesLoaded) {
              return FutureBuilder<String?>(
                future:
                    sl<import_secure_storage.SecureStorage>().getUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const ShimmerGrid();
                  }

                  Map<String, dynamic>? userData;
                  if (snapshot.hasData && snapshot.data != null) {
                    try {
                      userData = jsonDecode(snapshot.data!);
                    } catch (_) {}
                  }

                  final stages = state.stages.where((s) {
                    return PackageAccessHelper.canAccessStage(
                      userData: userData,
                      stageId: s.id,
                    );
                  }).toList();

                  // Fallback: if filter results in zero stages, show all available stages
                  final displayStages =
                      stages.isNotEmpty ? stages : state.stages;

                  if (displayStages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school_rounded,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد مراحل تعليمية متاحة',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final itemCount = displayStages.length;
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
                      final item = displayStages[index];
                      final bool isAccessible = PackageAccessHelper.canAccessStage(
                        userData: userData,
                        stageId: item.id,
                      );

                      return ChildFriendlyCard(
                        title: item.name,
                        subtitle: isAccessible
                            ? item.description
                            : 'غير مشمول في الباقة الحالية',
                        imageUrl: item.imageUrl,
                        color: isAccessible ? Colors.purple : Colors.grey,
                        defaultIcon: isAccessible
                            ? Icons.school_rounded
                            : Icons.lock_rounded,
                        onTap: () {
                          if (!isAccessible) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'هذه المرحلة غير مشمولة في باقتك الحالية.'),
                              ),
                            );
                            return;
                          }
                          context.push(
                            '/grades/${item.id}',
                            extra: {
                              'titlePath': [item.name],
                              'backgroundImageUrl': item.backgroundImageUrl,
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
    );
  }
}
