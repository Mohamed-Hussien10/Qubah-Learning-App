import 'package:equatable/equatable.dart';
import 'package:web_dashboard/features/educational_stages/data/models/stage_model.dart';

abstract class StageFileThumbnailsState extends Equatable {
  const StageFileThumbnailsState();

  @override
  List<Object?> get props => [];
}

class StageFileThumbnailsInitial extends StageFileThumbnailsState {
  const StageFileThumbnailsInitial();
}

class StageFileThumbnailsLoading extends StageFileThumbnailsState {
  const StageFileThumbnailsLoading();
}

class StageFileThumbnailsLoaded extends StageFileThumbnailsState {
  final List<StageModel> stages;
  final StageModel? selectedStage;
  final Map<String, String> thumbnails; // format -> thumbnailUrl
  final bool isUpdating;

  const StageFileThumbnailsLoaded({
    required this.stages,
    this.selectedStage,
    required this.thumbnails,
    this.isUpdating = false,
  });

  @override
  List<Object?> get props => [stages, selectedStage, thumbnails, isUpdating];

  StageFileThumbnailsLoaded copyWith({
    List<StageModel>? stages,
    StageModel? selectedStage,
    Map<String, String>? thumbnails,
    bool? isUpdating,
  }) {
    return StageFileThumbnailsLoaded(
      stages: stages ?? this.stages,
      selectedStage: selectedStage ?? this.selectedStage,
      thumbnails: thumbnails ?? this.thumbnails,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }
}

class StageFileThumbnailsError extends StageFileThumbnailsState {
  final String message;

  const StageFileThumbnailsError(this.message);

  @override
  List<Object?> get props => [message];
}
