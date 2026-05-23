import os

features = [
    {"name": "grades", "singular": "grade", "SingularClass": "Grade", "ParentClass": "Stage"},
    {"name": "sections", "singular": "section", "SingularClass": "Section", "ParentClass": "Grade"},
    {"name": "units", "singular": "unit", "SingularClass": "Unit", "ParentClass": "Subject"},
    {"name": "lesson_files", "singular": "lesson_file", "SingularClass": "LessonFile", "ParentClass": "Lesson"}
]

base_path = "lib/features"

def write_file(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

for f in features:
    name = f["name"]
    sing = f["singular"]
    Cls = f["SingularClass"]
    PCls = f["ParentClass"]
    
    # 1. Entity
    ent = f"""class {Cls}Entity {{
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int order;
  final int childCount;

  const {Cls}Entity({{
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.order,
    this.childCount = 0,
  }});
}}
"""
    write_file(f"{base_path}/{name}/domain/entities/{sing}_entity.dart", ent)

    # 2. Model
    mod = f"""import '../../domain/entities/{sing}_entity.dart';

class {Cls}Model {{
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int order;
  final int childCount;

  const {Cls}Model({{
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.order,
    this.childCount = 0,
  }});

  factory {Cls}Model.fromJson(Map<String, dynamic> json) => {Cls}Model(
    id: json['id'].toString(),
    name: json['title'] ?? '',
    description: json['description'] as String?,
    imageUrl: json['thumbnail_url'] as String?,
    order: json['order'] as int? ?? 0,
    childCount: 0,
  );

  {Cls}Entity toEntity() => {Cls}Entity(
    id: id,
    name: name,
    description: description,
    imageUrl: imageUrl,
    order: order,
    childCount: childCount,
  );
}}
"""
    write_file(f"{base_path}/{name}/data/models/{sing}_model.dart", mod)

    # 3. Repository Interface
    repo_int = f"""import '../entities/{sing}_entity.dart';

abstract class {Cls}sRepository {{
  Future<List<{Cls}Entity>> get{Cls}s(String parentId);
}}
"""
    write_file(f"{base_path}/{name}/domain/repositories/{name}_repository.dart", repo_int)

    # 4. UseCase
    uc = f"""import '../../../../core/utils/usecase.dart';
import '../entities/{sing}_entity.dart';
import '../repositories/{name}_repository.dart';

class Get{Cls}sUseCase implements UseCase<List<{Cls}Entity>, String> {{
  final {Cls}sRepository repository;

  Get{Cls}sUseCase(this.repository);

  @override
  Future<List<{Cls}Entity>> call(String params) {{
    return repository.get{Cls}s(params);
  }}
}}
"""
    write_file(f"{base_path}/{name}/domain/usecases/get_{name}_usecase.dart", uc)

    # 5. Api Service
    api = f"""import 'package:dio/dio.dart';
import '../models/{sing}_model.dart';

class {Cls}sApiService {{
  final Dio dio;

  {Cls}sApiService(this.dio);

  Future<List<{Cls}Model>> get{Cls}s(String parentId) async {{
    // Adjust URL according to parent relationship
    final response = await dio.get('/{name}/$parentId');
    return (response.data['data'] as List)
        .map((e) => {Cls}Model.fromJson(e))
        .toList();
  }}
}}
"""
    write_file(f"{base_path}/{name}/data/data_sources/{name}_api_service.dart", api)

    # 6. Repository Impl
    repo_impl = f"""import '../../domain/entities/{sing}_entity.dart';
import '../../domain/repositories/{name}_repository.dart';
import '../data_sources/{name}_api_service.dart';

class {Cls}sRepositoryImpl implements {Cls}sRepository {{
  final {Cls}sApiService apiService;

  {Cls}sRepositoryImpl(this.apiService);

  @override
  Future<List<{Cls}Entity>> get{Cls}s(String parentId) async {{
    final models = await apiService.get{Cls}s(parentId);
    return models.map((e) => e.toEntity()).toList();
  }}
}}
"""
    write_file(f"{base_path}/{name}/data/repositories/{name}_repository_impl.dart", repo_impl)

    # 7. State
    state = f"""import '../../../domain/entities/{sing}_entity.dart';

abstract class {Cls}sState {{}}

class {Cls}sInitial extends {Cls}sState {{}}

class {Cls}sLoading extends {Cls}sState {{}}

class {Cls}sLoaded extends {Cls}sState {{
  final List<{Cls}Entity> {name};
  {Cls}sLoaded(this.{name});
}}

class {Cls}sError extends {Cls}sState {{
  final String message;
  {Cls}sError(this.message);
}}
"""
    write_file(f"{base_path}/{name}/presentation/manager/state/{name}_state.dart", state)

    # 8. Cubit
    cubit = f"""import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_{name}_usecase.dart';
import '../state/{name}_state.dart';

class {Cls}sCubit extends Cubit<{Cls}sState> {{
  final Get{Cls}sUseCase _get{Cls}sUseCase;

  {Cls}sCubit({{required Get{Cls}sUseCase get{Cls}sUseCase}})
      : _get{Cls}sUseCase = get{Cls}sUseCase, super({Cls}sInitial());

  Future<void> load{Cls}s(String parentId) async {{
    emit({Cls}sLoading());
    try {{
      final data = await _get{Cls}sUseCase(parentId);
      emit({Cls}sLoaded(data));
    }} catch (e) {{
      emit({Cls}sError(e.toString()));
    }}
  }}
}}
"""
    write_file(f"{base_path}/{name}/presentation/manager/cubit/{name}_cubit.dart", cubit)

    # 9. Screen
    screen = f"""import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../manager/cubit/{name}_cubit.dart';
import '../manager/state/{name}_state.dart';

class {Cls}sScreen extends StatefulWidget {{
  final String parentId;
  const {Cls}sScreen({{Key? key, required this.parentId}}) : super(key: key);

  @override
  State<{Cls}sScreen> createState() => _{Cls}sScreenState();
}}

class _{Cls}sScreenState extends State<{Cls}sScreen> {{
  @override
  void initState() {{
    super.initState();
    context.read<{Cls}sCubit>().load{Cls}s(widget.parentId);
  }}

  @override
  Widget build(BuildContext context) {{
    return Scaffold(
      appBar: AppBar(title: const Text('{Cls}s')),
      body: BlocBuilder<{Cls}sCubit, {Cls}sState>(
        builder: (context, state) {{
          if (state is {Cls}sLoading) return const Center(child: CircularProgressIndicator());
          if (state is {Cls}sError) return Center(child: Text(state.message));
          if (state is {Cls}sLoaded) {{
            return ListView.builder(
              itemCount: state.{name}.length,
              itemBuilder: (context, index) {{
                final item = state.{name}[index];
                return ListTile(
                  title: Text(item.name),
                  onTap: () {{
                    // Next routing
                  }},
                );
              }},
            );
          }}
          return const SizedBox.shrink();
        }},
      ),
    );
  }}
}}
"""
    write_file(f"{base_path}/{name}/presentation/screens/{name}_screen.dart", screen)

print("Scaffolded new Flutter features.")
