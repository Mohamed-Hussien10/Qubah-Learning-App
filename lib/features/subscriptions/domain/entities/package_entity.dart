import 'package:equatable/equatable.dart';

/// Pure Dart entity representing a Subscription Package in the mobile app domain layer.
class PackageEntity extends Equatable {
  final String id;
  final String name;
  final double price;
  final String educationalStageId;
  final String? gradeId;
  final String? sectionId;
  final String? subjectId;
  final String? description;
  final DateTime? expiryDate;
  final bool isActive;
  final DateTime? createdAt;

  // Eager loaded title helpers
  final String? educationalStageTitle;
  final String? gradeTitle;
  final String? sectionTitle;
  final String? subjectTitle;

  const PackageEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.educationalStageId,
    this.gradeId,
    this.sectionId,
    this.subjectId,
    this.description,
    this.expiryDate,
    this.isActive = true,
    this.createdAt,
    this.educationalStageTitle,
    this.gradeTitle,
    this.sectionTitle,
    this.subjectTitle,
  });

  /// Returns readable scope text (e.g., "المرحلة المتوسطة ➔ الصف الأول ➔ الرياضيات").
  String get scopeText {
    final List<String> parts = [];
    if (educationalStageTitle != null && educationalStageTitle!.isNotEmpty) {
      parts.add(educationalStageTitle!);
    }
    if (gradeTitle != null && gradeTitle!.isNotEmpty) {
      parts.add(gradeTitle!);
    }
    if (sectionTitle != null && sectionTitle!.isNotEmpty) {
      parts.add(sectionTitle!);
    }
    if (subjectTitle != null && subjectTitle!.isNotEmpty) {
      parts.add(subjectTitle!);
    }

    if (parts.isEmpty) return 'شامل';
    return parts.join(' ➔ ');
  }

  /// Label indicating the scope specificity of the package.
  String get scopeLevelLabel {
    if (subjectId != null && subjectId!.isNotEmpty) return 'مادة محددة';
    if (sectionId != null && sectionId!.isNotEmpty) return 'فصل محدد';
    if (gradeId != null && gradeId!.isNotEmpty) return 'صف محدد';
    return 'مرحلة كاملة';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        price,
        educationalStageId,
        gradeId,
        sectionId,
        subjectId,
        description,
        expiryDate,
        isActive,
        createdAt,
        educationalStageTitle,
        gradeTitle,
        sectionTitle,
        subjectTitle,
      ];
}
