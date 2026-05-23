import 'package:equatable/equatable.dart';
import '../../../domain/entities/stage_entity.dart';

abstract class StagesState extends Equatable {
  const StagesState();
  @override
  List<Object?> get props => [];
}

class StagesInitial extends StagesState {}

class StagesLoading extends StagesState {}

class StagesLoaded extends StagesState {
  final List<StageEntity> stages;
  const StagesLoaded(this.stages);
  @override
  List<Object?> get props => [stages];
}

class StagesError extends StagesState {
  final String message;
  const StagesError(this.message);
  @override
  List<Object?> get props => [message];
}
