import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dashboard/core/errors/error_handler.dart';
import 'package:web_dashboard/features/free_trial_stages/data/models/free_trial_stage_model.dart';
import 'package:web_dashboard/features/free_trial_stages/data/repositories/free_trial_stages_repository.dart';
import 'package:web_dashboard/core/services/dependency_injection.dart';
import 'package:web_dashboard/features/free_trial_grades/data/repositories/free_trial_grades_repository.dart';

import 'free_trial_stages_state.dart';

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
      
      List<FreeTrialStageModel> updatedStages = [];
      for (final stage in free_trial_stages) {
        try {
          final grades = await sl<FreeTrialGradesRepository>().getByStageId(stage.id);
          updatedStages.add(stage.copyWith(gradesCount: grades.length));
        } catch (e) {
          updatedStages.add(stage.copyWith(gradesCount: -99));
        }
      }

      emit(FreeTrialStagesLoaded(free_trial_stages: updatedStages, filteredFreeTrialStages: updatedStages));
    } catch (e) {
      emit(FreeTrialStagesError(ErrorHandler.handle(e)));
    }
  }

  // ── Create ────────────────────────────────────────────────────────────

  Future<void> createFreeTrialStage(
    FreeTrialStageModel free_trial_stage, {
    List<int>? imageBytes,
    String? imageName,
    List<int>? bgImageBytes,
    String? bgImageName,
  }) async {
    try {
      await _repository.create(
        free_trial_stage,
        imageBytes: imageBytes,
        imageName: imageName,
        bgImageBytes: bgImageBytes,
        bgImageName: bgImageName,
      );
      await loadFreeTrialStages();
    } catch (e) {
      emit(FreeTrialStagesError(ErrorHandler.handle(e)));
    }
  }

  // ── Update ────────────────────────────────────────────────────────────

  Future<void> updateFreeTrialStage(
    FreeTrialStageModel free_trial_stage, {
    List<int>? imageBytes,
    String? imageName,
    List<int>? bgImageBytes,
    String? bgImageName,
  }) async {
    try {
      await _repository.update(
        free_trial_stage,
        imageBytes: imageBytes,
        imageName: imageName,
        bgImageBytes: bgImageBytes,
        bgImageName: bgImageName,
      );
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

  // ── Search ────────────────────────────────────────────────────────────

  void search(String query) {
    if (state is FreeTrialStagesLoaded) {
      final currentState = state as FreeTrialStagesLoaded;
      if (query.isEmpty) {
        emit(currentState.copyWith(filteredFreeTrialStages: currentState.free_trial_stages));
        return;
      }
      final filtered = currentState.free_trial_stages.where((free_trial_stage) {
        return free_trial_stage.title.toLowerCase().contains(query.toLowerCase());
      }).toList();
      emit(currentState.copyWith(filteredFreeTrialStages: filtered));
    }
  }
}
