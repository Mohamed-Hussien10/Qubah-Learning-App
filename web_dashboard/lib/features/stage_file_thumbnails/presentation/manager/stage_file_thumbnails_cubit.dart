import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dashboard/features/educational_stages/data/models/stage_model.dart';
import 'package:web_dashboard/features/educational_stages/data/repositories/stages_repository.dart';
import 'package:web_dashboard/features/stage_file_thumbnails/data/repositories/stage_file_thumbnails_repository.dart';
import 'package:web_dashboard/features/stage_file_thumbnails/presentation/manager/stage_file_thumbnails_state.dart';

class StageFileThumbnailsCubit extends Cubit<StageFileThumbnailsState> {
  final StagesRepository _stagesRepository;
  final StageFileThumbnailsRepository _thumbnailsRepository;

  StageFileThumbnailsCubit({
    required StagesRepository stagesRepository,
    required StageFileThumbnailsRepository thumbnailsRepository,
  })  : _stagesRepository = stagesRepository,
        _thumbnailsRepository = thumbnailsRepository,
        super(const StageFileThumbnailsInitial());

  Future<void> loadData() async {
    emit(const StageFileThumbnailsLoading());
    try {
      var stages = await _stagesRepository.getAll();
      if (stages.isEmpty) {
        stages = StageModel.dummyList;
      }

      final selectedStage = stages.isNotEmpty ? stages.first : null;
      Map<String, String> thumbnails = {};

      if (selectedStage != null) {
        thumbnails = await _thumbnailsRepository.getThumbnailsForStage(selectedStage.id);
      }

      emit(StageFileThumbnailsLoaded(
        stages: stages,
        selectedStage: selectedStage,
        thumbnails: thumbnails,
      ));
    } catch (e) {
      emit(StageFileThumbnailsLoaded(
        stages: StageModel.dummyList,
        selectedStage: StageModel.dummyList.first,
        thumbnails: const {},
      ));
    }
  }

  Future<void> selectStage(StageModel stage) async {
    final currentState = state;
    if (currentState is StageFileThumbnailsLoaded) {
      emit(currentState.copyWith(isUpdating: true, selectedStage: stage));
      try {
        final thumbnails = await _thumbnailsRepository.getThumbnailsForStage(stage.id);
        emit(currentState.copyWith(
          selectedStage: stage,
          thumbnails: thumbnails,
          isUpdating: false,
        ));
      } catch (e) {
        emit(currentState.copyWith(isUpdating: false));
      }
    }
  }

  Future<bool> uploadFormatThumbnail({
    required String format,
    required List<int> imageBytes,
    required String fileName,
  }) async {
    final currentState = state;
    if (currentState is StageFileThumbnailsLoaded && currentState.selectedStage != null) {
      emit(currentState.copyWith(isUpdating: true));
      try {
        final path = await _thumbnailsRepository.saveThumbnail(
          stageId: currentState.selectedStage!.id,
          format: format,
          imageBytes: imageBytes,
          fileName: fileName,
        );

        final updatedThumbnails = Map<String, String>.from(currentState.thumbnails);
        updatedThumbnails[format] = path;

        emit(currentState.copyWith(
          thumbnails: updatedThumbnails,
          isUpdating: false,
        ));
        return true;
      } catch (e) {
        emit(currentState.copyWith(isUpdating: false));
        return false;
      }
    }
    return false;
  }

  Future<bool> removeFormatThumbnail(String format) async {
    final currentState = state;
    if (currentState is StageFileThumbnailsLoaded && currentState.selectedStage != null) {
      emit(currentState.copyWith(isUpdating: true));
      try {
        await _thumbnailsRepository.removeThumbnail(
          stageId: currentState.selectedStage!.id,
          format: format,
        );

        final updatedThumbnails = Map<String, String>.from(currentState.thumbnails);
        updatedThumbnails.remove(format);

        emit(currentState.copyWith(
          thumbnails: updatedThumbnails,
          isUpdating: false,
        ));
        return true;
      } catch (e) {
        emit(currentState.copyWith(isUpdating: false));
        return false;
      }
    }
    return false;
  }
}
