import 'package:flutter/material.dart';
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
      appBar: AppBar(
        title: const Text(
          'المراحل الدراسية',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      backgroundColor: Colors.grey.shade50,
      body: BlocBuilder<StagesCubit, StagesState>(
        builder: (context, state) {
          if (state is StagesLoading)
            return const Center(child: CircularProgressIndicator());
          if (state is StagesError) return Center(child: Text(state.message));
          if (state is StagesLoaded) {
            if (state.stages.isEmpty) {
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
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: state.stages.length,
              itemBuilder: (context, index) {
                final item = state.stages[index];
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
    );
  }
}
