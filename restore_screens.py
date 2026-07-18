import os

def restore_stages_screen():
    src = 'web_dashboard/lib/features/educational_stages/presentation/screens/stages_screen.dart'
    dest = 'web_dashboard/lib/features/free_trial/presentation/screens/free_trial_stages_screen.dart'
    
    with open(src, 'r', encoding='utf-8') as f:
        content = f.read()

    # Imports
    content = content.replace("import 'package:web_dashboard/features/educational_stages/data/models/stage_model.dart';", "import 'package:web_dashboard/features/free_trial/data/models/free_trial_stage_model.dart';")
    content = content.replace("import 'package:web_dashboard/features/educational_stages/presentation/manager/stages_cubit.dart';", "import 'package:web_dashboard/features/free_trial/presentation/manager/free_trial_stages_cubit.dart';")
    content = content.replace("import 'package:web_dashboard/features/educational_stages/presentation/manager/stages_state.dart';", "import 'package:web_dashboard/features/free_trial/presentation/manager/free_trial_stages_state.dart';")
    content = content.replace("import 'package:web_dashboard/features/educational_stages/presentation/widgets/stage_form_dialog.dart';", "import 'package:web_dashboard/features/free_trial/presentation/widgets/free_trial_stage_form_dialog.dart';")

    # Classes/Variables
    content = content.replace('StagesScreen', 'FreeTrialStagesScreen')
    content = content.replace('_StagesView', '_FreeTrialStagesView')
    content = content.replace('StagesCubit', 'FreeTrialStagesCubit')
    content = content.replace('StagesState', 'FreeTrialStagesState')
    content = content.replace('StagesLoading', 'FreeTrialStagesLoading')
    content = content.replace('StagesError', 'FreeTrialStagesError')
    content = content.replace('StagesLoaded', 'FreeTrialStagesLoaded')
    content = content.replace('StageModel', 'FreeTrialStageModel')
    content = content.replace('StageFormDialog', 'FreeTrialStageFormDialog')

    # Routing & UI
    content = content.replace('AppStrings.stages', '"المراحل التجريبية"')
    content = content.replace("context.push('/grades/${stage.id}')", "context.push('/free-trial-grades/${stage.id}')")
    
    with open(dest, 'w', encoding='utf-8') as f:
        f.write(content)

def restore_grades_screen():
    src = 'web_dashboard/lib/features/grades/presentation/screens/grades_screen.dart'
    dest = 'web_dashboard/lib/features/free_trial/presentation/screens/free_trial_grades_screen.dart'
    
    with open(src, 'r', encoding='utf-8') as f:
        content = f.read()

    # Imports
    content = content.replace("import 'package:web_dashboard/features/grades/data/models/grade_model.dart';", "import 'package:web_dashboard/features/free_trial/data/models/free_trial_grade_model.dart';")
    content = content.replace("import 'package:web_dashboard/features/grades/presentation/manager/grades_cubit.dart';", "import 'package:web_dashboard/features/free_trial/presentation/manager/free_trial_grades_cubit.dart';")
    content = content.replace("import 'package:web_dashboard/features/grades/presentation/manager/grades_state.dart';", "import 'package:web_dashboard/features/free_trial/presentation/manager/free_trial_grades_state.dart';")
    content = content.replace("import 'package:web_dashboard/features/grades/presentation/widgets/grade_form_dialog.dart';", "import 'package:web_dashboard/features/free_trial/presentation/widgets/free_trial_grade_form_dialog.dart';")

    # Classes/Variables
    content = content.replace('GradesScreen', 'FreeTrialGradesScreen')
    content = content.replace('_GradesView', '_FreeTrialGradesView')
    content = content.replace('GradesCubit', 'FreeTrialGradesCubit')
    content = content.replace('GradesState', 'FreeTrialGradesState')
    content = content.replace('GradesLoading', 'FreeTrialGradesLoading')
    content = content.replace('GradesError', 'FreeTrialGradesError')
    content = content.replace('GradesLoaded', 'FreeTrialGradesLoaded')
    content = content.replace('GradeModel', 'FreeTrialGradeModel')
    content = content.replace('GradeFormDialog', 'FreeTrialGradeFormDialog')

    # Routing & UI
    content = content.replace('AppStrings.grades', '"الصفوف التجريبية"')
    content = content.replace("context.push('/sections/${grade.id}')", "context.push('/free-trial-subjects/${grade.id}')")
    
    with open(dest, 'w', encoding='utf-8') as f:
        f.write(content)

restore_stages_screen()
restore_grades_screen()
print("Restored screens!")
