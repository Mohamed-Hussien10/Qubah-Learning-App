import os
import re

dashboard_path = 'd:/Flutter/Qubah App/qubah_learning_app/web_dashboard/lib/features'
screens = [
    'educational_stages/presentation/screens/stages_screen.dart',
    'grades/presentation/screens/grades_screen.dart',
    'sections/presentation/screens/sections_screen.dart',
    'subjects/presentation/screens/subjects_screen.dart',
    'units/presentation/screens/units_screen.dart',
    'lessons/presentation/screens/lessons_screen.dart',
]

def map_entity_to_var(screen):
    if 'stages_screen' in screen: return 'stage', 'Icons.school'
    if 'grades_screen' in screen: return 'grade', 'Icons.class_rounded'
    if 'sections_screen' in screen: return 'section', 'Icons.category_rounded'
    if 'subjects_screen' in screen: return 'subject', 'Icons.menu_book_rounded'
    if 'units_screen' in screen: return 'unit', 'Icons.view_module_rounded'
    if 'lessons_screen' in screen: return 'lesson', 'Icons.play_lesson_rounded'
    return None, None

def replace_balanced(content, start_idx, replacement):
    open_count = 0
    end_idx = start_idx
    started = False
    for i in range(start_idx, len(content)):
        if content[i] == '(':
            open_count += 1
            started = True
        elif content[i] == ')':
            open_count -= 1
        
        if started and open_count == 0:
            end_idx = i + 1
            break
            
    return content[:start_idx] + replacement + content[end_idx:]

for screen in screens:
    file_path = os.path.join(dashboard_path, screen)
    if not os.path.exists(file_path):
        continue
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    item_var, icon = map_entity_to_var(screen)
    if not item_var: continue
    
    # Ensure import
    if "network_avatar.dart" not in content:
        content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:web_dashboard/core/widgets/network_avatar.dart';")

    while True:
        idx = content.find("CircleAvatar(")
        if idx == -1:
            break
        end_snippet = content[idx:idx+300]
        if "NetworkImage(resolveImageUrl" in end_snippet or "Icon(" in end_snippet and "AppColors.primary" in end_snippet:
            replacement = f"NetworkAvatar(imageUrl: {item_var}.thumbnailUrl, defaultIcon: {icon})"
            content = replace_balanced(content, idx, replacement)
        else:
            break

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

better_resolve = """  String resolveImageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    const domainUrl = 'https://qubahom.com';
    if (path.startsWith('/')) return '$domainUrl$path';
    if (path.startsWith('storage/')) return '$domainUrl/$path';
    return '$domainUrl/storage/$path';
  }"""

all_screens = screens + ['lesson_files/presentation/screens/lesson_files_screen.dart']
for screen in all_screens:
    file_path = os.path.join(dashboard_path, screen)
    if not os.path.exists(file_path):
        continue
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    regex3 = r'\s*String resolveImageUrl\(String path\) \{[\s\S]*?return path;\n\s*\}'
    content = re.sub(regex3, "\n" + better_resolve, content)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

print("Done")
