import os
import re

dashboard_path = 'd:/Flutter/Qubah App/qubah_learning_app/web_dashboard/lib/features'
entities = [
    {'folder': 'educational_stages', 'plural': 'stages'},
    {'folder': 'grades', 'plural': 'grades'},
    {'folder': 'sections', 'plural': 'sections'},
    {'folder': 'subjects', 'plural': 'subjects'},
    {'folder': 'units', 'plural': 'units'},
    {'folder': 'lessons', 'plural': 'lessons'},
]

new_method = """String resolveImageUrl(String path) {
  if (path.isEmpty) return '';
  if (path.contains('thumbnails/')) {
    final fileName = path.split('thumbnails/').last;
    return 'http://127.0.0.1:8000/api/v1/thumbnails/' + fileName;
  }
  if (path.startsWith('http')) return path;
  const baseUrl = 'http://127.0.0.1:8000';
  if (path.startsWith('/')) return '$baseUrl$path';
  if (path.startsWith('storage/')) return '$baseUrl/$path';
  return '$baseUrl/storage/$path';
}"""

for entity in entities:
    screen_path = os.path.join(dashboard_path, entity['folder'], 'presentation', 'screens', f"{entity['plural']}_screen.dart")
    if os.path.exists(screen_path):
        with open(screen_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # find `String resolveImageUrl(String path) { ... }`
        # wait, in stages_screen.dart it was `String _resolveImageUrl(String path) {`
        # let's replace both.
        
        # We can use regex to replace everything from `String resolveImageUrl` or `String _resolveImageUrl` up to the closing brace.
        # Since it might have nested braces, we can just find it and replace the exact old content.
        
        # Or simpler:
        pattern = r"String _?resolveImageUrl\(String path\) \{.*?^\}"
        content = re.sub(pattern, new_method, content, flags=re.DOTALL | re.MULTILINE)
        
        with open(screen_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated resolveImageUrl in {screen_path}")
