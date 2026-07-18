import os

base_path = r"d:\Flutter\Qubah App\qubah_learning_app\web_dashboard\lib\features"

def replace_in_file(filepath, old_text, new_text):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    new_content = content.replace(old_text, new_text)
    
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated {filepath}")
    else:
        print(f"No changes made to {filepath}")

# 1. free_trial_grades_repository.dart
grades_repo = os.path.join(base_path, 'free_trial_grades', 'data', 'repositories', 'free_trial_grades_repository.dart')
grades_old = """    final data = response.data['data'];
    final free_trial_grades = data?['free_trial_grades'];
    if (free_trial_grades is List) {
      return free_trial_grades
          .map((json) => FreeTrialGradeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }"""
grades_new = """    final data = response.data['data'];
    if (data is List) {
      return data
          .map((json) => FreeTrialGradeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }"""
replace_in_file(grades_repo, grades_old, grades_new)

# 2. free_trial_subjects_repository.dart
subjects_repo = os.path.join(base_path, 'free_trial_subjects', 'data', 'repositories', 'free_trial_subjects_repository.dart')
subjects_old = """    final data = response.data['data'];
    final free_trial_subjects = data?['free_trial_subjects'];
    if (free_trial_subjects is List) {
      return free_trial_subjects
          .map((json) => FreeTrialSubjectModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }"""
subjects_new = """    final data = response.data['data'];
    if (data is List) {
      return data
          .map((json) => FreeTrialSubjectModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }"""
replace_in_file(subjects_repo, subjects_old, subjects_new)

# 3. free_trial_lesson_files_repository.dart
files_repo = os.path.join(base_path, 'free_trial_lesson_files', 'data', 'repositories', 'free_trial_lesson_files_repository.dart')
files_old = """    final data = response.data['data'];
    final lesson_files = data?['lesson_files'];
    if (lesson_files is List) {
      return lesson_files
          .map((json) => FreeTrialLessonFileModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }"""
files_new = """    final data = response.data['data'];
    if (data is List) {
      return data
          .map((json) => FreeTrialLessonFileModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }"""
replace_in_file(files_repo, files_old, files_new)

print("Done fixing json parsing!")
