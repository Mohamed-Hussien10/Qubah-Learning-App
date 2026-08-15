import os
import re

lib_dir = r'd:\Flutter\Qubah App\qubah_learning_app\lib'
import_stmt = "import 'package:qubah_learning_app/core/widgets/hover_scale.dart';"

# Fix GestureDetector without MouseRegion parent
# Fix InkWell without mouseCursor

def fix_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    modified = False
    new_content = content

    # 1. Find GestureDetector( that are not already inside a MouseRegion
    i = 0
    while True:
        idx = new_content.find('GestureDetector(', i)
        if idx == -1:
            break
        # check 200 chars before for MouseRegion
        prefix = new_content[max(0, idx - 300):idx]
        if 'MouseRegion(' in prefix[-200:]:
            i = idx + 1
            continue
        # Check it has onTap
        # find matching closing paren
        start_paren = new_content.find('(', idx)
        paren_count = 1
        curr = start_paren + 1
        while paren_count > 0 and curr < len(new_content):
            if new_content[curr] == '(':
                paren_count += 1
            elif new_content[curr] == ')':
                paren_count -= 1
            curr += 1
        body = new_content[start_paren:curr]
        if 'onTap' not in body:
            i = idx + 1
            continue
        # wrap it
        before = new_content[:idx]
        middle = new_content[idx:curr]
        after = new_content[curr:]
        new_content = before + 'MouseRegion(\n        cursor: SystemMouseCursors.click,\n        child: ' + middle + ',\n      )' + after
        modified = True
        i = idx + len('MouseRegion(\n        cursor: SystemMouseCursors.click,\n        child: ') + (curr - idx) + len(',\n      )')

    # 2. Add mouseCursor to InkWell( that don't have it
    j = 0
    while True:
        idx = new_content.find('InkWell(', j)
        if idx == -1:
            break
        # find the matching paren
        start_paren = new_content.find('(', idx)
        paren_count = 1
        curr = start_paren + 1
        while paren_count > 0 and curr < len(new_content):
            if new_content[curr] == '(':
                paren_count += 1
            elif new_content[curr] == ')':
                paren_count -= 1
            curr += 1
        body = new_content[start_paren:curr]
        if 'onTap' in body and 'mouseCursor' not in body:
            # insert mouseCursor after onTap: ...callback...,
            # Find position right after InkWell(
            insert_pos = start_paren + 1
            # skip whitespace/newline
            while insert_pos < len(new_content) and new_content[insert_pos] in ' \t\r\n':
                insert_pos += 1
            # get indent
            line_start = new_content.rfind('\n', 0, idx) + 1
            indent = ''
            for c in new_content[line_start:idx]:
                if c in ' \t':
                    indent += c
                else:
                    break
            child_indent = indent + '  '
            new_content = (new_content[:insert_pos] +
                           '\n' + child_indent + 'mouseCursor: SystemMouseCursors.click,' +
                           new_content[insert_pos:])
            modified = True
            j = insert_pos + len('\n' + child_indent + 'mouseCursor: SystemMouseCursors.click,')
        else:
            j = idx + 1

    if modified:
        # ensure flutter/material import exists (it always does)
        if import_stmt not in new_content:
            first_import = new_content.find('import ')
            if first_import != -1:
                new_content = new_content[:first_import] + import_stmt + '\n' + new_content[first_import:]
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print('Updated: ' + os.path.relpath(filepath, lib_dir))

for root, dirs, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            fix_file(os.path.join(root, file))
