import '../../domain/entities/package_entity.dart';

/// Data model for Package JSON serialization and deserialization.
class PackageModel {
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
  final String? educationalStageTitle;
  final String? gradeTitle;
  final String? sectionTitle;
  final String? subjectTitle;

  const PackageModel({
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

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    String? getRelationTitle(dynamic rel) {
      if (rel == null) return null;
      if (rel is Map<String, dynamic>) {
        return rel['title']?.toString() ?? rel['name']?.toString();
      }
      return null;
    }

    return PackageModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      educationalStageId: json['educational_stage_id']?.toString() ??
          json['stage_id']?.toString() ??
          '',
      gradeId: json['grade_id']?.toString(),
      sectionId: json['section_id']?.toString(),
      subjectId: json['subject_id']?.toString(),
      description: json['description']?.toString(),
      expiryDate: json['expiry_date'] != null
          ? DateTime.tryParse(json['expiry_date'].toString())
          : null,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      educationalStageTitle: getRelationTitle(json['educational_stage'] ?? json['stage']),
      gradeTitle: getRelationTitle(json['grade']),
      sectionTitle: getRelationTitle(json['section']),
      subjectTitle: getRelationTitle(json['subject']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'educational_stage_id': educationalStageId,
      'grade_id': gradeId,
      'section_id': sectionId,
      'subject_id': subjectId,
      'description': description,
      'expiry_date': expiryDate?.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'educational_stage_title': educationalStageTitle,
      'grade_title': gradeTitle,
      'section_title': sectionTitle,
      'subject_title': subjectTitle,
    };
  }

  PackageEntity toEntity() {
    return PackageEntity(
      id: id,
      name: name,
      price: price,
      educationalStageId: educationalStageId,
      gradeId: gradeId,
      sectionId: sectionId,
      subjectId: subjectId,
      description: description,
      expiryDate: expiryDate,
      isActive: isActive,
      createdAt: createdAt,
      educationalStageTitle: educationalStageTitle,
      gradeTitle: gradeTitle,
      sectionTitle: sectionTitle,
      subjectTitle: subjectTitle,
    );
  }

  factory PackageModel.fromEntity(PackageEntity entity) {
    return PackageModel(
      id: entity.id,
      name: entity.name,
      price: entity.price,
      educationalStageId: entity.educationalStageId,
      gradeId: entity.gradeId,
      sectionId: entity.sectionId,
      subjectId: entity.subjectId,
      description: entity.description,
      expiryDate: entity.expiryDate,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      educationalStageTitle: entity.educationalStageTitle,
      gradeTitle: entity.gradeTitle,
      sectionTitle: entity.sectionTitle,
      subjectTitle: entity.subjectTitle,
    );
  }
}
