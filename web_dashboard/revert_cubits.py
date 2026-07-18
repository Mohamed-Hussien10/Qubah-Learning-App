import os

base_path = r"d:\Flutter\Qubah App\qubah_learning_app\web_dashboard\lib\features"

def replace_in_file(filepath, old_text, new_text):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    if old_text in content:
        content = content.replace(old_text, new_text)
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {filepath}")
    else:
        print(f"Text not found in {filepath}")

# 1. Revert FreeTrialStagesCubit.dart
stages_cubit = os.path.join(base_path, 'free_trial_stages', 'presentation', 'manager', 'free_trial_stages_cubit.dart')
replace_in_file(stages_cubit, 
    "final updatedStages = await Future.wait(free_trial_stages.map((stage) async {\n        try {\n          final grades = await sl<FreeTrialGradesRepository>().getByStageId(stage.id);\n          return stage.copyWith(gradesCount: grades.length);\n        } catch (_) {\n          return stage;\n        }\n      }));\n      emit(FreeTrialStagesLoaded(free_trial_stages: updatedStages, filteredFreeTrialStages: updatedStages));",
    "emit(FreeTrialStagesLoaded(free_trial_stages: free_trial_stages, filteredFreeTrialStages: free_trial_stages));"
)

# 2. Revert FreeTrialGradesCubit.dart
grades_cubit = os.path.join(base_path, 'free_trial_grades', 'presentation', 'manager', 'free_trial_grades_cubit.dart')
replace_in_file(grades_cubit,
    "final updatedGrades = await Future.wait(free_trial_grades.map((grade) async {\n        try {\n          final subjects = await sl<FreeTrialSubjectsRepository>().getByGradeId(grade.id);\n          return grade.copyWith(subjectsCount: subjects.length);\n        } catch (_) {\n          return grade;\n        }\n      }));\n      emit(FreeTrialGradesLoaded(stageId: stageId, stageName: _stageName, free_trial_grades: updatedGrades, filteredFreeTrialGrades: updatedGrades));",
    "emit(FreeTrialGradesLoaded(stageId: stageId, stageName: _stageName, free_trial_grades: free_trial_grades, filteredFreeTrialGrades: free_trial_grades));"
)

# 3. Revert FreeTrialSubjectsCubit.dart
subjects_cubit = os.path.join(base_path, 'free_trial_subjects', 'presentation', 'manager', 'free_trial_subjects_cubit.dart')
replace_in_file(subjects_cubit,
    "final updatedSubjects = await Future.wait(free_trial_subjects.map((subject) async {\n        try {\n          final files = await sl<FreeTrialLessonFilesRepository>().getBySubjectId(subject.id);\n          return subject.copyWith(lessonFilesCount: files.length);\n        } catch (_) {\n          return subject;\n        }\n      }));\n      emit(FreeTrialSubjectsLoaded(gradeId: gradeId, gradeName: _gradeName, free_trial_subjects: updatedSubjects, filteredFreeTrialSubjects: updatedSubjects));",
    "emit(FreeTrialSubjectsLoaded(gradeId: gradeId, gradeName: _gradeName, free_trial_subjects: free_trial_subjects, filteredFreeTrialSubjects: free_trial_subjects));"
)

# Fix fromJson in GradeModel
grade_model = os.path.join(base_path, 'free_trial_grades', 'data', 'models', 'free_trial_grade_model.dart')
replace_in_file(grade_model,
    "stageId: json['educational_stage_id']?.toString() ?? json['stage_id']?.toString() ?? '',",
    "stageId: json['free_trial_educational_stage_id']?.toString() ?? json['educational_stage_id']?.toString() ?? json['stage_id']?.toString() ?? '',"
)

# Fix fromJson in SubjectModel
subject_model = os.path.join(base_path, 'free_trial_subjects', 'data', 'models', 'free_trial_subject_model.dart')
replace_in_file(subject_model,
    "gradeId: json['grade_id']?.toString() ?? '',",
    "gradeId: json['free_trial_grade_id']?.toString() ?? json['grade_id']?.toString() ?? '',"
)

# Fix fromJson in LessonFileModel
lesson_file_model = os.path.join(base_path, 'free_trial_lesson_files', 'data', 'models', 'free_trial_lesson_file_model.dart')
replace_in_file(lesson_file_model,
    "subjectId: json['subject_id']?.toString() ?? '',",
    "subjectId: json['free_trial_subject_id']?.toString() ?? json['subject_id']?.toString() ?? '',"
)

print("Done reverting cubits and fixing models!")
