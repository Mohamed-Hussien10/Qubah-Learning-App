import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../../core/services/dependency_injection.dart';
import '../../../../core/storage/secure_storage.dart' as import_secure_storage;
import '../../../../core/widgets/error_display.dart';
import '../../../../core/utils/error_utils.dart';
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
            if (state is StagesLoading)
              return const ShimmerGrid();
            if (state is StagesError) return ErrorDisplay(message: ErrorUtils.getFriendlyMessage(state.message));
            if (state is StagesLoaded) {
              return FutureBuilder<String?>(
                future: sl<import_secure_storage.SecureStorage>().getUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const ShimmerGrid();
                  }
                  
                  String? userStageId;
                  if (snapshot.hasData && snapshot.data != null) {
                    try {
                      final data = jsonDecode(snapshot.data!);
                      userStageId = data['stage_id']?.toString();
                    } catch (_) {}
                  }

                  final stages = state.stages.where((s) => userStageId == null || s.id == userStageId).toList();

                if (stages.isEmpty) {
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
              final itemCount = stages.length;
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
                final item = stages[index];
                return ChildFriendlyCard(
                  title: item.name,
                  subtitle: item.description,
                  imageUrl: item.imageUrl,
                  color: Colors.purple,
                  defaultIcon: Icons.school_rounded,
                  onTap: () {
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
