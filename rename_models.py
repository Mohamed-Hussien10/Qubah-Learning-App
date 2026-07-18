import os

def rename_stage_model():
    path = 'web_dashboard/lib/features/free_trial/data/models/free_trial_stage_model.dart'
    if not os.path.exists(path):
        os.makedirs(os.path.dirname(path), exist_ok=True)
        return
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    content = content.replace('StageModel', 'FreeTrialStageModel')
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

def rename_grade_model():
    path = 'web_dashboard/lib/features/free_trial/data/models/free_trial_grade_model.dart'
    if not os.path.exists(path):
        os.makedirs(os.path.dirname(path), exist_ok=True)
        return
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    content = content.replace('GradeModel', 'FreeTrialGradeModel')
    content = content.replace('educational_stage_id', 'free_trial_educational_stage_id')
    content = content.replace('educationalStageId', 'freeTrialEducationalStageId')
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

rename_stage_model()
rename_grade_model()
print("Done renaming models")
