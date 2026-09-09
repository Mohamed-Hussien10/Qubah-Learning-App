import os
import glob

files = glob.glob('lib/**/*.dart', recursive=True)
count = 0
for f in files:
    with open(f, 'r', encoding='utf-8') as file:
        content = file.read()
    
    if "context.go('/login')" in content:
        if "app_router.dart" in f:
            continue
        new_content = content.replace("context.go('/login')", "context.go('/force-logout')")
        with open(f, 'w', encoding='utf-8') as file:
            file.write(new_content)
        count += 1
        print(f'Updated {f}')

print(f'Total files updated: {count}')
