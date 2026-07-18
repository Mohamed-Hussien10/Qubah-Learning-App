import os
import re

base_path = r"d:\Flutter\Qubah App\qubah_learning_app\web_dashboard\lib\features"

def replace_in_file(filepath, old_content, new_content):
    if not os.path.exists(filepath):
        print(f"File not found: {filepath}")
        return
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    new_data = content.replace(old_content, new_content)
    if new_data != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_data)
        print(f"Updated {filepath}")
    else:
        print(f"No changes for {filepath}")

# 1. free_trial_stages_repository.dart
# (It uses ApiEndpoints, so it might be fine, but let's check if there are hardcoded things)
# Wait, ApiEndpoints handles stages correctly now.

# 2. free_trial_grades_repository.dart
grades_repo = os.path.join(base_path, 'free_trial_grades', 'data', 'repositories', 'free_trial_grades_repository.dart')
replace_in_file(grades_repo, 
                "'/free_trial_grades/$id'", 
                "ApiEndpoints.free_trial_grade(int.parse(id))")

# 3. free_trial_subjects_repository.dart
subjects_repo = os.path.join(base_path, 'free_trial_subjects', 'data', 'repositories', 'free_trial_subjects_repository.dart')
replace_in_file(subjects_repo, 
                "'/grades/$gradeId'", 
                "'/free-trial/grades/$gradeId/subjects'")
replace_in_file(subjects_repo, 
                "'/free_trial_subjects/$id'", 
                "ApiEndpoints.free_trial_subject(int.parse(id))")
replace_in_file(subjects_repo, 
                "'/free_trial_subjects'", 
                "ApiEndpoints.free_trial_subjects")

# 4. free_trial_lesson_files_repository.dart
files_repo = os.path.join(base_path, 'free_trial_lesson_files', 'data', 'repositories', 'free_trial_lesson_files_repository.dart')
replace_in_file(files_repo, 
                "'/subjects/$subjectId'", 
                "'/free-trial/subjects/$subjectId/lesson-files'")
# Note: in files_repo, the key in data is probably 'lesson_files' or 'subjectFiles'? 
# The backend free-trial controller says getLessonFilesBySubject. So the key is probably 'lesson_files'. Let's replace 'subjectFiles' with 'lesson_files'
replace_in_file(files_repo, 
                "['subjectFiles']", 
                "['lesson_files']")
replace_in_file(files_repo, 
                "'/subject-files/$id'", 
                "'/free-trial/lesson-files/$id'")
replace_in_file(files_repo, 
                "'/subject-files'", 
                "'/free-trial/lesson-files'")
replace_in_file(files_repo,
                "'/subject-files/${file.id}'",
                "'/free-trial/lesson-files/${file.id}'")
replace_in_file(files_repo,
                "'/subject-files/upload'",
                "'/free-trial/lesson-files/upload'")

