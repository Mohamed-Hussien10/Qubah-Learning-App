import os

def update_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    modified = False
    
    # Replacement rules
    replacements = [
        ('http://127.0.0.1:8000', 'https://qubahom.com'),
        ('http://localhost:8000', 'https://qubahom.com'),
        ("static const String baseUrl = 'http://127.0.0.1:8000/api/v1';", "static String get domainUrl => 'https://qubahom.com';\n  static String get baseUrl => '$domainUrl/api/v1';"),
        ("static const String storageUrl = 'http://127.0.0.1:8000/storage';", "static String get storageUrl => '$domainUrl/storage';"),
    ]
    
    for old_str, new_str in replacements:
        if old_str in content:
            content = content.replace(old_str, new_str)
            modified = True
            
    if modified:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated: {filepath}")

def main():
    dirs = ['lib', 'web_dashboard/lib']
    for d in dirs:
        for root, _, files in os.walk(d):
            for file in files:
                if file.endswith('.dart'):
                    update_file(os.path.join(root, file))

if __name__ == '__main__':
    main()
