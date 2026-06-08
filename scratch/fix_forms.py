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
            
        # Add import file_picker.dart
        if 'file_picker.dart' not in content:
            content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:file_picker/file_picker.dart';")
            
        # 1. Add _selectedFileName, _selectedFileBytes, _thumbCtrl variables to the State
        var_regex = r"(bool _isSaving = false;\n)"
        if '_selectedFileName' not in content:
            content = re.sub(var_regex, r"\1  String? _selectedFileName;\n  List<int>? _selectedFileBytes;\n  late TextEditingController _thumbCtrl;\n", content)
            
        # 2. Add _thumbCtrl initialization and disposal
        init_regex = r"(super\.initState\(\);\n\s*_titleCtrl = TextEditingController.*?;\n\s*_descCtrl = TextEditingController.*?;\n)"
        if '_thumbCtrl = TextEditingController' not in content:
            content = re.sub(init_regex, r"\1    _thumbCtrl = TextEditingController(text: widget." + entity['name'].lower() + r"?.thumbnailUrl ?? '');\n", content)
            
        disp_regex = r"(_titleCtrl\.dispose\(\);\n\s*_descCtrl\.dispose\(\);\n)"
        if '_thumbCtrl.dispose()' not in content:
            content = re.sub(disp_regex, r"\1    _thumbCtrl.dispose();\n", content)
            
        # 3. Add _pickImage method
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
        if '_pickImage' not in content:
            content = re.sub(r"(void _handleSave\(\) \{)", pick_method + r"\n  \1", content)
            
        # 4. Modify onSave callback signature in widget definition
        #   final Future<void> Function(GradeModel) onSave; -> final Future<void> Function(GradeModel, {List<int>? imageBytes, String? imageName}) onSave;
        if '{List<int>? imageBytes, String? imageName}' not in content:
            content = content.replace(f"Function({entity['name']}Model {entity['name'].lower()}) onSave;", f"Function({entity['name']}Model {entity['name'].lower()}, {{List<int>? imageBytes, String? imageName}}) onSave;")
            content = content.replace(f"Function({entity['name']}Model {entity['name'].lower()}) onSave,", f"Function({entity['name']}Model {entity['name'].lower()}, {{List<int>? imageBytes, String? imageName}}) onSave,")
            
        # 5. Modify onSave call inside _handleSave
        if 'widget.onSave(' in content and 'imageBytes' not in content[content.find('widget.onSave'):]:
            content = re.sub(r"(widget\.onSave\([a-zA-Z_0-9]+\))", r"\1.replace(')', ', imageBytes: _selectedFileBytes, imageName: _selectedFileName)')", content) # wait regex replace is tricky
            # Just do simple string replace:
            content = content.replace(f"widget.onSave({entity['name'].lower()})", f"widget.onSave({entity['name'].lower()}, imageBytes: _selectedFileBytes, imageName: _selectedFileName)")
            
        # 6. Add thumbnail field to the UI
        field_ui = """const SizedBox(height: 16),
            const Text('صورة الغلاف (اختياري)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _thumbCtrl,
                    decoration: const InputDecoration(
                      hintText: 'لم يتم اختيار صورة',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('اختيار'),
                ),
              ],
            ),
            """
        if 'صورة الغلاف' not in content:
            # We find "الوصف (اختياري)" which is the description field, and insert our field BEFORE it.
            content = content.replace("const Text('الوصف (اختياري)'", field_ui + "const Text('الوصف (اختياري)'")
            
        # 7. Modify the model creation in _handleSave to include thumbnailUrl: _thumbCtrl.text
        # e.g. final grade = GradeModel(..., description: _descCtrl.text, ...);
        if 'thumbnailUrl: _thumbCtrl.text' not in content:
            content = content.replace("description: _descCtrl.text,", "description: _descCtrl.text,\n      thumbnailUrl: _thumbCtrl.text,")
            
        # 8. We also need to fix _showForm() to accept the imageBytes and pass it to the cubit!
        # Because we previously did NOT do this for the screens, only in my broken python script which was aimed at `_form_dialog.dart`!
        # Wait, the earlier python script DID try to replace `_showForm` call! Let's check if it did.
        # "onSave: (s, {imageBytes, imageName}) async {"
        if '(s, {imageBytes, imageName})' not in content and f"({entity['name'].lower()[0]}, {{imageBytes, imageName}})" not in content:
            # Re-run the _showForm replacement
            var = entity['name'].lower()[0] # 'g' for grade
            content = re.sub(f"onSave:\\s*\\({var}\\)\\s*async\\s*\\{{([\\s\\S]*?)\\}}", f"onSave: ({var}, {{imageBytes, imageName}}) async {{\\1}}", content)
            content = content.replace(f"update{entity['name']}({var})", f"update{entity['name']}({var}, imageBytes: imageBytes, imageName: imageName)")
            content = content.replace(f"create{entity['name']}({var})", f"create{entity['name']}({var}, imageBytes: imageBytes, imageName: imageName)")

        with open(screen_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {screen_path}")
