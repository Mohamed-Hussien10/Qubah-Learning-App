import glob
import re

directories = [
    'd:/Flutter/Qubah App/qubah_learning_app/lib/features/educational_stages',
    'd:/Flutter/Qubah App/qubah_learning_app/lib/features/grades',
    'd:/Flutter/Qubah App/qubah_learning_app/lib/features/sections',
    'd:/Flutter/Qubah App/qubah_learning_app/lib/features/subjects',
    'd:/Flutter/Qubah App/qubah_learning_app/lib/features/units',
    'd:/Flutter/Qubah App/qubah_learning_app/lib/features/lessons',
    'd:/Flutter/Qubah App/qubah_learning_app/lib/features/lesson_files',
]

for d in directories:
    for filepath in glob.glob(d + '/**/*.dart', recursive=True):
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            
        new_content = content
        
        # Add imports if not present
        if 'ErrorDisplay' not in new_content and 'state is ' in new_content:
            new_content = new_content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../../../../core/widgets/error_display.dart';\nimport '../../../../core/utils/error_utils.dart';\nimport '../../../../core/widgets/shimmer_loading.dart';")
            
        # Replace CircularProgressIndicator with ShimmerGrid
        new_content = new_content.replace('const Center(child: CircularProgressIndicator())', 'const ShimmerGrid()')
        
        # Replace Center(child: Text(state.message)) with ErrorDisplay
        new_content = re.sub(r'Center\(child:\s*Text\(state\.message\)\)', 'ErrorDisplay(message: ErrorUtils.getFriendlyMessage(state.message))', new_content)
        
        if content != new_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f'Updated {filepath}')
