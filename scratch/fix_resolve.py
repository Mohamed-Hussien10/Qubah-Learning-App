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

resolve_func = """
String resolveImageUrl(String path) {
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
"""

for entity in entities:
    screen_path = os.path.join(dashboard_path, entity['folder'], 'presentation', 'screens', f"{entity['plural']}_screen.dart")
    if os.path.exists(screen_path):
        with open(screen_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Change calls from _resolveImageUrl to resolveImageUrl
        content = content.replace('_resolveImageUrl', 'resolveImageUrl')
        
        # Remove the injected function from the bottom
        # It looks like:
        #   String resolveImageUrl(String path) {
        #     if (path.startsWith('http')) return path;
        # ...
        #   }
        # }
        
        func_regex = r"\s*String resolveImageUrl\(String path\) \{[\s\S]*?return '\$baseUrl/storage/\$path';\s*\}\s*\}"
        content = re.sub(func_regex, "", content)
        
        # Now append the top-level function at the very end of the file (after the last class's closing brace)
        content = content + "\n" + resolve_func
        
        with open(screen_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Fixed {screen_path}")
