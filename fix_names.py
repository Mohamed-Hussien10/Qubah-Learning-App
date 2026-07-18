import os

for root, dirs, files in os.walk('web_dashboard/lib/features/free_trial_subjects'):
    for filename in files:
        if 'free_trial_free_trial_' in filename:
            new_name = filename.replace('free_trial_free_trial_', 'free_trial_')
            os.rename(os.path.join(root, filename), os.path.join(root, new_name))
        elif 'free_trial_subjectss' in filename:
            new_name = filename.replace('free_trial_subjectss', 'free_trial_subjects')
            os.rename(os.path.join(root, filename), os.path.join(root, new_name))

for root, dirs, files in os.walk('web_dashboard/lib/features/free_trial_lesson_files'):
    for filename in files:
        if 'free_trial_free_trial_' in filename:
            new_name = filename.replace('free_trial_free_trial_', 'free_trial_')
            os.rename(os.path.join(root, filename), os.path.join(root, new_name))
        elif 'free_trial_lesson_filess' in filename:
            new_name = filename.replace('free_trial_lesson_filess', 'free_trial_lesson_files')
            os.rename(os.path.join(root, filename), os.path.join(root, new_name))

def fix_content(directory):
    for root, dirs, files in os.walk(directory):
        for filename in files:
            filepath = os.path.join(root, filename)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            content = content.replace('free_trial_free_trial_', 'free_trial_')
            content = content.replace('FreeTrialFreeTrial', 'FreeTrial')
            
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)

fix_content('web_dashboard/lib/features/free_trial_subjects')
fix_content('web_dashboard/lib/features/free_trial_lesson_files')

print("Fixed filenames and content")
