import '../../domain/entities/lesson_file_entity.dart';

class LessonFileModel {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int order;
  final int childCount;
  final String type;
  final String filePath;

  const LessonFileModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.order,
    this.childCount = 0,
    required this.type,
    required this.filePath,
  });

  factory LessonFileModel.fromJson(Map<String, dynamic> json) =>
      LessonFileModel(
        id: json['id'].toString(),
        name: json['title'] ?? '',
        description: json['description'] as String?,
        imageUrl: json['thumbnail_url'] as String?,
        order: json['order'] as int? ?? 0,
        childCount: 0,
        type: json['type'] ?? 'unknown',
        filePath: json['file_path'] ?? '',
      );

  LessonFileEntity toEntity() => LessonFileEntity(
    id: id,
    name: name,
    description: description,
    imageUrl: imageUrl,
    order: order,
    childCount: childCount,
    type: type,
    filePath: filePath,
  );
}
