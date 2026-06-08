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

pick_method = """
  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null) {
      setState(() {
        _selectedFileName = result.files.single.name;
        _selectedFileBytes = result.files.single.bytes;
        _thumbCtrl.text = _selectedFileName!;
      });
    }
  }
"""

for entity in entities:
    screen_path = os.path.join(dashboard_path, entity['folder'], 'presentation', 'screens', f"{entity['plural']}_screen.dart")
    if os.path.exists(screen_path):
        with open(screen_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        if '_pickImage' not in content:
            content = content.replace("Future<void> _handleSave() async {", pick_method + "\n  Future<void> _handleSave() async {")
            with open(screen_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Added _pickImage to {screen_path}")
