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

# 1. stages
stages_screen = os.path.join(base_path, 'free_trial_stages', 'presentation', 'screens', 'free_trial_stages_screen.dart')
replace_in_file(stages_screen, {
    "context.push('/grades/${free_trial_stage.id}');": "context.push('/free-trial-grades/${free_trial_stage.id}');"
})

# 2. grades
grades_screen = os.path.join(base_path, 'free_trial_grades', 'presentation', 'screens', 'free_trial_grades_screen.dart')
replace_in_file(grades_screen, {
    "_navigateToSections": "_navigateToSubjects",
    "context.push('/sections/${free_trial_grade.id}');": "context.push('/free-trial-subjects/${free_trial_grade.id}');"
})

# 3. subjects
subjects_screen = os.path.join(base_path, 'free_trial_subjects', 'presentation', 'screens', 'free_trial_subjects_screen.dart')
replace_in_file(subjects_screen, {
    "_navigateToUnits": "_navigateToLessonFiles",
    "context.push('/units/${free_trial_subject.id}');": "context.push('/free-trial-lesson-files/${free_trial_subject.id}');"
})

print("Done updating navigation!")
