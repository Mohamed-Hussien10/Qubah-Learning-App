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
    "'educational_stage_id': stageId,": "'free_trial_educational_stage_id': stageId,"
})

# 2. free_trial_subject_model.dart
subject_model = os.path.join(base_path, 'free_trial_subjects', 'data', 'models', 'free_trial_subject_model.dart')
replace_in_file(subject_model, {
    "'grade_id': gradeId,": "'free_trial_grade_id': gradeId,"
})

# 3. free_trial_lesson_file_model.dart
file_model = os.path.join(base_path, 'free_trial_lesson_files', 'data', 'models', 'free_trial_lesson_file_model.dart')
replace_in_file(file_model, {
    "'subject_id': subjectId,": "'free_trial_subject_id': subjectId,"
})

# 4. free_trial_lesson_files_repository.dart
file_repo = os.path.join(base_path, 'free_trial_lesson_files', 'data', 'repositories', 'free_trial_lesson_files_repository.dart')
replace_in_file(file_repo, {
    "'subject_id': subjectId,": "'free_trial_subject_id': subjectId,"
})

print("Done fixing foreign keys!")
