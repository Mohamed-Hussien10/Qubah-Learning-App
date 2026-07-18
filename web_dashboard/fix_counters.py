import os

base_path = r"d:\Flutter\Qubah App\qubah_learning_app\web_dashboard\lib\features"

def replace_in_file(filepath, replacements):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    for old_text, new_text in replacements.items():
        content = content.replace(old_text, new_text)
        
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Updated {filepath}")

# 1. free_trial_grade_model.dart
grade_model = os.path.join(base_path, 'free_trial_grades', 'data', 'models', 'free_trial_grade_model.dart')
replace_in_file(grade_model, {
    "sectionsCount": "subjectsCount",
    "sections_count": "subjects_count",
    "json['sections']": "json['subjects']"
})

# 2. free_trial_grades_screen.dart
grades_screen = os.path.join(base_path, 'free_trial_grades', 'presentation', 'screens', 'free_trial_grades_screen.dart')
replace_in_file(grades_screen, {
    "AppStrings.sections": "AppStrings.subjects",
    ".sectionsCount": ".subjectsCount"
})

# 3. free_trial_subject_model.dart
subject_model = os.path.join(base_path, 'free_trial_subjects', 'data', 'models', 'free_trial_subject_model.dart')
replace_in_file(subject_model, {
    "unitsCount": "lessonFilesCount",
    "units_count": "lesson_files_count",
    "json['units']": "json['lesson_files']"
})

# 4. free_trial_subjects_screen.dart
subjects_screen = os.path.join(base_path, 'free_trial_subjects', 'presentation', 'screens', 'free_trial_subjects_screen.dart')
replace_in_file(subjects_screen, {
    "Text('الوحدات')": "Text('الملفات')",
    ".unitsCount": ".lessonFilesCount"
})

print("Done fixing counters!")
