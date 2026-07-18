import os
import re

base_path = r"d:\Flutter\Qubah App\qubah_learning_app\web_dashboard\lib\features"

def replace_in_file(filepath, replacements):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    for old_text, new_text in replacements.items():
        content = content.replace(old_text, new_text)
        
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Updated {filepath}")

# 1. free_trial_stages_cubit.dart
stages_cubit = os.path.join(base_path, 'free_trial_stages', 'presentation', 'manager', 'free_trial_stages_cubit.dart')
replace_in_file(stages_cubit, {
    "getGradesByStage(stage.id)": "getByStageId(stage.id)"
})

# 2. free_trial_grades_cubit.dart
grades_cubit = os.path.join(base_path, 'free_trial_grades', 'presentation', 'manager', 'free_trial_grades_cubit.dart')
replace_in_file(grades_cubit, {
    "getSubjectsByGrade(grade.id)": "getByGradeId(grade.id)"
})

# 3. free_trial_subjects_cubit.dart
subjects_cubit = os.path.join(base_path, 'free_trial_subjects', 'presentation', 'manager', 'free_trial_subjects_cubit.dart')
replace_in_file(subjects_cubit, {
    "getFilesBySubject(subject.id)": "getBySubjectId(subject.id)"
})

print("Done fixing cubit methods!")
