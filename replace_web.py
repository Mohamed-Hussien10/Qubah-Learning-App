import os

targets = [
    "e.toString().replaceAll('Exception: ', '')",
    "e.toString()"
]
replacement = "ErrorHandler.handle(e)"
import_stmt = "import 'package:web_dashboard/core/errors/error_handler.dart';"

for root, dirs, files in os.walk('web_dashboard/lib/features'):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            modified = False
            for target in targets:
                if target in content:
                    content = content.replace(target, replacement)
                    modified = True
            
            if modified:
                # Add import if missing
                if import_stmt not in content:
                    lines = content.split('\n')
                    # Find last import
                    last_import_idx = 0
                    for i, line in enumerate(lines):
                        if line.startswith('import '):
                            last_import_idx = i
                    lines.insert(last_import_idx + 1, import_stmt)
                    content = '\n'.join(lines)
                
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f'Updated {filepath}')
