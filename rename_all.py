import os
import shutil

def clone_and_rename_file(src, dest, replacements):
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    with open(src, 'r', encoding='utf-8') as f:
        content = f.read()
    
    for old, new in replacements:
        content = content.replace(old, new)
        
    with open(dest, 'w', encoding='utf-8') as f:
        f.write(content)

def main():
    base = 'web_dashboard/lib/features/'
    
    # 1. Models
    clone_and_rename_file(
        base + 'educational_stages/data/models/stage_model.dart',
        base + 'free_trial/data/models/free_trial_stage_model.dart',
        [('StageModel', 'FreeTrialStageModel')]
    )
    
    clone_and_rename_file(
        base + 'grades/data/models/grade_model.dart',
        base + 'free_trial/data/models/free_trial_grade_model.dart',
        [
            ('GradeModel', 'FreeTrialGradeModel'),
            ('educational_stage_id', 'free_trial_educational_stage_id'),
            ('educationalStageId', 'freeTrialEducationalStageId')
        ]
    )
    
    # 2. Repositories
    clone_and_rename_file(
        base + 'educational_stages/data/repositories/stages_repository.dart',
        base + 'free_trial/data/repositories/free_trial_stages_repository.dart',
        [
            ('StagesRepository', 'FreeTrialStagesRepository'),
            ('StageModel', 'FreeTrialStageModel'),
            ("'educational-stages'", "'free-trial/stages'"),
            ("stage_model.dart", "../models/free_trial_stage_model.dart")
        ]
    )

    clone_and_rename_file(
        base + 'grades/data/repositories/grades_repository.dart',
        base + 'free_trial/data/repositories/free_trial_grades_repository.dart',
        [
            ('GradesRepository', 'FreeTrialGradesRepository'),
            ('GradeModel', 'FreeTrialGradeModel'),
            ("'grades'", "'free-trial/grades'"),
            ("grade_model.dart", "../models/free_trial_grade_model.dart")
        ]
    )
    
    # 3. Cubits
    clone_and_rename_file(
        base + 'educational_stages/presentation/manager/stages_cubit.dart',
        base + 'free_trial/presentation/manager/free_trial_stages_cubit.dart',
        [
            ('StagesCubit', 'FreeTrialStagesCubit'),
            ('StagesState', 'FreeTrialStagesState'),
            ('StagesInitial', 'FreeTrialStagesInitial'),
            ('StagesLoading', 'FreeTrialStagesLoading'),
            ('StagesLoaded', 'FreeTrialStagesLoaded'),
            ('StagesError', 'FreeTrialStagesError'),
            ('StageModel', 'FreeTrialStageModel'),
            ('StagesRepository', 'FreeTrialStagesRepository'),
            ('stages_repository.dart', '../../data/repositories/free_trial_stages_repository.dart'),
            ('stage_model.dart', '../../data/models/free_trial_stage_model.dart')
        ]
    )
    
    clone_and_rename_file(
        base + 'grades/presentation/manager/grades_cubit.dart',
        base + 'free_trial/presentation/manager/free_trial_grades_cubit.dart',
        [
            ('GradesCubit', 'FreeTrialGradesCubit'),
            ('GradesState', 'FreeTrialGradesState'),
            ('GradesInitial', 'FreeTrialGradesInitial'),
            ('GradesLoading', 'FreeTrialGradesLoading'),
            ('GradesLoaded', 'FreeTrialGradesLoaded'),
            ('GradesError', 'FreeTrialGradesError'),
            ('GradeModel', 'FreeTrialGradeModel'),
            ('GradesRepository', 'FreeTrialGradesRepository'),
            ('grades_repository.dart', '../../data/repositories/free_trial_grades_repository.dart'),
            ('grade_model.dart', '../../data/models/free_trial_grade_model.dart')
        ]
    )

if __name__ == '__main__':
    main()
