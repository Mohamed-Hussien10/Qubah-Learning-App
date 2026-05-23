import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/breadcrumb_nav.dart';
import '../../../../core/widgets/child_friendly_card.dart';
import '../manager/cubit/subjects_cubit.dart';
import '../manager/state/subjects_state.dart';

class SubjectsScreen extends StatefulWidget {
  final String parentId;
  final List<String> titlePath;
  const SubjectsScreen({
    super.key,
    required this.parentId,
    this.titlePath = const [],
  });

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SubjectsCubit>().loadSubjects(widget.parentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'المواد الدراسية',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          if (widget.titlePath.isNotEmpty)
            BreadcrumbNav(pathNames: widget.titlePath),
          Expanded(
            child: BlocBuilder<SubjectsCubit, SubjectsState>(
              builder: (context, state) {
                if (state is SubjectsLoading)
                  return const Center(child: CircularProgressIndicator());
                if (state is SubjectsError)
                  return Center(child: Text(state.message));
                if (state is SubjectsLoaded) {
                  if (state.subjects.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.menu_book_rounded,
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: state.subjects.length,
                    itemBuilder: (context, index) {
                      final item = state.subjects[index];
                      return ChildFriendlyCard(
                        title: item.name,
                        subtitle: item.description,
                        imageUrl: item.imageUrl,
                        color: Colors.green,
                        defaultIcon: Icons.menu_book_rounded,
                        onTap: () {
                          context.push(
                            '/units/${item.id}',
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
    );
  }
}
