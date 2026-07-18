import os

base_path = r"d:\Flutter\Qubah App\qubah_learning_app\web_dashboard\lib\features"

def change_part_to_import(filepath, part_name):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    content = content.replace(f"part '{part_name}';", f"import '{part_name}';")
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

change_part_to_import(
    os.path.join(base_path, 'free_trial_stages', 'presentation', 'manager', 'free_trial_stages_cubit.dart'),
    'free_trial_stages_state.dart'
)
change_part_to_import(
    os.path.join(base_path, 'free_trial_grades', 'presentation', 'manager', 'free_trial_grades_cubit.dart'),
    'free_trial_grades_state.dart'
)
change_part_to_import(
    os.path.join(base_path, 'free_trial_subjects', 'presentation', 'manager', 'free_trial_subjects_cubit.dart'),
    'free_trial_subjects_state.dart'
)
