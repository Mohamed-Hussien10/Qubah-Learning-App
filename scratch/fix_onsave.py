import os
import re

dashboard_path = 'd:/Flutter/Qubah App/qubah_learning_app/web_dashboard/lib/features'
entities = [
    {'folder': 'grades', 'name': 'Grade', 'plural': 'grades'},
    {'folder': 'sections', 'name': 'Section', 'plural': 'sections'},
    {'folder': 'subjects', 'name': 'Subject', 'plural': 'subjects'},
    {'folder': 'units', 'name': 'Unit', 'plural': 'units'},
    {'folder': 'lessons', 'name': 'Lesson', 'plural': 'lessons'},
]

for entity in entities:
    screen_path = os.path.join(dashboard_path, entity['folder'], 'presentation', 'screens', f"{entity['plural']}_screen.dart")
    if os.path.exists(screen_path):
        with open(screen_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # 1. Fix the callback signature
        # Look for: final Future<void> Function(GradeModel) onSave;
        # Change to: final Future<void> Function(GradeModel, {List<int>? imageBytes, String? imageName}) onSave;
        
        sig_old = f"final Future<void> Function({entity['name']}Model) onSave;"
        sig_new = f"final Future<void> Function({entity['name']}Model, {{List<int>? imageBytes, String? imageName}}) onSave;"
        if sig_old in content:
            content = content.replace(sig_old, sig_new)
            
        # 2. Fix the mess I made with replace(')', ', imageBytes: ...)')
        # It looks like: await widget.onSave(grade, imageBytes: _selectedFileBytes, imageName: _selectedFileName).replace(')', ', imageBytes: _selectedFileBytes, imageName: _selectedFileName)');
        # Wait, the mess actually looks exactly like that.
        var_name = entity['name'].lower()
        
        # We can use regex to clean up any line containing widget.onSave that got messed up.
        # r"(await widget\.onSave\([a-zA-Z0-9_]+, imageBytes: _selectedFileBytes, imageName: _selectedFileName\))\.replace\([^)]+\);"
        # -> r"\1;"
        
        content = re.sub(r"(await widget\.onSave\([a-zA-Z0-9_]+, imageBytes: _selectedFileBytes, imageName: _selectedFileName\))\.replace\('[^']*',\s*'[^']*'\)", r"\1", content)
        
        # Also clean up any duplicate replacements or if the replace failed but something else messed up.
        # It's safest to just write a robust regex:
        # Match `await widget.onSave(X, ...).replace(...)`
        # Wait, just `.replace(')', ', imageBytes: _selectedFileBytes, imageName: _selectedFileName)')`
        content = content.replace(".replace(')', ', \nimageBytes: _selectedFileBytes, imageName: _selectedFileName)')", "")
        content = content.replace(".replace(')', ', imageBytes: _selectedFileBytes, imageName: _selectedFileName)')", "")
        
        with open(screen_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Fixed {screen_path}")
