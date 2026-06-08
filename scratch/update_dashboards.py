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
    # 1. Update Model
    model_path = os.path.join(dashboard_path, entity['folder'], 'data', 'models', f"{entity['name'].lower()}_model.dart")
    if os.path.exists(model_path):
        with open(model_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Add thumbnailUrl if not exists
        if 'final String? thumbnailUrl;' not in content:
            content = re.sub(r'(class\s+[A-Za-z]+Model\s+extends\s+BaseEntity\s*\{(?:\s*final\s+[^\n]+;\n)+)', r'\1  final String? thumbnailUrl;\n', content)
            
            # Add to constructor
            content = re.sub(r'(super\.description,\n)', r'\1    this.thumbnailUrl,\n', content)
            
            # Add to props
            content = re.sub(r'(\[.*?)(thumbnailUrl,)?(\s*\];)', r'\1, thumbnailUrl\3', content)
            content = content.replace('[,', '[') # fix possible typo
            
            # Add to copyWith
            content = re.sub(r'(String\?\s+description,\n)', r'\1    String? thumbnailUrl,\n', content)
            content = re.sub(r'(description:\s*description\s*\?\?\s*this\.description,\n)', r'\1      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,\n', content)

        # Update toJson and fromJson
        # if fromJson doesn't have thumbnail_url, add it
        if "thumbnailUrl: json['thumbnail_url']," not in content:
            content = re.sub(r"(description:\s*json\['description'\],\n)", r"\1      thumbnailUrl: json['thumbnail_url'],\n", content)
            
        # if toJson doesn't have thumbnail_path, add it (or replace thumbnail_url)
        if "thumbnail_path" not in content:
            if "'thumbnail_url': thumbnailUrl," in content:
                content = content.replace("'thumbnail_url': thumbnailUrl,", "'thumbnail_path': thumbnailUrl,")
            else:
                content = re.sub(r"('description':\s*description,\n)", r"\1      'thumbnail_path': thumbnailUrl,\n", content)
                
        # Fix is_active integer sending
        content = re.sub(r"'is_active':\s*isActive(?! \? 1 : 0),", r"'is_active': isActive ? 1 : 0,", content)
        
        # Fix order integer parsing
        content = re.sub(r"order:\s*json\['order'\]\s*\?\?\s*0,", r"order: json['order'] != null ? int.tryParse(json['order'].toString()) ?? 0 : 0,", content)
        
        # Fix Count integer parsing
        content = re.sub(r"([a-zA-Z0-9_]+Count):\s*json\['([a-zA-Z0-9_]+)'\]\s*\?\?\s*0,", r"\1: json['\2'] != null ? int.tryParse(json['\2'].toString()) ?? 0 : 0,", content)
        
        with open(model_path, 'w', encoding='utf-8') as f:
            f.write(content)

    # 2. Update Repository
    repo_path = os.path.join(dashboard_path, entity['folder'], 'data', 'repositories', f"{entity['plural']}_repository.dart")
    if os.path.exists(repo_path):
        with open(repo_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Replace create method signature and body
        if 'imageBytes' not in content:
            create_regex = r"(Future<" + entity['name'] + r"Model>\s+create\(" + entity['name'] + r"Model\s+[a-zA-Z]+\)\s+async\s+\{\n\s*final\s+payload\s*=\s*[a-zA-Z]+\.toJson\(\)\.\.remove\('id'\)\.\.remove\('created_at'\);\n)(.*?)(^\s*\})"
            new_create = r"""\1    
    if (imageBytes != null && imageBytes.isNotEmpty && imageName != null) {
      final uploadRes = await _apiClient.uploadFileBytes(
        '/thumbnails/upload',
        fileBytes: imageBytes,
        fileName: imageName,
        fileFieldName: 'thumbnail',
        additionalFields: {'folder': '""" + entity['plural'] + r"""'},
      );
      payload['thumbnail_path'] = uploadRes.data['data']['path'];
    }

    final response = await _apiClient.post(ApiEndpoints.""" + entity['plural'] + r""", data: payload);
    final data = response.data['data'] ?? response.data;
    return """ + entity['name'] + r"""Model.fromJson(data as Map<String, dynamic>);
  }"""
            content = re.sub(create_regex, new_create, content, flags=re.DOTALL | re.MULTILINE)
            content = content.replace(f"create({entity['name']}Model ", f"create({entity['name']}Model {entity['name'].lower()}, {{List<int>? imageBytes, String? imageName}}")

            # Update update method
            update_regex = r"(Future<" + entity['name'] + r"Model>\s+update\(" + entity['name'] + r"Model\s+[a-zA-Z]+\)\s+async\s+\{\n\s*final\s+payload\s*=\s*[a-zA-Z]+\.toJson\(\)\.\.remove\('created_at'\);\n)(.*?)(^\s*\})"
            new_update = r"""\1
    if (imageBytes != null && imageBytes.isNotEmpty && imageName != null) {
      final uploadRes = await _apiClient.uploadFileBytes(
        '/thumbnails/upload',
        fileBytes: imageBytes,
        fileName: imageName,
        fileFieldName: 'thumbnail',
        additionalFields: {'folder': '""" + entity['plural'] + r"""'},
      );
      payload['thumbnail_path'] = uploadRes.data['data']['path'];
    }

    final response = await _apiClient.put(ApiEndpoints.""" + entity['name'].lower() + r"""(int.parse(""" + entity['name'].lower() + r""".id)), data: payload);
    final data = response.data['data'] ?? response.data;
    return """ + entity['name'] + r"""Model.fromJson(data as Map<String, dynamic>);
  }"""
            content = re.sub(update_regex, new_update, content, flags=re.DOTALL | re.MULTILINE)
            content = content.replace(f"update({entity['name']}Model ", f"update({entity['name']}Model {entity['name'].lower()}, {{List<int>? imageBytes, String? imageName}}")

        with open(repo_path, 'w', encoding='utf-8') as f:
            f.write(content)

    # 3. Update Cubit
    cubit_path = os.path.join(dashboard_path, entity['folder'], 'presentation', 'manager', f"{entity['plural']}_cubit.dart")
    if os.path.exists(cubit_path):
        with open(cubit_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        if '{List<int>? imageBytes, String? imageName}' not in content:
            content = content.replace(f"create{entity['name']}({entity['name']}Model {entity['name'].lower()})", f"create{entity['name']}({entity['name']}Model {entity['name'].lower()}, {{List<int>? imageBytes, String? imageName}})")
            content = content.replace(f".create({entity['name'].lower()})", f".create({entity['name'].lower()}, imageBytes: imageBytes, imageName: imageName)")
            
            content = content.replace(f"update{entity['name']}({entity['name']}Model {entity['name'].lower()})", f"update{entity['name']}({entity['name']}Model {entity['name'].lower()}, {{List<int>? imageBytes, String? imageName}})")
            content = content.replace(f".update({entity['name'].lower()})", f".update({entity['name'].lower()}, imageBytes: imageBytes, imageName: imageName)")

        with open(cubit_path, 'w', encoding='utf-8') as f:
            f.write(content)

    # 4. Update Screen Avatar
    screen_path = os.path.join(dashboard_path, entity['folder'], 'presentation', 'screens', f"{entity['plural']}_screen.dart")
    if os.path.exists(screen_path):
        with open(screen_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        if 'NetworkImage' not in content:
            item_var = entity['name'].lower()
            old_avatar = f"""CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                        child: const Icon({entity['icon']},
                            size: 18, color: AppColors.primary),
                      )"""
            new_avatar = f"""CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                        backgroundImage: ({item_var}.thumbnailUrl != null && {item_var}.thumbnailUrl!.isNotEmpty)
                            ? NetworkImage(_resolveImageUrl({item_var}.thumbnailUrl!))
                            : null,
                        onBackgroundImageError: ({item_var}.thumbnailUrl != null && {item_var}.thumbnailUrl!.isNotEmpty) 
                            ? (_, __) {{}} 
                            : null,
                        child: ({item_var}.thumbnailUrl == null || {item_var}.thumbnailUrl!.isEmpty)
                            ? const Icon({entity['icon']}, size: 18, color: AppColors.primary)
                            : null,
                      )"""
            content = content.replace(old_avatar, new_avatar)
            
            # Also fix _showForm call
            content = re.sub(f"onSave:\\s*\\(s\\)\\s*async\\s*\\{{([\\s\\S]*?)\\}}", f"onSave: (s, {{imageBytes, imageName}}) async {{\\1}}", content)
            content = content.replace(f"update{entity['name']}(s)", f"update{entity['name']}(s, imageBytes: imageBytes, imageName: imageName)")
            content = content.replace(f"create{entity['name']}(s)", f"create{entity['name']}(s, imageBytes: imageBytes, imageName: imageName)")

            if '_resolveImageUrl' not in content:
                resolve_func = """
  String _resolveImageUrl(String path) {
    if (path.startsWith('http')) return path;
    const baseUrl = 'http://localhost:8000'; 
    if (path.startsWith('/')) {
      return '$baseUrl$path';
    } else if (path.startsWith('storage/')) {
      return '$baseUrl/$path';
    } else {
      return '$baseUrl/storage/$path';
    }
  }
}"""
                content = re.sub(r'\}\s*$', resolve_func, content)
                
        with open(screen_path, 'w', encoding='utf-8') as f:
            f.write(content)

    # 5. Update Form Dialog
    dialog_path = os.path.join(dashboard_path, entity['folder'], 'presentation', 'widgets', f"{entity['name'].lower()}_form_dialog.dart")
    if os.path.exists(dialog_path):
        with open(dialog_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        if 'imageBytes' not in content:
            # Update onSave signature
            content = content.replace(f"Future<void> Function({entity['name']}Model {entity['name'].lower()}) onSave;", f"Future<void> Function({entity['name']}Model {entity['name'].lower()}, {{List<int>? imageBytes, String? imageName}}) onSave;")
            content = content.replace(f"Future<void> Function({entity['name']}Model {entity['name'].lower()}) onSave,", f"Future<void> Function({entity['name']}Model {entity['name'].lower()}, {{List<int>? imageBytes, String? imageName}}) onSave,")
            
            # Add variables
            content = re.sub(r'(bool _isSaving = false;\n)', r'\1  String? _selectedFileName;\n  List<int>? _selectedFileBytes;\n', content)
            
            # Add _pickImage logic if it exists but doesn't have bytes, or add it from scratch if it doesn't exist
            if 'Future<void> _pickImage()' in content:
                content = content.replace("withData: true,", "") # clean if half implemented
                content = content.replace("type: FileType.image,", "type: FileType.image,\n      withData: true,")
                content = re.sub(r"setState\(\(\) \{\n\s*_selectedFileName = result.files.single.name;\n\s*_thumbCtrl.text = _selectedFileName!;\n\s*\}\);", r"setState(() {\n        _selectedFileName = result.files.single.name;\n        _selectedFileBytes = result.files.single.bytes;\n        _thumbCtrl.text = _selectedFileName!;\n      });", content)
            else:
                # Need to inject thumbnail field.
                if 'file_picker.dart' not in content:
                    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:file_picker/file_picker.dart';")
                    
                # First add controller
                content = re.sub(r'(late TextEditingController _titleCtrl;\n)', r'\1  late TextEditingController _thumbCtrl;\n', content)
                content = re.sub(r'(_titleCtrl = TextEditingController.*?\n)', r'\1    _thumbCtrl = TextEditingController(text: widget.' + entity['name'].lower() + r'?.thumbnailUrl ?? \'\');\n', content)
                content = re.sub(r'(_titleCtrl\.dispose\(\);\n)', r'\1    _thumbCtrl.dispose();\n', content)
                
                # Add picker method
                picker = """  Future<void> _pickImage() async {
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
                content = re.sub(r'(  void _handleSave\(\) \{\n)', picker + r'\n\1', content)
                
                # Add UI field
                field = """            const SizedBox(height: 16),
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
                content = re.sub(r'(            const SizedBox\(height: 16\),\n\s*const Text\(\'الوصف \(اختياري\)\')', field + r'\1', content)
                
                # Update creation object. Wait, copyWith vs constructor. I'll just use constructor.
                # Let's replace the constructor usage in `_handleSave`
                
            # Update onSave call
            content = content.replace(f"widget.onSave({entity['name'].lower()})", f"widget.onSave({entity['name'].lower()}, imageBytes: _selectedFileBytes, imageName: _selectedFileName)")
            
            # Since some models don't have thumbnail injected yet, the `_handleSave` creates the model.
            # E.g. final grade = GradeModel(..., thumbnailUrl: _thumbCtrl.text)
            content = re.sub(r'(description: _descCtrl\.text,\n)', r'\1      thumbnailUrl: _thumbCtrl.text,\n', content)
            
        with open(dialog_path, 'w', encoding='utf-8') as f:
            f.write(content)
