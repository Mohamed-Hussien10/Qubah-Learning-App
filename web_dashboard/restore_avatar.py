import os
import re

base_path = r"d:\Flutter\Qubah App\qubah_learning_app\web_dashboard\lib\features"

def restore_circle_avatar(filepath, icon_name, var_name):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Remove the NetworkAvatar import
    content = content.replace("import 'package:web_dashboard/core/widgets/network_avatar.dart';", "")

    # Replace NetworkAvatar(...) back to CircleAvatar
    pattern = rf'NetworkAvatar\(imageUrl: {var_name}\.thumbnailUrl, defaultIcon: Icons\.{icon_name}, radius: 18\),?'
    
    replacement = f'''CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                          backgroundImage: ({var_name}.thumbnailUrl != null &&
                                  {var_name}.thumbnailUrl!.isNotEmpty)
                              ? NetworkImage(resolveImageUrl({var_name}.thumbnailUrl!))
                              : null,
                        onBackgroundImageError: ({var_name}.thumbnailUrl != null && {var_name}.thumbnailUrl!.isNotEmpty) 
                            ? (_, __) {{}} 
                            : null,
                        child: ({var_name}.thumbnailUrl == null || {var_name}.thumbnailUrl!.isEmpty)
                            ? const Icon(Icons.{icon_name}, size: 18, color: AppColors.primary)
                            : null,
                      )'''
                              
    content = re.sub(pattern, replacement, content)
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

restore_circle_avatar(os.path.join(base_path, 'free_trial_stages', 'presentation', 'screens', 'free_trial_stages_screen.dart'), 'school', 'free_trial_stage')
restore_circle_avatar(os.path.join(base_path, 'free_trial_grades', 'presentation', 'screens', 'free_trial_grades_screen.dart'), 'class_rounded', 'free_trial_grade')
restore_circle_avatar(os.path.join(base_path, 'free_trial_subjects', 'presentation', 'screens', 'free_trial_subjects_screen.dart'), 'menu_book_rounded', 'free_trial_subject')
print("Restored CircleAvatar!")
