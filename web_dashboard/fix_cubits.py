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
with open(stages_cubit, 'r', encoding='utf-8') as f:
    stages_content = f.read()

if "import 'package:web_dashboard/core/services/dependency_injection.dart';" not in stages_content:
    stages_content = "import 'package:web_dashboard/core/services/dependency_injection.dart';\nimport 'package:web_dashboard/features/free_trial_grades/data/repositories/free_trial_grades_repository.dart';\n" + stages_content

stages_content = stages_content.replace(
    "final free_trial_stages = await _repository.getAll();\n      emit(FreeTrialStagesLoaded(free_trial_stages: free_trial_stages, filteredFreeTrialStages: free_trial_stages));",
    "final free_trial_stages = await _repository.getAll();\n      final updatedStages = await Future.wait(free_trial_stages.map((stage) async {\n        try {\n          final grades = await sl<FreeTrialGradesRepository>().getGradesByStage(stage.id);\n          return stage.copyWith(gradesCount: grades.length);\n        } catch (_) {\n          return stage;\n        }\n      }));\n      emit(FreeTrialStagesLoaded(free_trial_stages: updatedStages, filteredFreeTrialStages: updatedStages));"
)
with open(stages_cubit, 'w', encoding='utf-8') as f:
    f.write(stages_content)

# 2. free_trial_grades_cubit.dart
grades_cubit = os.path.join(base_path, 'free_trial_grades', 'presentation', 'manager', 'free_trial_grades_cubit.dart')
with open(grades_cubit, 'r', encoding='utf-8') as f:
    grades_content = f.read()

if "import 'package:web_dashboard/core/services/dependency_injection.dart';" not in grades_content:
    grades_content = "import 'package:web_dashboard/core/services/dependency_injection.dart';\nimport 'package:web_dashboard/features/free_trial_subjects/data/repositories/free_trial_subjects_repository.dart';\n" + grades_content

grades_content = grades_content.replace(
    "final free_trial_grades = await _repository.getGradesByStage(stageId);\n      emit(FreeTrialGradesLoaded(stageId: stageId, stageName: _stageName, free_trial_grades: free_trial_grades, filteredFreeTrialGrades: free_trial_grades));",
    "final free_trial_grades = await _repository.getGradesByStage(stageId);\n      final updatedGrades = await Future.wait(free_trial_grades.map((grade) async {\n        try {\n          final subjects = await sl<FreeTrialSubjectsRepository>().getSubjectsByGrade(grade.id);\n          return grade.copyWith(subjectsCount: subjects.length);\n        } catch (_) {\n          return grade;\n        }\n      }));\n      emit(FreeTrialGradesLoaded(stageId: stageId, stageName: _stageName, free_trial_grades: updatedGrades, filteredFreeTrialGrades: updatedGrades));"
)
with open(grades_cubit, 'w', encoding='utf-8') as f:
    f.write(grades_content)

# 3. free_trial_subjects_cubit.dart
subjects_cubit = os.path.join(base_path, 'free_trial_subjects', 'presentation', 'manager', 'free_trial_subjects_cubit.dart')
with open(subjects_cubit, 'r', encoding='utf-8') as f:
    subjects_content = f.read()

if "import 'package:web_dashboard/core/services/dependency_injection.dart';" not in subjects_content:
    subjects_content = "import 'package:web_dashboard/core/services/dependency_injection.dart';\nimport 'package:web_dashboard/features/free_trial_lesson_files/data/repositories/free_trial_lesson_files_repository.dart';\n" + subjects_content

subjects_content = subjects_content.replace(
    "final free_trial_subjects = await _repository.getSubjectsByGrade(gradeId);\n      emit(FreeTrialSubjectsLoaded(gradeId: gradeId, gradeName: _gradeName, free_trial_subjects: free_trial_subjects, filteredFreeTrialSubjects: free_trial_subjects));",
    "final free_trial_subjects = await _repository.getSubjectsByGrade(gradeId);\n      final updatedSubjects = await Future.wait(free_trial_subjects.map((subject) async {\n        try {\n          final files = await sl<FreeTrialLessonFilesRepository>().getFilesBySubject(subject.id);\n          return subject.copyWith(lessonFilesCount: files.length);\n        } catch (_) {\n          return subject;\n        }\n      }));\n      emit(FreeTrialSubjectsLoaded(gradeId: gradeId, gradeName: _gradeName, free_trial_subjects: updatedSubjects, filteredFreeTrialSubjects: updatedSubjects));"
)
with open(subjects_cubit, 'w', encoding='utf-8') as f:
    f.write(subjects_content)

print("Done fixing cubits!")
