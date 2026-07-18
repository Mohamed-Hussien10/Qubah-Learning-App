import 'package:equatable/equatable.dart';
import 'package:web_dashboard/features/free_trial_stages/data/models/free_trial_stage_model.dart';

/// Base state for free_trial_stages management.
abstract class FreeTrialStagesState extends Equatable {
  const FreeTrialStagesState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded.
class FreeTrialStagesInitial extends FreeTrialStagesState {
  const FreeTrialStagesInitial();
}

/// Loading state while fetching data.
class FreeTrialStagesLoading extends FreeTrialStagesState {
  const FreeTrialStagesLoading();
}

/// Data loaded successfully.
class FreeTrialStagesLoaded extends FreeTrialStagesState {
  /// The complete unfiltered list.
  final List<FreeTrialStageModel> free_trial_stages;

  /// The list after applying search / filter.
  final List<FreeTrialStageModel> filteredFreeTrialStages;

  /// The current search query (empty = no filter).
  final String searchQuery;

  const FreeTrialStagesLoaded({
    required this.free_trial_stages,
    required this.filteredFreeTrialStages,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [free_trial_stages, filteredFreeTrialStages, searchQuery];

  FreeTrialStagesLoaded copyWith({
    List<FreeTrialStageModel>? free_trial_stages,
    List<FreeTrialStageModel>? filteredFreeTrialStages,
    String? searchQuery,
  }) {
    return FreeTrialStagesLoaded(
      free_trial_stages: free_trial_stages ?? this.free_trial_stages,
      filteredFreeTrialStages: filteredFreeTrialStages ?? this.filteredFreeTrialStages,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Error state.
class FreeTrialStagesError extends FreeTrialStagesState {
  final String message;
  const FreeTrialStagesError(this.message);

  @override
  List<Object?> get props => [message];
}
