import os

dashboard_path = 'd:/Flutter/Qubah App/qubah_learning_app/web_dashboard/lib/features'
entities = [
    {'folder': 'grades', 'name': 'Grade', 'plural': 'grades'},
    {'folder': 'sections', 'name': 'Section', 'plural': 'sections'},
    {'folder': 'subjects', 'name': 'Subject', 'plural': 'subjects'},
    {'folder': 'units', 'name': 'Unit', 'plural': 'units'},
    {'folder': 'lessons', 'name': 'Lesson', 'plural': 'lessons'},
]

for entity in entities:
    repo_path = os.path.join(dashboard_path, entity['folder'], 'data', 'repositories', f"{entity['plural']}_repository.dart")
    if os.path.exists(repo_path):
        with open(repo_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        if 'api_endpoints.dart' not in content:
            content = content.replace("import 'package:web_dashboard/core/network/api_client.dart';", "import 'package:web_dashboard/core/network/api_client.dart';\nimport 'package:web_dashboard/core/constants/api_endpoints.dart';")
            
        with open(repo_path, 'w', encoding='utf-8') as f:
            f.write(content)
