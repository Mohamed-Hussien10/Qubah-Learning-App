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

  // Multi-subset fields
  final bool isAllStages;
  final List<String> stageIds;
  final bool isAllGrades;
  final List<String> gradeIds;
  final bool isAllSections;
  final List<String> sectionIds;
  final bool isAllSubjects;
  final List<String> subjectIds;

  final List<String> stageTitles;
  final List<String> gradeTitles;
  final List<String> sectionTitles;
  final List<String> subjectTitles;

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
    this.isAllStages = false,
    this.stageIds = const [],
    this.isAllGrades = false,
    this.gradeIds = const [],
    this.isAllSections = false,
    this.sectionIds = const [],
    this.isAllSubjects = false,
    this.subjectIds = const [],
    this.stageTitles = const [],
    this.gradeTitles = const [],
    this.sectionTitles = const [],
    this.subjectTitles = const [],
  });

  /// Returns readable scope text (e.g., "المرحلة المتوسطة ➔ الصف الأول ➔ الرياضيات").
  String get scopeText {
    if (isAllStages) return 'كل المراحل التعليمية';

    final List<String> parts = [];

    if (stageTitles.isNotEmpty) {
      parts.add(stageTitles.toSet().join(' + '));
    } else if (stageIds.isNotEmpty) {
      parts.add('${stageIds.length} مرحلة');
    } else if (educationalStageTitle != null && educationalStageTitle!.isNotEmpty) {
      parts.add(educationalStageTitle!);
    }

    if (isAllGrades) {
      parts.add('كل الصفوف');
    } else if (gradeTitles.isNotEmpty) {
      parts.add(gradeTitles.toSet().join(' + '));
    } else if (gradeIds.isNotEmpty) {
      parts.add('${gradeIds.length} صفوف');
    } else if (gradeTitle != null && gradeTitle!.isNotEmpty) {
      parts.add(gradeTitle!);
    }

    if (isAllSections) {
      parts.add('كل الفصول');
    } else if (sectionTitles.isNotEmpty) {
      parts.add(sectionTitles.toSet().join(' + '));
    } else if (sectionIds.isNotEmpty) {
      parts.add('${sectionIds.length} فصول');
    } else if (sectionTitle != null && sectionTitle!.isNotEmpty) {
      parts.add(sectionTitle!);
    }

    if (isAllSubjects) {
      parts.add('كل المواد');
    } else if (subjectTitles.isNotEmpty) {
      parts.add(subjectTitles.toSet().join(' + '));
    } else if (subjectIds.isNotEmpty) {
      parts.add('${subjectIds.length} مواد');
    } else if (subjectTitle != null && subjectTitle!.isNotEmpty) {
      parts.add(subjectTitle!);
    }

    if (parts.isEmpty) return 'شامل';
    return parts.join(' ➔ ');
  }

  /// Label indicating the scope specificity of the package.
  String get scopeLevelLabel {
    if (isAllStages) return 'شامل كل المراحل';
    if (!isAllSubjects && (subjectIds.isNotEmpty || (subjectId != null && subjectId!.isNotEmpty))) return 'مواد محددة';
    if (!isAllSections && (sectionIds.isNotEmpty || (sectionId != null && sectionId!.isNotEmpty))) return 'فصول محددة';
    if (!isAllGrades && (gradeIds.isNotEmpty || (gradeId != null && gradeId!.isNotEmpty))) return 'صفوف محددة';
    return 'مراحل محددة';
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
        isAllStages,
        stageIds,
        isAllGrades,
        gradeIds,
        isAllSections,
        sectionIds,
        isAllSubjects,
        subjectIds,
        stageTitles,
        gradeTitles,
        sectionTitles,
        subjectTitles,
      ];
}
