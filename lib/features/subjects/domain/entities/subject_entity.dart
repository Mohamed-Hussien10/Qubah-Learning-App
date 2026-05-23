import 'package:equatable/equatable.dart';

class SubjectEntity extends Equatable {
  final String id;
  final String stageId;
  final String name;
  final String? description;
  final String? imageUrl;
  final int order;
  final int lessonCount;

  const SubjectEntity({
    required this.id,
    required this.stageId,
    required this.name,
    this.description,
    this.imageUrl,
    required this.order,
    this.lessonCount = 0,
  });

  @override
  List<Object?> get props => [
    id,
    stageId,
    name,
    description,
    imageUrl,
    order,
    lessonCount,
  ];
}
