import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dashboard/features/educational_stages/data/models/stage_model.dart';
import 'package:web_dashboard/features/educational_stages/data/repositories/stages_repository.dart';
import 'package:web_dashboard/features/educational_stages/presentation/manager/stages_state.dart';
import 'package:web_dashboard/core/errors/error_handler.dart';

/// Cubit that manages the stages list, CRUD, search & filtering.
class StagesCubit extends Cubit<StagesState> {
  final StagesRepository _repository;

  StagesCubit({required StagesRepository repository})
      : _repository = repository,
        super(const StagesInitial());

  // ── Load ──────────────────────────────────────────────────────────────

  Future<void> loadStages() async {
    emit(const StagesLoading());
    try {
      final stages = await _repository.getAll();
      emit(StagesLoaded(stages: stages, filteredStages: stages));
    } catch (e) {
      emit(StagesError(ErrorHandler.handle(e)));
    }
  }

  // ── Create ────────────────────────────────────────────────────────────

  Future<void> createStage(StageModel stage, {List<int>? imageBytes, String? imageName, List<int>? bgImageBytes, String? bgImageName}) async {
    try {
      await _repository.create(stage, imageBytes: imageBytes, imageName: imageName, bgImageBytes: bgImageBytes, bgImageName: bgImageName);
      await loadStages();
    } catch (e) {
      emit(StagesError(ErrorHandler.handle(e)));
    }
  }

  // ── Update ────────────────────────────────────────────────────────────

  Future<void> updateStage(StageModel stage, {List<int>? imageBytes, String? imageName, List<int>? bgImageBytes, String? bgImageName}) async {
    try {
      await _repository.update(stage, imageBytes: imageBytes, imageName: imageName, bgImageBytes: bgImageBytes, bgImageName: bgImageName);
      await loadStages();
    } catch (e) {
      emit(StagesError(ErrorHandler.handle(e)));
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────

  Future<void> deleteStage(String id) async {
    try {
      await _repository.delete(id);
      await loadStages();
    } catch (e) {
      emit(StagesError(ErrorHandler.handle(e)));
    }
  }

  // ── Toggle Status ─────────────────────────────────────────────────────

  Future<void> toggleStatus(String id) async {
    try {
      await _repository.toggleStatus(id);
      await loadStages();
    } catch (e) {
      emit(StagesError(ErrorHandler.handle(e)));
    }
  }

  // ── Reorder ───────────────────────────────────────────────────────────

  Future<void> reorder(List<String> orderedIds) async {
    try {
      await _repository.reorder(orderedIds);
      await loadStages();
    } catch (e) {
      emit(StagesError(ErrorHandler.handle(e)));
    }
  }

  // ── Search / Filter ──────────────────────────────────────────────────

  void search(String query) {
    final currentState = state;
    if (currentState is StagesLoaded) {
      if (query.isEmpty) {
        emit(currentState.copyWith(
          filteredStages: currentState.stages,
          searchQuery: '',
        ));
      } else {
        final filtered = currentState.stages.where((stage) {
          final lowerQuery = query.toLowerCase();
          return stage.title.toLowerCase().contains(lowerQuery) ||
              (stage.description?.toLowerCase().contains(lowerQuery) ?? false);
        }).toList();
        emit(currentState.copyWith(
          filteredStages: filtered,
          searchQuery: query,
        ));
      }
    }
  }
}
