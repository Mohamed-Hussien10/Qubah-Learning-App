import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qubah_learning_app/core/utils/usecase.dart';
import '../../../domain/usecases/get_stages_usecase.dart';
import '../state/stages_state.dart';

class StagesCubit extends Cubit<StagesState> {
  final GetStagesUseCase _getStagesUseCase;

  StagesCubit({required GetStagesUseCase getStagesUseCase})
    : _getStagesUseCase = getStagesUseCase,
      super(StagesInitial());

  Future<void> loadStages() async {
    emit(StagesLoading());
    try {
      final stages = await _getStagesUseCase(NoParams());
      emit(StagesLoaded(stages));
    } catch (e) {
      emit(StagesError(e.toString().split('Error: ').last.trim()));
    }
  }
}
