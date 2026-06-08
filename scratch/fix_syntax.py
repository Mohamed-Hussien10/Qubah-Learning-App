import os
import re

dashboard_path = 'd:/Flutter/Qubah App/qubah_learning_app/web_dashboard/lib/features'
entities = [
    {'folder': 'grades', 'name': 'Grade', 'plural': 'grades', 'icon': 'Icons.class_rounded'},
    {'folder': 'sections', 'name': 'Section', 'plural': 'sections', 'icon': 'Icons.category_rounded'},
    {'folder': 'subjects', 'name': 'Subject', 'plural': 'subjects', 'icon': 'Icons.menu_book_rounded'},
    {'folder': 'units', 'name': 'Unit', 'plural': 'units', 'icon': 'Icons.view_module_rounded'},
    {'folder': 'lessons', 'name': 'Lesson', 'plural': 'lessons', 'icon': 'Icons.play_lesson_rounded'},
]

for entity in entities:
    # Fix repository syntax error
    repo_path = os.path.join(dashboard_path, entity['folder'], 'data', 'repositories', f"{entity['plural']}_repository.dart")
    if os.path.exists(repo_path):
        with open(repo_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Fix }grade) async {
        content = re.sub(r"(\{\s*List<int>\?\s*imageBytes,\s*String\?\s*imageName\s*\})\s*[a-zA-Z]+\s*\)\s*async\s*\{", r"\1) async {", content)

        with open(repo_path, 'w', encoding='utf-8') as f:
            f.write(content)
            
    # Fix model if I messed up toJson comma
    model_path = os.path.join(dashboard_path, entity['folder'], 'data', 'models', f"{entity['name'].lower()}_model.dart")
    if os.path.exists(model_path):
        with open(model_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        content = content.replace('thumbnailUrl}', 'thumbnailUrl')
        
        with open(model_path, 'w', encoding='utf-8') as f:
            f.write(content)
