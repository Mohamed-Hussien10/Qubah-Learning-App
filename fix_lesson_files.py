import os

directory = 'web_dashboard/lib/features/free_trial_lesson_files'

# Rename files
for root, dirs, files in os.walk(directory):
    for filename in files:
        if 'subject_file' in filename:
            new_name = filename.replace('subject_file', 'lesson_file')
            os.rename(os.path.join(root, filename), os.path.join(root, new_name))

# Replace content
for root, dirs, files in os.walk(directory):
    for filename in files:
        filepath = os.path.join(root, filename)
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        content = content.replace('subject_file', 'lesson_file')
        content = content.replace('SubjectFile', 'LessonFile')
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)

print("Fixed subject_file -> lesson_file")
