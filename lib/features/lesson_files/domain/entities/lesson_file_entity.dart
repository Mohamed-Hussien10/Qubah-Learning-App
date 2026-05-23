class LessonFileEntity {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int order;
  final int childCount;
  final String type;
  final String filePath;

  const LessonFileEntity({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.order,
    this.childCount = 0,
    required this.type,
    required this.filePath,
  });
}
