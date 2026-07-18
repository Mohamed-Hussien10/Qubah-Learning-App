import os

def fix_grades_screen():
    path = 'web_dashboard/lib/features/free_trial/presentation/screens/free_trial_grades_screen.dart'
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. stageName
    content = content.replace("final stageName = state is FreeTrialGradesLoaded ? state.stageName : '';", "")
    content = content.replace("return _buildBreadcrumb(context, isDark, stageName);", "return _buildBreadcrumb(context, isDark);")
    content = content.replace("Widget _buildBreadcrumb(BuildContext context, bool isDark, String stageName) {", "Widget _buildBreadcrumb(BuildContext context, bool isDark) {")
    content = content.replace("stageName.isNotEmpty ? stageName : '...',", "'...',")

    # 2. deleteGrade
    content = content.replace("context.read<FreeTrialGradesCubit>().deleteGrade(widget.stageId, grade.id);", "context.read<FreeTrialGradesCubit>().deleteGrade(grade.id);")

    # 3. toggleStatus
    content = content.replace("cubit.toggleStatus(widget.stageId, grade.id, grade.isActive),", "cubit.toggleStatus(grade.id, grade.isActive),")

    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

def fix_stages_screen():
    path = 'web_dashboard/lib/features/free_trial/presentation/screens/free_trial_stages_screen.dart'
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # toggleStatus
    content = content.replace("cubit.toggleStatus(stage.id),", "cubit.toggleStatus(stage.id, stage.isActive),")

    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

fix_grades_screen()
fix_stages_screen()
print("Fixed screens!")
