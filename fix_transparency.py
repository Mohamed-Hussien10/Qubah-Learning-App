import glob

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
        
        # Replace transparent backgrounds with the explicit theme background
        new_content = new_content.replace('backgroundColor: Colors.transparent,', 'backgroundColor: Theme.of(context).scaffoldBackgroundColor,')
        
        if content != new_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f'Updated {filepath}')
