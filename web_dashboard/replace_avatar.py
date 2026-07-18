import os
import re

base_path = r"d:\Flutter\Qubah App\qubah_learning_app\web_dashboard\lib\features"

def replace_with_network_avatar(filepath, icon_name):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Import NetworkAvatar if not present
    if "import 'package:web_dashboard/core/widgets/network_avatar.dart';" not in content:
        content = content.replace(
            "import 'package:flutter/material.dart';",
            "import 'package:flutter/material.dart';\nimport 'package:web_dashboard/core/widgets/network_avatar.dart';"
        )

    # Replace the huge CircleAvatar block
    pattern = r'CircleAvatar\(\s*radius: 18,\s*backgroundColor: [^,]+,\s*backgroundImage: [^,]+,\s*onBackgroundImageError: [^,]+,\s*child: [^,]+,\s*\)'
    
    # Wait, the exact block in stages is:
    # CircleAvatar(
    #   radius: 18,
    #   backgroundColor: AppColors.primaryLight.withOpacity(0.2),
    #   backgroundImage: (free_trial_stage.thumbnailUrl != null &&
    #           free_trial_stage.thumbnailUrl!.isNotEmpty)
    #       ? NetworkImage(resolveImageUrl(free_trial_stage.thumbnailUrl!))
    #       : null,
    #   onBackgroundImageError: (free_trial_stage.thumbnailUrl != null && free_trial_stage.thumbnailUrl!.isNotEmpty) 
    #       ? (_, __) {} 
    #       : null,
    #   child: (free_trial_stage.thumbnailUrl == null || free_trial_stage.thumbnailUrl!.isEmpty)
    #       ? const Icon(Icons.school, size: 18, color: AppColors.primary)
    #       : null,
    # )
    
    # A generic regex for it is:
    pattern2 = r'CircleAvatar\(\s*radius:\s*18,\s*backgroundColor:.*?\s*backgroundImage:.*?\s*onBackgroundImageError:.*?\s*child:.*?\s*\)'
    
    # In each file, the variable name is different (free_trial_stage, free_trial_grade, free_trial_subject)
    # I'll just use a more targeted replacement
    
    match = re.search(r'backgroundImage:\s*\(([^.]+)\.thumbnailUrl', content)
    if match:
        var_name = match.group(1)
        replacement = f'NetworkAvatar(imageUrl: {var_name}.thumbnailUrl, defaultIcon: Icons.{icon_name}, radius: 18)'
        content = re.sub(pattern2, replacement, content, flags=re.DOTALL)
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

replace_with_network_avatar(os.path.join(base_path, 'free_trial_stages', 'presentation', 'screens', 'free_trial_stages_screen.dart'), 'school')
replace_with_network_avatar(os.path.join(base_path, 'free_trial_grades', 'presentation', 'screens', 'free_trial_grades_screen.dart'), 'class_')
replace_with_network_avatar(os.path.join(base_path, 'free_trial_subjects', 'presentation', 'screens', 'free_trial_subjects_screen.dart'), 'menu_book')
print("Replaced CircleAvatar with NetworkAvatar!")
