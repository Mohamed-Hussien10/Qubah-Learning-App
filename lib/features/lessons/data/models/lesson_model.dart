import '../../domain/entities/lesson_entity.dart';

class LessonModel {
  final String id;
  final String subjectId;
  final String name;
  final String? description;
  final String type;
  final String contentUrl;
  final String? coverImageUrl;
  final int order;
  final bool isLocked;
  final double progress;

  const LessonModel({
    required this.id,
    required this.subjectId,
    required this.name,
    this.description,
    required this.type,
    required this.contentUrl,
    this.coverImageUrl,
    required this.order,
    this.isLocked = false,
    this.progress = 0.0,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) => LessonModel(
    id: json['id'].toString(),
    subjectId: json['topic_id']?.toString() ?? '',
    name: json['title'] ?? json['name'] ?? '',
    description: json['description'] as String?,
    type: json['type'] as String? ?? 'video',
    contentUrl: json['url'] ?? json['file_path'] ?? json['content_url'] ?? '',
    coverImageUrl: json['thumbnail_url'] ?? json['cover_image_url'] as String?,
    order: json['order'] as int? ?? 0,
    isLocked: json['is_locked'] as bool? ?? false,
    progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
  );

  LessonEntity toEntity() => LessonEntity(
    id: id,
    subjectId: subjectId,
    name: name,
    description: description,
    type: type,
    contentUrl: contentUrl,
    coverImageUrl: coverImageUrl,
    order: order,
    isLocked: isLocked,
    progress: progress,
  );
}
