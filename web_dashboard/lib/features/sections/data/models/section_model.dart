import 'package:web_dashboard/features/shared/models/base_entity.dart';

/// Model representing a section (قسم) within a grade.
class SectionModel extends BaseEntity {
  final String gradeId;
  final int subjectsCount;

  const SectionModel({
    required super.id,
    required this.gradeId,
    required super.title,
    super.description,
    super.isActive = true,
    super.order = 0,
    this.subjectsCount = 0,
    super.createdAt,
  });

  @override
  List<Object?> get props => [...super.props, gradeId, subjectsCount];

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: json['id']?.toString() ?? '',
      gradeId: json['grade_id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      order: json['order'] ?? 0,
      subjectsCount: json['subjects_count'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'grade_id': gradeId,
      'title': title,
      'description': description,
      'is_active': isActive,
      'order': order,
      'subjects_count': subjectsCount,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  SectionModel copyWith({
    String? id,
    String? gradeId,
    String? title,
    String? description,
    bool? isActive,
    int? order,
    int? subjectsCount,
    DateTime? createdAt,
  }) {
    return SectionModel(
      id: id ?? this.id,
      gradeId: gradeId ?? this.gradeId,
      title: title ?? this.title,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      subjectsCount: subjectsCount ?? this.subjectsCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Dummy data keyed by gradeId.
  static Map<String, List<SectionModel>> get dummyMap => {
        'grade-1': [
          SectionModel(id: 'section-1', gradeId: 'grade-1', title: 'القسم العلمي', description: 'يشمل المواد العلمية والرياضيات', order: 1, subjectsCount: 4, createdAt: DateTime(2025, 2, 1)),
          SectionModel(id: 'section-2', gradeId: 'grade-1', title: 'القسم الأدبي', description: 'يشمل المواد الأدبية واللغات', order: 2, subjectsCount: 3, createdAt: DateTime(2025, 2, 1)),
        ],
        'grade-7': [
          SectionModel(id: 'section-3', gradeId: 'grade-7', title: 'القسم العلمي', description: 'يشمل المواد العلمية', order: 1, subjectsCount: 5, createdAt: DateTime(2025, 3, 1)),
          SectionModel(id: 'section-4', gradeId: 'grade-7', title: 'القسم الأدبي', description: 'يشمل المواد الأدبية', order: 2, subjectsCount: 4, createdAt: DateTime(2025, 3, 1)),
        ],
        'grade-10': [
          SectionModel(id: 'section-5', gradeId: 'grade-10', title: 'القسم العلمي', description: 'يشمل الفيزياء والكيمياء والأحياء', order: 1, subjectsCount: 6, createdAt: DateTime(2025, 4, 1)),
          SectionModel(id: 'section-6', gradeId: 'grade-10', title: 'القسم الأدبي', description: 'يشمل التاريخ والجغرافيا والفلسفة', order: 2, subjectsCount: 5, createdAt: DateTime(2025, 4, 1)),
        ],
      };
}
