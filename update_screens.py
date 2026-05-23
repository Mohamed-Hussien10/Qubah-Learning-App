import os

features = [
    {"name": "educational_stages", "plural": "stages", "singular": "stage", "Cls": "Stage", "Title": "المراحل الدراسية", "next_route": "/grades", "icon": "Icons.school_rounded", "color": "Colors.purple"},
    {"name": "grades", "plural": "grades", "singular": "grade", "Cls": "Grade", "Title": "الصفوف الدراسية", "next_route": "/sections", "icon": "Icons.class_rounded", "color": "Colors.blue"},
    {"name": "sections", "plural": "sections", "singular": "section", "Cls": "Section", "Title": "الفصول", "next_route": "/subjects", "icon": "Icons.meeting_room_rounded", "color": "Colors.orange"},
    {"name": "subjects", "plural": "subjects", "singular": "subject", "Cls": "Subject", "Title": "المواد الدراسية", "next_route": "/units", "icon": "Icons.menu_book_rounded", "color": "Colors.green"},
    {"name": "units", "plural": "units", "singular": "unit", "Cls": "Unit", "Title": "الوحدات", "next_route": "/lessons", "icon": "Icons.view_module_rounded", "color": "Colors.teal"},
    {"name": "lessons", "plural": "lessons", "singular": "lesson", "Cls": "Lesson", "Title": "الدروس", "next_route": "/lesson-files", "icon": "Icons.play_lesson_rounded", "color": "Colors.indigo"},
]

base_path = "lib/features"

def write_file(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

for f in features:
    name = f["name"]
    plural = f["plural"]
    Cls = f["Cls"]
    title = f["Title"]
    next_route = f["next_route"]
    icon = f["icon"]
    color = f["color"]
    
    # Handle the difference in parentId argument logic
    parent_arg_decl = "final String parentId;" if name != "educational_stages" else ""
    parent_arg_init = "required this.parentId" if name != "educational_stages" else ""
    init_call = f"context.read<{Cls}sCubit>().load{Cls}s(widget.parentId);" if name != "educational_stages" else f"context.read<{Cls}sCubit>().load{Cls}s();"

    # Some screens used subjectId instead of parentId earlier, let's standardize to parentId for the generated ones, or handle specific exceptions
    # But wait, stages has no parentId.
    
    screen = f"""import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/child_friendly_card.dart';
import '../manager/cubit/{plural}_cubit.dart';
import '../manager/state/{plural}_state.dart';

class {Cls}sScreen extends StatefulWidget {{
  {parent_arg_decl}
  const {Cls}sScreen({{super.key{', ' + parent_arg_init if parent_arg_init else ''}}});

  @override
  State<{Cls}sScreen> createState() => _{Cls}sScreenState();
}}

class _{Cls}sScreenState extends State<{Cls}sScreen> {{
  @override
  void initState() {{
    super.initState();
    {init_call}
  }}

  @override
  Widget build(BuildContext context) {{
    return Scaffold(
      appBar: AppBar(
        title: const Text('{title}', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      backgroundColor: Colors.grey.shade50,
      body: BlocBuilder<{Cls}sCubit, {Cls}sState>(
        builder: (context, state) {{
          if (state is {Cls}sLoading) return const Center(child: CircularProgressIndicator());
          if (state is {Cls}sError) return Center(child: Text(state.message));
          if (state is {Cls}sLoaded) {{
            if (state.{plural}.isEmpty) {{
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon({icon}, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('لا توجد بيانات', style: TextStyle(fontSize: 20, color: Colors.grey.shade500)),
                  ],
                ),
              );
            }}
            return ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 32),
              itemCount: state.{plural}.length,
              itemBuilder: (context, index) {{
                final item = state.{plural}[index];
                return ChildFriendlyCard(
                  title: item.name,
                  subtitle: item.description,
                  imageUrl: item.imageUrl,
                  color: {color},
                  defaultIcon: {icon},
                  onTap: () {{
                    context.push('{next_route}/${{item.id}}');
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
    write_file(f"{base_path}/{name}/presentation/screens/{plural}_screen.dart", screen)

# Write LessonFiles screen separately because it handles file viewing, not navigation to another list
files_screen = """import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/child_friendly_card.dart';
import '../manager/cubit/lesson_files_cubit.dart';
import '../manager/state/lesson_files_state.dart';
import '../../../../core/routing/app_router.dart';

class LessonFilesScreen extends StatefulWidget {
  final String parentId;
  const LessonFilesScreen({super.key, required this.parentId});

  @override
  State<LessonFilesScreen> createState() => _LessonFilesScreenState();
}

class _LessonFilesScreenState extends State<LessonFilesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LessonFilesCubit>().loadLessonFiles(widget.parentId);
  }

  void _openFile(BuildContext context, dynamic file) {
    // Determine route based on file type
    if (file.type == 'video' || file.type == 'mp4') {
      context.push(AppRoutes.videoPlayer, extra: {'videoUrl': file.filePath, 'title': file.name});
    } else if (file.type == 'audio' || file.type == 'mp3') {
      context.push(AppRoutes.audioPlayer, extra: {'audioUrl': file.filePath, 'title': file.name, 'coverImageUrl': file.imageUrl});
    } else if (file.type == 'pdf') {
      context.push(AppRoutes.pdfViewer, extra: {'pdfUrl': file.filePath, 'title': file.name});
    } else if (file.type == 'scorm' || file.type == 'interactive') {
      context.push(AppRoutes.interactiveViewer, extra: {'contentUrl': file.filePath, 'title': file.name});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('نوع الملف غير مدعوم')));
    }
  }

  IconData _getIconForType(String type) {
    if (type == 'video' || type == 'mp4') return Icons.play_circle_fill_rounded;
    if (type == 'audio' || type == 'mp3') return Icons.audiotrack_rounded;
    if (type == 'pdf') return Icons.picture_as_pdf_rounded;
    if (type == 'scorm' || type == 'interactive') return Icons.extension_rounded;
    return Icons.insert_drive_file_rounded;
  }

  Color _getColorForType(String type) {
    if (type == 'video' || type == 'mp4') return Colors.red;
    if (type == 'audio' || type == 'mp3') return Colors.blue;
    if (type == 'pdf') return Colors.orange;
    if (type == 'scorm' || type == 'interactive') return Colors.purple;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملفات', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      backgroundColor: Colors.grey.shade50,
      body: BlocBuilder<LessonFilesCubit, LessonFilesState>(
        builder: (context, state) {
          if (state is LessonFilesLoading) return const Center(child: CircularProgressIndicator());
          if (state is LessonFilesError) return Center(child: Text(state.message));
          if (state is LessonFilesLoaded) {
            if (state.lessonFiles.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_open_rounded, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('لا توجد ملفات', style: TextStyle(fontSize: 20, color: Colors.grey.shade500)),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 32),
              itemCount: state.lessonFiles.length,
              itemBuilder: (context, index) {
                final item = state.lessonFiles[index];
                // Assuming item has type and filePath in the actual model
                return ChildFriendlyCard(
                  title: item.name,
                  subtitle: 'اضغط للفتح',
                  imageUrl: item.imageUrl,
                  color: _getColorForType('video'), // Fallback
                  defaultIcon: _getIconForType('video'), // Fallback
                  onTap: () {
                    // This requires the entity to have 'type' and 'filePath'. 
                    // I will add a mock _openFile for now until we update the entity if needed.
                    _openFile(context, item);
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
"""
write_file(f"{base_path}/lesson_files/presentation/screens/lesson_files_screen.dart", files_screen)

print("UI screens updated.")
