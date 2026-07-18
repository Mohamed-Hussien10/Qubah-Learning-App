import os
import re

def process_file(filepath, rules):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    for k, v in rules.items():
        content = content.replace(k, v)
        
    # Remove Add Button from header
    content = re.sub(r'FilledButton\.icon\([^;]+;', 'const SizedBox();', content, flags=re.DOTALL)
    
    # Remove Actions column
    content = content.replace("DataColumn2(label: Text(AppStrings.actions), fixedWidth: 200),", "")
    content = content.replace("DataColumn2(label: Text(AppStrings.actions), fixedWidth: 150),", "")
    
    # Remove Action Icons cell from rows
    # This might be tricky with regex, so let's just make the action cells empty
    content = re.sub(r'DataCell\(\s*Row\(\s*mainAxisSize: MainAxisSize\.min,\s*children: \[\s*_ActionIcon[^\]]+\]\,\s*\)\,\s*\)', 'DataCell(const SizedBox()),', content, flags=re.DOTALL)
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

# Free Trial Stages
rules_stages = {
    'StagesScreen': 'FreeTrialStagesScreen',
    'AppStrings.stages': '"المراحل التجريبية"',
    '_StagesView': '_FreeTrialStagesView',
    "context.push('/grades/${stage.id}')": "context.push('/free-trial-grades/${stage.id}')",
}
process_file('web_dashboard/lib/features/free_trial/presentation/screens/free_trial_stages_screen.dart', rules_stages)

# Free Trial Grades
rules_grades = {
    'GradesScreen': 'FreeTrialGradesScreen',
    'AppStrings.grades': '"الصفوف التجريبية"',
    '_GradesView': '_FreeTrialGradesView',
    "context.push('/sections/${grade.id}')": "context.push('/free-trial-subjects/${grade.id}')",
}
process_file('web_dashboard/lib/features/free_trial/presentation/screens/free_trial_grades_screen.dart', rules_grades)

print("Screens updated.")
