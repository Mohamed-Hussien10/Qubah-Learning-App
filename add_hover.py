import os
import re

lib_dir = r'd:\Flutter\Qubah App\qubah_learning_app\lib'

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    targets = ['ElevatedButton', 'TextButton', 'IconButton', 'FilledButton', 'OutlinedButton']
    
    modified = False
    new_content = content
    
    for target in targets:
        search_idx = 0
        while True:
            idx = new_content.find(target + '(', search_idx)
            idx_icon = new_content.find(target + '.icon(', search_idx)
            idx_styleFrom = new_content.find(target + '.styleFrom(', search_idx)
            
            if idx_styleFrom != -1 and (idx == -1 or idx_styleFrom < idx):
                search_idx = idx_styleFrom + len(target + '.styleFrom(')
                continue
                
            actual_idx = -1
            if idx != -1 and idx_icon != -1:
                actual_idx = min(idx, idx_icon)
            else:
                actual_idx = max(idx, idx_icon)
                
            if actual_idx == -1:
                break
                
            start_paren = new_content.find('(', actual_idx)
            paren_count = 1
            curr_idx = start_paren + 1
            
            while paren_count > 0 and curr_idx < len(new_content):
                if new_content[curr_idx] == '(':
                    paren_count += 1
                elif new_content[curr_idx] == ')':
                    paren_count -= 1
                curr_idx += 1
                
            if paren_count == 0:
                prefix = new_content[max(0, actual_idx-20):actual_idx]
                if 'HoverScale(' not in prefix:
                    before = new_content[:actual_idx]
                    middle = new_content[actual_idx:curr_idx]
                    after = new_content[curr_idx:]
                    new_content = before + 'HoverScale(child: ' + middle + ')' + after
                    modified = True
                    search_idx = curr_idx + len('HoverScale(child: )')
                else:
                    search_idx = curr_idx
            else:
                search_idx = actual_idx + 1

    if modified:
        import_stmt = "import 'package:qubah_learning_app/core/widgets/hover_scale.dart';"
        if import_stmt not in new_content:
            first_import = new_content.find('import ')
            if first_import != -1:
                new_content = new_content[:first_import] + import_stmt + '\n' + new_content[first_import:]
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print('Updated ' + os.path.relpath(filepath, lib_dir))

for root, dirs, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
