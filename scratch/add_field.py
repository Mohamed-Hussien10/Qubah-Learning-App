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

field_ui = """
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
                  const SizedBox(height: 16),
                  """

for entity in entities:
    screen_path = os.path.join(dashboard_path, entity['folder'], 'presentation', 'screens', f"{entity['plural']}_screen.dart")
    if os.path.exists(screen_path):
        with open(screen_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        if 'صورة الغلاف (اختياري)' not in content:
            # We match `TextFormField(\s*controller: _descCtrl,`
            content = re.sub(r"(TextFormField\(\s*controller:\s*_descCtrl,)", field_ui + r"\1", content)
            
            with open(screen_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Added field to {screen_path}")
