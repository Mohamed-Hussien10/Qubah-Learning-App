import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qubah_learning_app/core/utils/usecase.dart';
import '../../../domain/usecases/get_stages_usecase.dart';
import '../state/stages_state.dart';
import 'package:qubah_learning_app/core/errors/error_handler.dart';

class StagesCubit extends Cubit<StagesState> {
  final GetStagesUseCase _getStagesUseCase;
  bool _hasLoaded = false;

  StagesCubit({required GetStagesUseCase getStagesUseCase})
    : _getStagesUseCase = getStagesUseCase,
      super(StagesInitial());

  Future<void> loadStages({bool forceRefresh = false}) async {
    // Skip reload if data is already loaded and no force refresh requested
    if (_hasLoaded && state is StagesLoaded && !forceRefresh) return;

    emit(StagesLoading());
    try {
      final stages = await _getStagesUseCase(NoParams());
      _hasLoaded = true;
      emit(StagesLoaded(stages));
    } catch (e) {
      emit(StagesError(ErrorHandler.handle(e)));
    }
  }
}
