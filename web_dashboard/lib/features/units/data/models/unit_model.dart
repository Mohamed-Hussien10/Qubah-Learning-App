import 'package:web_dashboard/features/shared/models/base_entity.dart';

/// Model representing an educational unit (وحدة) within a subject.
class UnitModel extends BaseEntity {
  final String subjectId;
  final int lessonsCount;
  final String? thumbnailUrl;

  const UnitModel({
    required super.id,
    required this.subjectId,
    required super.title,
    super.description,
    this.thumbnailUrl,
    super.isActive = true,
    super.order = 0,
    this.lessonsCount = 0,
    super.createdAt,
  });

  @override
  List<Object?> get props => [...super.props, subjectId, lessonsCount, thumbnailUrl];

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id']?.toString() ?? '',
      subjectId: json['subject_id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      thumbnailUrl: json['thumbnail_url'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      order: json['order'] != null ? int.tryParse(json['order'].toString()) ?? 0 : 0,
      lessonsCount: json['lessons_count'] != null ? int.tryParse(json['lessons_count'].toString()) ?? 0 : 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject_id': subjectId,
      'title': title,
      'description': description,
      'thumbnail_path': thumbnailUrl,
      'is_active': isActive ? 1 : 0,
      'order': order,
      'lessons_count': lessonsCount,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  UnitModel copyWith({
    String? id,
    String? subjectId,
    String? title,
    String? description,
    String? thumbnailUrl,
    bool? isActive,
    int? order,
    int? lessonsCount,
    DateTime? createdAt,
  }) {
    return UnitModel(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      lessonsCount: lessonsCount ?? this.lessonsCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Dummy data keyed by subjectId.
  static Map<String, List<UnitModel>> get dummyMap => {
        'subject-1': [
          UnitModel(
            id: 'unit-1',
            subjectId: 'subject-1',
            title: 'الوحدة الأولى: الأعداد الحقيقية',
            description: 'دراسة الأعداد الطبيعية والصحيحة والحقيقية والمقارنة بينها',
            isActive: true,
            order: 1,
            lessonsCount: 3,
            createdAt: DateTime(2025, 2, 10),
          ),
          UnitModel(
            id: 'unit-2',
            subjectId: 'subject-1',
            title: 'الوحدة الثانية: العمليات الحسابية والجبر',
            description: 'دراسة الجمع والطرح والضرب والقسمة الجبرية والمجاهيل',
            isActive: true,
            order: 2,
            lessonsCount: 4,
            createdAt: DateTime(2025, 2, 10),
          ),
        ],
        'subject-2': [
          UnitModel(
            id: 'unit-3',
            subjectId: 'subject-2',
            title: 'الوحدة الأولى: الكائنات الحية والبيئة',
            description: 'دراسة الخلايا والتركيب الحيوي والأنظمة البيئية المختلفة',
            isActive: true,
            order: 1,
            lessonsCount: 3,
            createdAt: DateTime(2025, 2, 10),
          ),
          UnitModel(
            id: 'unit-4',
            subjectId: 'subject-2',
            title: 'الوحدة الثانية: المادة والطاقة',
            description: 'تحولات المادة وأنواع الطاقة وقوانين حفظ الطاقة والحرارة',
            isActive: true,
            order: 2,
            lessonsCount: 3,
            createdAt: DateTime(2025, 2, 10),
          ),
        ],
      };
}