import 'package:web_dashboard/features/shared/models/base_entity.dart';

/// Model representing a lesson (درس) within a unit.
class LessonModel extends BaseEntity {
  final String unitId;
  final String? thumbnailUrl;
  final String duration;
  final bool isPublished;
  final int filesCount;

  const LessonModel({
    required super.id,
    required this.unitId,
    required super.title,
    super.description,
    this.thumbnailUrl,
    required this.duration,
    this.isPublished = true,
    super.isActive = true,
    super.order = 0,
    this.filesCount = 0,
    super.createdAt,
  });

  @override
  List<Object?> get props =>
      [...super.props, unitId, thumbnailUrl, duration, isPublished, filesCount];

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id']?.toString() ?? '',
      unitId: json['unit_id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      thumbnailUrl: json['thumbnail_url'],
      duration: json['duration']?.toString() ?? '00:00',
      isPublished: json['is_published'] == 1 || json['is_published'] == true,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      order: json['order'] != null ? int.tryParse(json['order'].toString()) ?? 0 : 0,
      filesCount: json['files_count'] != null ? int.tryParse(json['files_count'].toString()) ?? 0 : 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unit_id': unitId,
      'title': title,
      'description': description,
      'thumbnail_path': thumbnailUrl,
      'duration': duration,
      'is_published': isPublished,
      'is_active': isActive ? 1 : 0,
      'order': order,
      'files_count': filesCount,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  LessonModel copyWith({
    String? id,
    String? unitId,
    String? title,
    String? description,
    String? thumbnailUrl,
    String? duration,
    bool? isPublished,
    bool? isActive,
    int? order,
    int? filesCount,
    DateTime? createdAt,
  }) {
    return LessonModel(
      id: id ?? this.id,
      unitId: unitId ?? this.unitId,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      isPublished: isPublished ?? this.isPublished,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      filesCount: filesCount ?? this.filesCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Dummy data keyed by unitId.
  static Map<String, List<LessonModel>> get dummyMap => {
        'unit-1': [
          LessonModel(
            id: 'lesson-1',
            unitId: 'unit-1',
            title: 'الدرس الأول: مدخل إلى الأعداد الحقيقية',
            description: 'التعريف بالأعداد الحقيقية وخصائصها ومجموعات الأعداد الأخرى',
            thumbnailUrl: 'https://via.placeholder.com/150/6C5CE7/FFFFFF?text=درس-1',
            duration: '12:45',
            isPublished: true,
            isActive: true,
            order: 1,
            filesCount: 2,
            createdAt: DateTime(2025, 2, 12),
          ),
          LessonModel(
            id: 'lesson-2',
            unitId: 'unit-1',
            title: 'الدرس الثاني: المقارنة والترتيب',
            description: 'شرح كيفية ترتيب الأعداد الحقيقية والمقارنة بينها بيانيا وحسابيا',
            thumbnailUrl: 'https://via.placeholder.com/150/00D2D3/FFFFFF?text=درس-2',
            duration: '15:20',
            isPublished: true,
            isActive: true,
            order: 2,
            filesCount: 1,
            createdAt: DateTime(2025, 2, 12),
          ),
          LessonModel(
            id: 'lesson-3',
            unitId: 'unit-1',
            title: 'الدرس الثالث: القيمة المطلقة',
            description: 'دراسة مفهوم القيمة المطلقة وخصائصها وتطبيقاتها الرياضية',
            duration: '18:10',
            isPublished: false,
            isActive: true,
            order: 3,
            filesCount: 0,
            createdAt: DateTime(2025, 2, 12),
          ),
        ],
        'unit-2': [
          LessonModel(
            id: 'lesson-4',
            unitId: 'unit-2',
            title: 'الدرس الأول: جمع وطرح الحدود الجبرية',
            description: 'طريقة التعامل مع الحدود المتشابهة والمختلفة في الجمع والطرح',
            duration: '14:30',
            isPublished: true,
            isActive: true,
            order: 1,
            filesCount: 1,
            createdAt: DateTime(2025, 2, 12),
          ),
          LessonModel(
            id: 'lesson-5',
            unitId: 'unit-2',
            title: 'الدرس الثاني: ضرب وقسمة المقادير الجبرية',
            description: 'توزيع الضرب على الجمع واختصار المقادير الجبرية الكسرية',
            duration: '22:15',
            isPublished: true,
            isActive: true,
            order: 2,
            filesCount: 2,
            createdAt: DateTime(2025, 2, 12),
          ),
        ],
      };
}
