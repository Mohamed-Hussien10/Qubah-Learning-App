import os

target = "e.toString().split('Error: ').last.trim()"
replacement = "ErrorHandler.handle(e)"
import_stmt = "import 'package:qubah_learning_app/core/errors/error_handler.dart';"

for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            if target in content:
                content = content.replace(target, replacement)
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
