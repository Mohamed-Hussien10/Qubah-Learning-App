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
  final String? backgroundImageUrl;
  const UnitsScreen({
    super.key,
    required this.parentId,
    this.titlePath = const [],
    this.backgroundImageUrl,
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

  String _resolveImageUrl(String path) {
    if (path.startsWith('http')) {
      if (path.contains('localhost') || path.contains('127.0.0.1')) {
        return path.replaceAll(RegExp(r'http://(?:localhost|127\.0\.0\.1)(:\d+)?'), 'http://192.168.1.8:8000');
      }
      return path;
    }
    const baseUrl = 'http://192.168.1.8:8000'; 
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
                  final itemCount = state.units.length;
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
                              'backgroundImageUrl': widget.backgroundImageUrl,
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
