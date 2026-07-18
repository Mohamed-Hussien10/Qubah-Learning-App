import os
import re

base_path = r"d:\Flutter\Qubah App\qubah_learning_app\web_dashboard\lib\features"

def replace_regex_in_file(filepath, pattern, replacement):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    content = re.sub(pattern, replacement, content, flags=re.DOTALL)
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Updated {filepath}")

# 2. Revert FreeTrialGradesCubit.dart
grades_cubit = os.path.join(base_path, 'free_trial_grades', 'presentation', 'manager', 'free_trial_grades_cubit.dart')
replace_regex_in_file(grades_cubit,
    r'final updatedGrades = await Future.wait\(.*?\);[\s\S]*?emit\(FreeTrialGradesLoaded\(stageId: stageId, stageName: _stageName, free_trial_grades: updatedGrades, filteredFreeTrialGrades: updatedGrades\)\);',
    r'emit(FreeTrialGradesLoaded(stageId: stageId, stageName: _stageName, free_trial_grades: free_trial_grades, filteredFreeTrialGrades: free_trial_grades));'
)

# 3. Revert FreeTrialSubjectsCubit.dart
subjects_cubit = os.path.join(base_path, 'free_trial_subjects', 'presentation', 'manager', 'free_trial_subjects_cubit.dart')
replace_regex_in_file(subjects_cubit,
    r'final updatedSubjects = await Future.wait\(.*?\);[\s\S]*?emit\(FreeTrialSubjectsLoaded\(gradeId: gradeId, gradeName: _gradeName, free_trial_subjects: updatedSubjects, filteredFreeTrialSubjects: updatedSubjects\)\);',
    r'emit(FreeTrialSubjectsLoaded(gradeId: gradeId, gradeName: _gradeName, free_trial_subjects: free_trial_subjects, filteredFreeTrialSubjects: free_trial_subjects));'
)

print("Done using regex!")
