import os
import shutil
import re

def multi_replace(text, replacements_dict):
    # Sort keys by length, descending, so longer words match first
    keys = sorted(replacements_dict.keys(), key=len, reverse=True)
    pattern = re.compile('|'.join(re.escape(key) for key in keys))
    return pattern.sub(lambda m: replacements_dict[m.group(0)], text)

def process_dir(src, dest, replacements_dict):
    if os.path.exists(dest):
        shutil.rmtree(dest)
    shutil.copytree(src, dest)
    
    # Replace file names
    for root, dirs, files in os.walk(dest):
        for filename in files:
            new_name = multi_replace(filename, replacements_dict)
            if new_name != filename:
                os.rename(os.path.join(root, filename), os.path.join(root, new_name))
                
    # Now dirs
    for root, dirs, files in os.walk(dest, topdown=False):
        for dirname in dirs:
            new_name = multi_replace(dirname, replacements_dict)
            if new_name != dirname:
                os.rename(os.path.join(root, dirname), os.path.join(root, new_name))
                
    # Content
    for root, dirs, files in os.walk(dest):
        for filename in files:
            filepath = os.path.join(root, filename)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            content = multi_replace(content, replacements_dict)
            
            # Additional path logic
            if 'free_trial_subjects' in dest:
                content = content.replace("ApiEndpoints.subjects", "'/free-trial/subjects'")
                content = content.replace("ApiEndpoints.subject(int.parse(free_trial_subject.id))", f"'/free-trial/subjects/${{free_trial_subject.id}}'")
                content = content.replace("'/sections/$gradeId'", "'/free-trial/grades/$gradeId/subjects'")
            elif 'free_trial_lesson_files' in dest:
                content = content.replace("ApiEndpoints.lessonFiles", "'/free-trial/lesson-files'")
                content = content.replace("ApiEndpoints.lessonFile(int.parse(free_trial_lesson_file.id))", f"'/free-trial/lesson-files/${{free_trial_lesson_file.id}}'")
                content = content.replace("'/lessons/$subjectId'", "'/free-trial/subjects/$subjectId/lesson-files'")
            elif 'free_trial_stages' in dest:
                content = content.replace("ApiEndpoints.educationalStages", "'/free-trial/stages'")
                content = content.replace("ApiEndpoints.educationalStage(int.parse(free_trial_stage.id))", f"'/free-trial/stages/${{free_trial_stage.id}}'")
            elif 'free_trial_grades' in dest:
                content = content.replace("ApiEndpoints.grades", "'/free-trial/grades'")
                content = content.replace("ApiEndpoints.grade(int.parse(free_trial_grade.id))", f"'/free-trial/grades/${{free_trial_grade.id}}'")
                content = content.replace("'/educational-stages/$stageId'", "'/free-trial/stages/$stageId/grades'")

            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)

rules_subjects = {
    'SubjectsCubit': 'FreeTrialSubjectsCubit',
    'SubjectsState': 'FreeTrialSubjectsState',
    'SubjectModel': 'FreeTrialSubjectModel',
    'SubjectsRepository': 'FreeTrialSubjectsRepository',
    'Subjects': 'FreeTrialSubjects',
    'subjects': 'free_trial_subjects',
    'Subject': 'FreeTrialSubject',
    'subject': 'free_trial_subject',
    'sectionId': 'gradeId',
    'Section': 'Grade',
    'section': 'grade',
}
process_dir('subjects', 'free_trial_subjects', rules_subjects)

rules_files = {
    'LessonFiles': 'FreeTrialLessonFiles',
    'lesson_files': 'free_trial_lesson_files',
    'LessonFile': 'FreeTrialLessonFile',
    'lesson_file': 'free_trial_lesson_file',
    'lessonId': 'subjectId',
    'Lesson': 'Subject',
    'lesson': 'subject',
}
process_dir('lesson_files', 'free_trial_lesson_files', rules_files)

rules_stages = {
    'EducationalStages': 'FreeTrialStages',
    'educational_stages': 'free_trial_stages',
    'EducationalStage': 'FreeTrialStage',
    'educational_stage': 'free_trial_stage',
    'Stages': 'FreeTrialStages',
    'stages': 'free_trial_stages',
    'Stage': 'FreeTrialStage',
    'stage': 'free_trial_stage',
}
process_dir('educational_stages', 'free_trial_stages', rules_stages)

rules_grades = {
    'Grades': 'FreeTrialGrades',
    'grades': 'free_trial_grades',
    'Grade': 'FreeTrialGrade',
    'grade': 'free_trial_grade',
}
process_dir('grades', 'free_trial_grades', rules_grades)

print("Copy and substitution complete using single-pass regex.")
