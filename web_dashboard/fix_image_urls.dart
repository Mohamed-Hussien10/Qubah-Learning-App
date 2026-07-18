import 'dart:io';

void main() {
  final screens = [
    'features/educational_stages/presentation/screens/stages_screen.dart',
    'features/grades/presentation/screens/grades_screen.dart',
    'features/sections/presentation/screens/sections_screen.dart',
    'features/subjects/presentation/screens/subjects_screen.dart',
    'features/units/presentation/screens/units_screen.dart',
    'features/lessons/presentation/screens/lessons_screen.dart',
    'features/lesson_files/presentation/screens/lesson_files_screen.dart',
    'features/free_trial/presentation/screens/free_trial_stages_screen.dart',
    'features/free_trial/presentation/screens/free_trial_grades_screen.dart',
    'features/free_trial_subjects/presentation/screens/free_trial_subjects_screen.dart',
    'features/free_trial_lesson_files/presentation/screens/free_trial_lesson_files_screen.dart',
  ];

  final regex1 = RegExp(r'  String resolveImageUrl\(String path\) \{[\s\S]*?  \}');
  final regex2 = RegExp(r'String resolveImageUrl\(String path\) \{[\s\S]*?^\}', multiLine: true);

  for (var file in screens) {
    final f = File('lib/$file');
    if (!f.existsSync()) {
      print('Not found: $file');
      continue;
    }
    
    var content = f.readAsStringSync();
    
    // Add import if missing
    if (!content.contains('core/constants/api_endpoints.dart')) {
        content = content.replaceFirst("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:web_dashboard/core/constants/api_endpoints.dart';");
    }
    
    // Check if it's an indented function (like in stages_screen) or top-level function
    final newFunc1 = '''  String resolveImageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.contains('thumbnails/')) {
      final fileName = path.split('thumbnails/').last;
      return '\${ApiEndpoints.domainUrl}/api/v1/thumbnails/' + fileName;
    }
    if (path.startsWith('http')) return path;
    final baseUrl = ApiEndpoints.domainUrl;
    if (path.startsWith('/')) return '\$baseUrl\$path';
    if (path.startsWith('storage/')) return '\$baseUrl/\$path';
    return '\$baseUrl/storage/\$path';
  }''';

    final newFunc2 = '''String resolveImageUrl(String path) {
  if (path.isEmpty) return '';
  if (path.contains('thumbnails/')) {
    final fileName = path.split('thumbnails/').last;
    return '\${ApiEndpoints.domainUrl}/api/v1/thumbnails/' + fileName;
  }
  if (path.startsWith('http')) return path;
  final baseUrl = ApiEndpoints.domainUrl;
  if (path.startsWith('/')) return '\$baseUrl\$path';
  if (path.startsWith('storage/')) return '\$baseUrl/\$path';
  return '\$baseUrl/storage/\$path';
}''';

    if (regex1.hasMatch(content)) {
      content = content.replaceFirst(regex1, newFunc1);
    } else if (regex2.hasMatch(content)) {
      content = content.replaceFirst(regex2, newFunc2);
    } else {
      print('Failed to match resolveImageUrl in: $file');
      continue;
    }

    f.writeAsStringSync(content);
    print('Updated: $file');
  }
}
