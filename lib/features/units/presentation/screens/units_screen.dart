import 'package:flutter/material.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../../core/utils/error_utils.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/breadcrumb_nav.dart';
import '../../../../core/widgets/child_friendly_card.dart';
import '../manager/cubit/units_cubit.dart';
import '../manager/state/units_state.dart';

class UnitsScreen extends StatefulWidget {
  final String parentId;
  final List<String> titlePath;
  const UnitsScreen({
    super.key,
    required this.parentId,
    this.titlePath = const [],
  });

  @override
  State<UnitsScreen> createState() => _UnitsScreenState();
}

class _UnitsScreenState extends State<UnitsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UnitsCubit>().loadUnits(widget.parentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الوحدات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Column(
        children: [
          if (widget.titlePath.isNotEmpty)
            BreadcrumbNav(pathNames: widget.titlePath),
          Expanded(
            child: BlocBuilder<UnitsCubit, UnitsState>(
              builder: (context, state) {
                if (state is UnitsLoading)
                  return const ShimmerGrid();
                if (state is UnitsError)
                  return ErrorDisplay(message: ErrorUtils.getFriendlyMessage(state.message));
                if (state is UnitsLoaded) {
                  if (state.units.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.view_module_rounded,
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
                    itemCount: state.units.length,
                    itemBuilder: (context, index) {
                      final item = state.units[index];
                      return ChildFriendlyCard(
                        title: item.name,
                        subtitle: item.description,
                        imageUrl: item.imageUrl,
                        color: Colors.teal,
                        defaultIcon: Icons.view_module_rounded,
                        onTap: () {
                          context.push(
                            '/lessons/${item.id}',
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
