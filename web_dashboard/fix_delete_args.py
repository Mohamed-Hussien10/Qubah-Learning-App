import os

base_path = r"d:\Flutter\Qubah App\qubah_learning_app\web_dashboard\lib\features"

def replace_in_file(filepath, old, new):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    content = content.replace(old, new)
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

replace_in_file(
    os.path.join(base_path, 'free_trial_grades', 'presentation', 'manager', 'free_trial_grades_cubit.dart'),
    "await _repository.delete(id);",
    "await _repository.delete(_stageId, id);"
)

replace_in_file(
    os.path.join(base_path, 'free_trial_subjects', 'presentation', 'manager', 'free_trial_subjects_cubit.dart'),
    "await _repository.delete(id);",
    "await _repository.delete(_gradeId, id);"
)

print("Fixed delete arguments!")
