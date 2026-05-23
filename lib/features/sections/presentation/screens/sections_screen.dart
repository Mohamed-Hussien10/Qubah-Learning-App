import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/breadcrumb_nav.dart';
import '../../../../core/widgets/child_friendly_card.dart';
import '../manager/cubit/sections_cubit.dart';
import '../manager/state/sections_state.dart';

class SectionsScreen extends StatefulWidget {
  final String parentId;
  final List<String> titlePath;
  const SectionsScreen({
    super.key,
    required this.parentId,
    this.titlePath = const [],
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
      appBar: AppBar(
        title: const Text(
          'الفصول',
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
            child: BlocBuilder<SectionsCubit, SectionsState>(
              builder: (context, state) {
                if (state is SectionsLoading)
                  return const Center(child: CircularProgressIndicator());
                if (state is SectionsError)
                  return Center(child: Text(state.message));
                if (state is SectionsLoaded) {
                  if (state.sections.isEmpty) {
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
                    itemCount: state.sections.length,
                    itemBuilder: (context, index) {
                      final item = state.sections[index];
                      return ChildFriendlyCard(
                        title: item.name,
                        subtitle: item.description,
                        imageUrl: item.imageUrl,
                        color: Colors.green,
                        defaultIcon: Icons.category_rounded,
                        onTap: () {
                          context.push(
                            '/subjects/${item.id}',
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
