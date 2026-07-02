import os

def replace_in_file(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            
        if 'https://qubahom.com' in content:
            new_content = content.replace('https://qubahom.com', 'http://127.0.0.1:8000')
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Updated {filepath}")
    except Exception as e:
        print(f"Error reading {filepath}: {e}")

def main():
    dirs_to_check = ['lib', 'web_dashboard/lib']
    for directory in dirs_to_check:
        for root, dirs, files in os.walk(directory):
            for file in files:
                if file.endswith('.dart'):
                    replace_in_file(os.path.join(root, file))

if __name__ == '__main__':
    main()
