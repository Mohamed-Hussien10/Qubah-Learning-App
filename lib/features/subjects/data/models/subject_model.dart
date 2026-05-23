import '../../domain/entities/subject_entity.dart';

class SubjectModel {
  final String id;
  final String stageId;
  final String name;
  final String? description;
  final String? imageUrl;
  final int order;
  final int lessonCount;

  const SubjectModel({
    required this.id,
    required this.stageId,
    required this.name,
    this.description,
    this.imageUrl,
    required this.order,
    this.lessonCount = 0,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) => SubjectModel(
    id: json['id'].toString(),
    stageId: json['subject_id']?.toString() ?? '',
    name: json['title'] ?? json['name'] ?? '',
    description: json['description'] as String?,
    imageUrl: json['thumbnail_url'] ?? json['image_url'] as String?,
    order: json['order'] as int? ?? 0,
    lessonCount: json['contents_count'] ?? json['lesson_count'] as int? ?? 0,
  );

  SubjectEntity toEntity() => SubjectEntity(
    id: id,
    stageId: stageId,
    name: name,
    description: description,
    imageUrl: imageUrl,
    order: order,
    lessonCount: lessonCount,
  );
}
