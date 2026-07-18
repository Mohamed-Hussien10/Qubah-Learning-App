import os

def fix_stages():
    with open('web_dashboard/lib/features/free_trial/presentation/screens/free_trial_stages_screen.dart', 'r', encoding='utf-8') as f:
        content = f.read()

    content = content.replace('StagesScreen', 'FreeTrialStagesScreen')
    content = content.replace('AppStrings.stages', '"المراحل التجريبية"')
    content = content.replace('_StagesView', '_FreeTrialStagesView')
    content = content.replace("context.push('/grades/${stage.id}')", "context.push('/free-trial-grades/${stage.id}')")

    # Remove add button
    content = content.replace('''        FilledButton.icon(
          onPressed: () => _showForm(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('${AppStrings.add} مرحلة'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),''', 'const SizedBox(),')

    # Remove actions column
    content = content.replace("DataColumn2(label: Text(AppStrings.actions), fixedWidth: 200),", "DataColumn2(label: Text(''), fixedWidth: 10),")

    # Replace actions cell
    actions_cell = """                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ActionIcon(
                        icon: Icons.edit_rounded,
                        tooltip: AppStrings.edit,
                        color: AppColors.warning,
                        onTap: () => _showForm(context, stage: stage),
                      ),
                      _ActionIcon(
                        icon: Icons.delete_outline_rounded,
                        tooltip: AppStrings.delete,
                        color: AppColors.error,
                        onTap: () =>
                            _confirmDelete(context, stage),
                      ),
                    ],
                  ),
                ),"""
    content = content.replace(actions_cell, "                DataCell(const SizedBox()),")

    with open('web_dashboard/lib/features/free_trial/presentation/screens/free_trial_stages_screen.dart', 'w', encoding='utf-8') as f:
        f.write(content)


def fix_grades():
    with open('web_dashboard/lib/features/free_trial/presentation/screens/free_trial_grades_screen.dart', 'r', encoding='utf-8') as f:
        content = f.read()

    content = content.replace('GradesScreen', 'FreeTrialGradesScreen')
    content = content.replace('AppStrings.grades', '"الصفوف التجريبية"')
    content = content.replace('_GradesView', '_FreeTrialGradesView')
    content = content.replace("context.push('/sections/${grade.id}')", "context.push('/free-trial-subjects/${grade.id}')")

    # Remove add button
    content = content.replace('''        FilledButton.icon(
          onPressed: () => _showForm(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('${AppStrings.add} صف'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),''', 'const SizedBox(),')

    # Remove actions column
    content = content.replace("DataColumn2(label: Text(AppStrings.actions), fixedWidth: 150),", "DataColumn2(label: Text(''), fixedWidth: 10),")

    # Replace actions cell
    actions_cell = """                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ActionIcon(
                        icon: Icons.edit_rounded,
                        tooltip: AppStrings.edit,
                        color: AppColors.warning,
                        onTap: () => _showForm(context, grade: grade),
                      ),
                      _ActionIcon(
                        icon: Icons.delete_outline_rounded,
                        tooltip: AppStrings.delete,
                        color: AppColors.error,
                        onTap: () => _confirmDelete(context, grade),
                      ),
                    ],
                  ),
                ),"""
    content = content.replace(actions_cell, "                DataCell(const SizedBox()),")

    with open('web_dashboard/lib/features/free_trial/presentation/screens/free_trial_grades_screen.dart', 'w', encoding='utf-8') as f:
        f.write(content)

fix_stages()
fix_grades()
print("Done")
