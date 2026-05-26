import 'package:equatable/equatable.dart';
import 'package:web_dashboard/features/educational_stages/data/models/stage_model.dart';

/// Base state for stages management.
abstract class StagesState extends Equatable {
  const StagesState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded.
class StagesInitial extends StagesState {
  const StagesInitial();
}

/// Loading state while fetching data.
class StagesLoading extends StagesState {
  const StagesLoading();
}

/// Data loaded successfully.
class StagesLoaded extends StagesState {
  /// The complete unfiltered list.
  final List<StageModel> stages;

  /// The list after applying search / filter.
  final List<StageModel> filteredStages;

  /// The current search query (empty = no filter).
  final String searchQuery;

  const StagesLoaded({
    required this.stages,
    required this.filteredStages,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [stages, filteredStages, searchQuery];

  StagesLoaded copyWith({
    List<StageModel>? stages,
    List<StageModel>? filteredStages,
    String? searchQuery,
  }) {
    return StagesLoaded(
      stages: stages ?? this.stages,
      filteredStages: filteredStages ?? this.filteredStages,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Error state.
class StagesError extends StagesState {
  final String message;
  const StagesError(this.message);

  @override
  List<Object?> get props => [message];
}
