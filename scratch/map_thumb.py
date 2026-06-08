import os
import re

dashboard_path = 'd:/Flutter/Qubah App/qubah_learning_app/web_dashboard/lib/features'
entities = [
    {'folder': 'grades', 'plural': 'grades'},
    {'folder': 'sections', 'plural': 'sections'},
    {'folder': 'subjects', 'plural': 'subjects'},
    {'folder': 'units', 'plural': 'units'},
    {'folder': 'lessons', 'plural': 'lessons'},
]

for entity in entities:
    screen_path = os.path.join(dashboard_path, entity['folder'], 'presentation', 'screens', f"{entity['plural']}_screen.dart")
    if os.path.exists(screen_path):
        with open(screen_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        if 'thumbnailUrl: _thumbCtrl.text' not in content:
            content = content.replace("isActive: _isActive,", "isActive: _isActive,\n      thumbnailUrl: _thumbCtrl.text,")
            with open(screen_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Added thumbnailUrl to {screen_path}")
