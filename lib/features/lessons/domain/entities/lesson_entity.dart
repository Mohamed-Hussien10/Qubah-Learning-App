import 'package:equatable/equatable.dart';

class LessonEntity extends Equatable {
  final String id;
  final String subjectId;
  final String name;
  final String? description;
  final String type; // video, audio, pdf, interactive, game
  final String contentUrl;
  final String? coverImageUrl;
  final int order;
  final bool isLocked;
  final double progress;

  const LessonEntity({
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

  @override
  List<Object?> get props => [
    id,
    subjectId,
    name,
    description,
    type,
    contentUrl,
    coverImageUrl,
    order,
    isLocked,
    progress,
  ];
}
