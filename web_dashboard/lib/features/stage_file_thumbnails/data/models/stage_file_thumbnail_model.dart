import 'package:equatable/equatable.dart';

/// Represents a default file format thumbnail for a specific educational stage.
class StageFileThumbnailModel extends Equatable {
  final String stageId;
  final String format;
  final String thumbnailUrl;

  const StageFileThumbnailModel({
    required this.stageId,
    required this.format,
    required this.thumbnailUrl,
  });

  @override
  List<Object?> get props => [stageId, format, thumbnailUrl];

  factory StageFileThumbnailModel.fromJson(Map<String, dynamic> json) {
    return StageFileThumbnailModel(
      stageId: json['stage_id']?.toString() ?? '',
      format: json['format']?.toString() ?? '',
      thumbnailUrl: json['thumbnail_url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stage_id': stageId,
      'format': format,
      'thumbnail_url': thumbnailUrl,
    };
  }

  StageFileThumbnailModel copyWith({
    String? stageId,
    String? format,
    String? thumbnailUrl,
  }) {
    return StageFileThumbnailModel(
      stageId: stageId ?? this.stageId,
      format: format ?? this.format,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }
}
