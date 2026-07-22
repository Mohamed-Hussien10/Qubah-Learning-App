import 'package:equatable/equatable.dart';

/// Model representing a Subscription Package in the platform.
class PackageModel extends Equatable {
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
      educationalStageId: json['educational_stage_id']?.toString() ?? '',
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
      educationalStageTitle: getRelationTitle(json['educational_stage']),
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
      'expiry_date': expiryDate != null
          ? "${expiryDate!.year.toString().padLeft(4, '0')}-${expiryDate!.month.toString().padLeft(2, '0')}-${expiryDate!.day.toString().padLeft(2, '0')}"
          : null,
      'is_active': isActive ? 1 : 0,
    };
  }

  /// Returns readable hierarchical scope string.
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

    if (parts.isEmpty) return 'غير محدد';
    return parts.join(' ➔ ');
  }

  /// Label indicating at what level the package stops.
  String get scopeLevelLabel {
    if (subjectId != null && subjectId!.isNotEmpty) return 'مادة محددة';
    if (sectionId != null && sectionId!.isNotEmpty) return 'فصل محدد';
    if (gradeId != null && gradeId!.isNotEmpty) return 'صف محدد';
    return 'مرحلة كاملة';
  }

  PackageModel copyWith({
    String? id,
    String? name,
    double? price,
    String? educationalStageId,
    String? gradeId,
    String? sectionId,
    String? subjectId,
    String? description,
    DateTime? expiryDate,
    bool? isActive,
    DateTime? createdAt,
    String? educationalStageTitle,
    String? gradeTitle,
    String? sectionTitle,
    String? subjectTitle,
  }) {
    return PackageModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      educationalStageId: educationalStageId ?? this.educationalStageId,
      gradeId: gradeId ?? this.gradeId,
      sectionId: sectionId ?? this.sectionId,
      subjectId: subjectId ?? this.subjectId,
      description: description ?? this.description,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      educationalStageTitle:
          educationalStageTitle ?? this.educationalStageTitle,
      gradeTitle: gradeTitle ?? this.gradeTitle,
      sectionTitle: sectionTitle ?? this.sectionTitle,
      subjectTitle: subjectTitle ?? this.subjectTitle,
    );
  }
}
