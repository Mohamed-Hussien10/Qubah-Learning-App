class SectionEntity {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int order;
  final int childCount;

  const SectionEntity({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.order,
    this.childCount = 0,
  });
}
