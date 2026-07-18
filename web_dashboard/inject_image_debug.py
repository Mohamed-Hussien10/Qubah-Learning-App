import os
import re

base_path = r"d:\Flutter\Qubah App\qubah_learning_app\web_dashboard\lib\features"

def inject_error_logging(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # We want to add onBackgroundImageError to CircleAvatar inside DataCell
    pattern = r'(backgroundImage:\s*\(.*?\)\s*\?\s*NetworkImage\([^)]+\)\s*:\s*null,)'
    replacement = r'\1\n                          onBackgroundImageError: (exception, stackTrace) {\n                            debugPrint("Image Load Error: $exception");\n                          },'
    
    content = re.sub(pattern, replacement, content)
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

inject_error_logging(os.path.join(base_path, 'free_trial_stages', 'presentation', 'screens', 'free_trial_stages_screen.dart'))
print("Injected error logging!")
