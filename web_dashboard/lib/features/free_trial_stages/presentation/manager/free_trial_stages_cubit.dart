import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dashboard/features/free_trial_stages/data/models/free_trial_stage_model.dart';
import 'package:web_dashboard/features/free_trial_stages/data/repositories/free_trial_stages_repository.dart';
import 'package:web_dashboard/features/free_trial_stages/presentation/manager/free_trial_stages_state.dart';
import 'package:web_dashboard/core/errors/error_handler.dart';

/// Cubit that manages the free_trial_stages list, CRUD, search & filtering.
class FreeTrialStagesCubit extends Cubit<FreeTrialStagesState> {
  final FreeTrialStagesRepository _repository;

  FreeTrialStagesCubit({required FreeTrialStagesRepository repository})
      : _repository = repository,
        super(const FreeTrialStagesInitial());

  // ── Load ──────────────────────────────────────────────────────────────

  Future<void> loadFreeTrialStages() async {
    emit(const FreeTrialStagesLoading());
    try {
      final free_trial_stages = await _repository.getAll();
      emit(FreeTrialStagesLoaded(free_trial_stages: free_trial_stages, filteredFreeTrialStages: free_trial_stages));
    } catch (e) {
      emit(FreeTrialStagesError(ErrorHandler.handle(e)));
    }
  }

  // ── Create ────────────────────────────────────────────────────────────

  Future<void> createFreeTrialStage(FreeTrialStageModel free_trial_stage, {List<int>? imageBytes, String? imageName, List<int>? bgImageBytes, String? bgImageName}) async {
    try {
      await _repository.create(free_trial_stage, imageBytes: imageBytes, imageName: imageName, bgImageBytes: bgImageBytes, bgImageName: bgImageName);
      await loadFreeTrialStages();
    } catch (e) {
      emit(FreeTrialStagesError(ErrorHandler.handle(e)));
    }
  }

  // ── Update ────────────────────────────────────────────────────────────

  Future<void> updateFreeTrialStage(FreeTrialStageModel free_trial_stage, {List<int>? imageBytes, String? imageName, List<int>? bgImageBytes, String? bgImageName}) async {
    try {
      await _repository.update(free_trial_stage, imageBytes: imageBytes, imageName: imageName, bgImageBytes: bgImageBytes, bgImageName: bgImageName);
      await loadFreeTrialStages();
    } catch (e) {
      emit(FreeTrialStagesError(ErrorHandler.handle(e)));
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────

  Future<void> deleteFreeTrialStage(String id) async {
    try {
      await _repository.delete(id);
      await loadFreeTrialStages();
    } catch (e) {
      emit(FreeTrialStagesError(ErrorHandler.handle(e)));
    }
  }

  // ── Toggle Status ─────────────────────────────────────────────────────

  Future<void> toggleStatus(String id) async {
    try {
      await _repository.toggleStatus(id);
      await loadFreeTrialStages();
    } catch (e) {
      emit(FreeTrialStagesError(ErrorHandler.handle(e)));
    }
  }

  // ── Reorder ───────────────────────────────────────────────────────────

  Future<void> reorder(List<String> orderedIds) async {
    try {
      await _repository.reorder(orderedIds);
      await loadFreeTrialStages();
    } catch (e) {
      emit(FreeTrialStagesError(ErrorHandler.handle(e)));
    }
  }

  // ── Search / Filter ──────────────────────────────────────────────────

  void search(String query) {
    final currentState = state;
    if (currentState is FreeTrialStagesLoaded) {
      if (query.isEmpty) {
        emit(currentState.copyWith(
          filteredFreeTrialStages: currentState.free_trial_stages,
          searchQuery: '',
        ));
      } else {
        final filtered = currentState.free_trial_stages.where((free_trial_stage) {
          final lowerQuery = query.toLowerCase();
          return free_trial_stage.title.toLowerCase().contains(lowerQuery) ||
              (free_trial_stage.description?.toLowerCase().contains(lowerQuery) ?? false);
        }).toList();
        emit(currentState.copyWith(
          filteredFreeTrialStages: filtered,
          searchQuery: query,
        ));
      }
    }
  }
}
