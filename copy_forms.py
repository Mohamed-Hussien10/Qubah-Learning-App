import os

def copy_forms():
    base = 'web_dashboard/lib/features/'
    
    # Stages Form
    src = base + 'educational_stages/presentation/widgets/stage_form_dialog.dart'
    dest = base + 'free_trial/presentation/widgets/free_trial_stage_form_dialog.dart'
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    with open(src, 'r', encoding='utf-8') as f:
        content = f.read()

    content = content.replace("import 'package:web_dashboard/features/educational_stages/data/models/stage_model.dart';", "import 'package:web_dashboard/features/free_trial/data/models/free_trial_stage_model.dart';")
    content = content.replace("import 'package:web_dashboard/features/educational_stages/presentation/manager/stages_cubit.dart';", "import 'package:web_dashboard/features/free_trial/presentation/manager/free_trial_stages_cubit.dart';")
    content = content.replace('StageFormDialog', 'FreeTrialStageFormDialog')
    content = content.replace('StageModel', 'FreeTrialStageModel')
    content = content.replace('StagesCubit', 'FreeTrialStagesCubit')
    content = content.replace('AppStrings.stages', '"المراحل التجريبية"')
    content = content.replace('AppStrings.stage', '"مرحلة تجريبية"')

    with open(dest, 'w', encoding='utf-8') as f:
        f.write(content)

    # Grades Form
    src = base + 'grades/presentation/widgets/grade_form_dialog.dart'
    dest = base + 'free_trial/presentation/widgets/free_trial_grade_form_dialog.dart'
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    with open(src, 'r', encoding='utf-8') as f:
        content = f.read()

    content = content.replace("import 'package:web_dashboard/features/grades/data/models/grade_model.dart';", "import 'package:web_dashboard/features/free_trial/data/models/free_trial_grade_model.dart';")
    content = content.replace("import 'package:web_dashboard/features/grades/presentation/manager/grades_cubit.dart';", "import 'package:web_dashboard/features/free_trial/presentation/manager/free_trial_grades_cubit.dart';")
    content = content.replace('GradeFormDialog', 'FreeTrialGradeFormDialog')
    content = content.replace('GradeModel', 'FreeTrialGradeModel')
    content = content.replace('GradesCubit', 'FreeTrialGradesCubit')
    content = content.replace('AppStrings.grades', '"الصفوف التجريبية"')
    content = content.replace('AppStrings.grade', '"صف تجريبي"')
    content = content.replace('educationalStageId', 'freeTrialEducationalStageId')

    with open(dest, 'w', encoding='utf-8') as f:
        f.write(content)

copy_forms()
print("Done forms")
