import 'package:web_dashboard/features/shared/models/base_entity.dart';

/// Model representing a file (ملف) attached to a lesson.
class LessonFileModel extends BaseEntity {
  final String lessonId;
  final String type; // video, audio, pdf, image, scorm, html5
  final String fileUrl;
  final String fileSize;

  const LessonFileModel({
    required super.id,
    required this.lessonId,
    required super.title,
    required this.type,
    required this.fileUrl,
    required this.fileSize,
    super.isActive = true,
    super.order = 0,
    super.createdAt,
  });

  @override
  List<Object?> get props =>
      [...super.props, lessonId, type, fileUrl, fileSize];

  factory LessonFileModel.fromJson(Map<String, dynamic> json) {
    return LessonFileModel(
      id: json['id']?.toString() ?? '',
      lessonId: json['lesson_id']?.toString() ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? 'pdf',
      fileUrl: json['file_url'] ?? '',
      fileSize: json['file_size'] ?? '0 KB',
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      order: json['order'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'title': title,
      'type': type,
      'file_url': fileUrl,
      'file_size': fileSize,
      'is_active': isActive,
      'order': order,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  LessonFileModel copyWith({
    String? id,
    String? lessonId,
    String? title,
    String? description,
    String? type,
    String? fileUrl,
    String? fileSize,
    bool? isActive,
    int? order,
    DateTime? createdAt,
  }) {
    return LessonFileModel(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      title: title ?? this.title,
      type: type ?? this.type,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSize: fileSize ?? this.fileSize,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Dummy data keyed by lessonId.
  static Map<String, List<LessonFileModel>> get dummyMap => {
        'lesson-1': [
          LessonFileModel(
            id: 'file-1',
            lessonId: 'lesson-1',
            title: 'فيديو الشرح الأساسي',
            type: 'video',
            fileUrl: 'https://www.w3schools.com/html/mov_bbb.mp4',
            fileSize: '45.2 MB',
            order: 1,
            createdAt: DateTime(2025, 2, 14),
          ),
          LessonFileModel(
            id: 'file-2',
            lessonId: 'lesson-1',
            title: 'كراسة الأنشطة - الأعداد الحقيقية',
            type: 'pdf',
            fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
            fileSize: '2.4 MB',
            order: 2,
            createdAt: DateTime(2025, 2, 14),
          ),
        ],
        'lesson-2': [
          LessonFileModel(
            id: 'file-3',
            lessonId: 'lesson-2',
            title: 'ورقة عمل - المقارنة والترتيب',
            type: 'pdf',
            fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
            fileSize: '1.8 MB',
            order: 1,
            createdAt: DateTime(2025, 2, 14),
          ),
        ],
        'lesson-4': [
          LessonFileModel(
            id: 'file-4',
            lessonId: 'lesson-4',
            title: 'فيديو تعليمي - الجمع والطرح الجبري',
            type: 'video',
            fileUrl: 'https://www.w3schools.com/html/mov_bbb.mp4',
            fileSize: '32.1 MB',
            order: 1,
            createdAt: DateTime(2025, 2, 14),
          ),
        ],
        'lesson-5': [
          LessonFileModel(
            id: 'file-5',
            lessonId: 'lesson-5',
            title: 'أوراق العمل والتمارين المتطورة',
            type: 'pdf',
            fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
            fileSize: '3.5 MB',
            order: 1,
            createdAt: DateTime(2025, 2, 14),
          ),
          LessonFileModel(
            id: 'file-6',
            lessonId: 'lesson-5',
            title: 'عرض تقديمي توضيحي - HTML5',
            type: 'html5',
            fileUrl: 'https://qubah.com/files/lessons/5/presentation/index.html',
            fileSize: '12.4 MB',
            order: 2,
            createdAt: DateTime(2025, 2, 14),
          ),
        ],
      };
}
