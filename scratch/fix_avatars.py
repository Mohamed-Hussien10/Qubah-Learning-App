import os
import re

dashboard_path = 'd:/Flutter/Qubah App/qubah_learning_app/web_dashboard/lib/features'
entities = [
    {'folder': 'grades', 'name': 'Grade', 'plural': 'grades'},
    {'folder': 'sections', 'name': 'Section', 'plural': 'sections'},
    {'folder': 'subjects', 'name': 'Subject', 'plural': 'subjects'},
    {'folder': 'units', 'name': 'Unit', 'plural': 'units'},
    {'folder': 'lessons', 'name': 'Lesson', 'plural': 'lessons'},
]

for entity in entities:
    screen_path = os.path.join(dashboard_path, entity['folder'], 'presentation', 'screens', f"{entity['plural']}_screen.dart")
    if os.path.exists(screen_path):
        with open(screen_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        item_var = entity['name'].lower()
        
        # We will use regex to find the CircleAvatar and replace it
        # Look for: CircleAvatar( radius: 18, backgroundColor: ... child: const Icon(..., size: 18, color: ...) )
        avatar_regex = r"(CircleAvatar\(\s*radius:\s*18,\s*backgroundColor:\s*AppColors\.primaryLight\.withOpacity\(0\.2\),\s*child:\s*const\s*Icon\(([^,]+),\s*size:\s*18,\s*color:\s*AppColors\.primary\),\s*\))"
        
        match = re.search(avatar_regex, content)
        if match:
            icon_name = match.group(2).strip()
            new_avatar = f"""CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                        backgroundImage: ({item_var}.thumbnailUrl != null && {item_var}.thumbnailUrl!.isNotEmpty)
                            ? NetworkImage(_resolveImageUrl({item_var}.thumbnailUrl!))
                            : null,
                        onBackgroundImageError: ({item_var}.thumbnailUrl != null && {item_var}.thumbnailUrl!.isNotEmpty) 
                            ? (_, __) {{}} 
                            : null,
                        child: ({item_var}.thumbnailUrl == null || {item_var}.thumbnailUrl!.isEmpty)
                            ? const Icon({icon_name}, size: 18, color: AppColors.primary)
                            : null,
                      )"""
            content = content.replace(match.group(1), new_avatar)
            
            with open(screen_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Updated avatar in {screen_path}")
