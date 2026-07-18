import os
import re

base_path = r"d:\Flutter\Qubah App\qubah_learning_app\web_dashboard\lib\features"

def use_cached_network_image(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Import CachedNetworkImage if not present
    if "import 'package:cached_network_image/cached_network_image.dart';" not in content:
        content = content.replace(
            "import 'package:flutter/material.dart';",
            "import 'package:flutter/material.dart';\nimport 'package:cached_network_image/cached_network_image.dart';"
        )

    # Replace CircleAvatar with NetworkImage inside DataCell
    pattern = r'child: CircleAvatar\(\s*radius: 18,\s*backgroundColor: AppColors\.primary\.withOpacity\(0\.1\),\s*backgroundImage:\s*\(([^)]+)\)\s*\?\s*NetworkImage\(([^)]+)\)\s*:\s*null,\s*(onBackgroundImageError: [^}]+\},\s*)?child:\s*\([^)]+\)\s*\?\s*const Icon\(([^)]+)\)\s*:\s*null,\s*\)'
    
    replacement = r'''child: \1
                            ? CachedNetworkImage(
                                imageUrl: \2,
                                imageBuilder: (context, imageProvider) => CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.primary.withOpacity(0.1),
                                  backgroundImage: imageProvider,
                                ),
                                placeholder: (context, url) => const SizedBox(
                                  width: 36, height: 36,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                errorWidget: (context, url, error) => Tooltip(
                                  message: 'Error loading image: $error',
                                  child: const CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.redAccent,
                                    child: Icon(Icons.broken_image, color: Colors.white, size: 18),
                                  ),
                                ),
                              )
                            : CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.primary.withOpacity(0.1),
                                child: const Icon(\4),
                              )'''
                              
    content = re.sub(pattern, replacement, content)
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

use_cached_network_image(os.path.join(base_path, 'free_trial_stages', 'presentation', 'screens', 'free_trial_stages_screen.dart'))
use_cached_network_image(os.path.join(base_path, 'free_trial_grades', 'presentation', 'screens', 'free_trial_grades_screen.dart'))
use_cached_network_image(os.path.join(base_path, 'free_trial_subjects', 'presentation', 'screens', 'free_trial_subjects_screen.dart'))
print("Injected visual debugging for images!")
